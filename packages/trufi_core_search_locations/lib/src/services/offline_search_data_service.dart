import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart' show rootBundle;

import '../models/search_location.dart';
import 'search_location_service.dart';

/// Offline search over a city's `search.json`: streets and the junctions
/// between them.
///
/// Places, businesses and addresses are deliberately left to the online
/// service — it ranks them better and stays fresher. Returning them from
/// here too only pushed its results off the screen.
///
/// This is what makes *"Ayacucho y Heroínas"* findable. In cities without
/// street numbers people give directions as intersections, and no online
/// geocoder answers that — Photon can find a street or a place, but not
/// the point where two streets cross. The data comes from the
/// association's `osm-search-data-export` (see the `search-*` tool in each
/// city app) in its `json-compact` shape:
///
/// ```json
/// { "streets": { "<ref>": [name, alternativeNames, coordinates, region] },
///   "streetJunctions": { "<ref>": [[otherStreetRef, [lon, lat]], …] } }
/// ```
///
/// Meant to be combined with an online service rather than to replace it
/// (see [CompositeSearchLocationService]): this one owns streets and
/// junctions, the online one owns everything else and stays fresher.
class OfflineSearchDataService
    with SearchLocationDrillDown
    implements SearchLocationService {
  /// Asset path of the generated `search.json`.
  final String assetPath;

  /// Upper bound on results per category, so a two-letter query doesn't
  /// return thousands of rows.
  final int limitPerCategory;

  /// Word used between two streets in this language ("y" in Spanish,
  /// "and" in English). Queries like `ayacucho y heroinas` are read as a
  /// junction lookup.
  final List<String> junctionSeparators;

  _SearchData? _data;
  Future<_SearchData>? _loading;

  OfflineSearchDataService({
    this.assetPath = 'assets/search/search.json',
    this.limitPerCategory = 10,
    this.junctionSeparators = const ['y', 'and', 'esq', 'esquina', 'con', '&'],
  });

  /// Loads (once) and keeps the parsed data in memory.
  Future<_SearchData> _ensureLoaded() {
    if (_data != null) return Future.value(_data);
    return _loading ??= _load().then((d) {
      _data = d;
      _loading = null;
      return d;
    }).catchError((Object error, StackTrace stack) {
      // Don't cache the failure: a later call should try again rather
      // than fail forever because the first attempt raced a cold start.
      _loading = null;
      throw SearchLocationException(
        'Could not load offline search data from $assetPath',
        originalError: error,
      );
    });
  }

  Future<_SearchData> _load() async {
    // rootBundle throws a FlutterError when the asset is missing; callers
    // (and SearchLocationsCubit) only handle SearchLocationException, so
    // the wrapper above is what keeps a missing asset from surfacing as
    // an unhandled async error and a spinner that never stops.
    final raw = await rootBundle.loadString(assetPath);
    return _SearchData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<List<SearchLocation>> search(String query) async {
    final q = _normalize(query);
    if (q.isEmpty) return const [];

    final data = await _ensureLoaded();
    final results = <SearchLocation>[];

    // "street A <separator> street B" → the crossing itself.
    final pair = _splitJunctionQuery(q);
    if (pair != null) {
      results.addAll(data.findJunctions(pair.$1, pair.$2, limitPerCategory));
    }

    results.addAll(data.findStreets(q, limitPerCategory));
    return results;
  }

  /// The junctions of a given street, for the "pick a street, then pick
  /// the corner" flow.
  Future<List<SearchLocation>> junctionsOf(String streetRef) async {
    final data = await _ensureLoaded();
    return data.junctionsOf(streetRef);
  }

  /// A street result can be expanded into its corners when this dataset
  /// knows at least one junction for it. Synchronous on purpose: street
  /// results only exist after the data loaded, so `_data` is already in
  /// memory by the time the search screen asks.
  @override
  bool canDrillDown(SearchLocation location) {
    const prefix = 'street:';
    if (!location.id.startsWith(prefix)) return false;
    final ref = location.id.substring(prefix.length);
    return _data?.hasJunctions(ref) ?? false;
  }

  @override
  Future<List<SearchLocation>> drillDown(SearchLocation location) {
    return junctionsOf(location.id.substring('street:'.length));
  }

  @override
  Future<SearchLocation?> reverse(double latitude, double longitude) async {
    // Reverse geocoding stays with the online service: this dataset has
    // no addresses, and guessing the nearest street would be worse than
    // saying nothing.
    return null;
  }

  @override
  void dispose() {
    _data = null;
    _loading = null;
  }

  (String, String)? _splitJunctionQuery(String q) {
    for (final sep in junctionSeparators) {
      final pattern = RegExp('\\s${RegExp.escape(sep)}\\s');
      final match = pattern.firstMatch(q);
      if (match != null) {
        final a = q.substring(0, match.start).trim();
        final b = q.substring(match.end).trim();
        if (a.isNotEmpty && b.isNotEmpty) return (a, b);
      }
    }
    return null;
  }
}

/// Lowercases, strips accents and collapses whitespace so "Ayacucho" and
/// "ayacucho" match, and so does "Heroínas" typed without the accent.
String _normalize(String value) {
  const from = 'áàäâãéèëêíìïîóòöôõúùüûñç';
  const to = 'aaaaaeeeeiiiiooooouuuunc';
  final lower = value.toLowerCase().trim();
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    final index = from.indexOf(char);
    buffer.write(index >= 0 ? to[index] : char);
  }
  return buffer.toString().replaceAll(RegExp(r'\s+'), ' ');
}

class _Street {
  final String ref;
  final String name;
  final List<String> alternativeNames;
  final double? latitude;
  final double? longitude;
  final String normalized;

  _Street({
    required this.ref,
    required this.name,
    required this.alternativeNames,
    required this.latitude,
    required this.longitude,
  }) : normalized = [name, ...alternativeNames].map(_normalize).join(' | ');
}

class _SearchData {
  final Map<String, _Street> streets;
  final Map<String, List<(String ref, double lat, double lon)>> junctions;
  _SearchData({
    required this.streets,
    required this.junctions,
  });

  factory _SearchData.fromJson(Map<String, dynamic> json) {
    final streets = <String, _Street>{};
    (json['streets'] as Map<String, dynamic>? ?? {}).forEach((ref, value) {
      final row = value as List<dynamic>;
      final coords = row.length > 2 ? row[2] as List<dynamic>? : null;
      streets[ref] = _Street(
        ref: ref,
        name: row.isNotEmpty ? row[0] as String? ?? '' : '',
        alternativeNames: row.length > 1
            ? (row[1] as List<dynamic>? ?? const []).cast<String>()
            : const [],
        // The exporter writes [lon, lat].
        longitude: coords != null && coords.isNotEmpty
            ? (coords[0] as num).toDouble()
            : null,
        latitude: coords != null && coords.length > 1
            ? (coords[1] as num).toDouble()
            : null,
      );
    });

    final junctions = <String, List<(String, double, double)>>{};
    (json['streetJunctions'] as Map<String, dynamic>? ?? {}).forEach(
      (ref, value) {
        final list = <(String, double, double)>[];
        for (final entry in (value as List<dynamic>)) {
          // One malformed row must not cost the whole city its data.
          if (entry is! List || entry.length < 2) continue;
          final other = entry[0];
          final coords = entry[1];
          if (other is! String || coords is! List || coords.length < 2) {
            continue;
          }
          list.add((
            other,
            (coords[1] as num).toDouble(),
            (coords[0] as num).toDouble(),
          ));
        }
        junctions[ref] = list;
      },
    );

    return _SearchData(streets: streets, junctions: junctions);
  }

  Iterable<_Street> _matchingStreets(String normalizedQuery) => streets.values
      .where((s) => s.normalized.contains(normalizedQuery));

  List<SearchLocation> findStreets(String q, int limit) {
    final matches = _matchingStreets(q).toList()
      ..sort((a, b) => _rank(a.normalized, q).compareTo(_rank(b.normalized, q)));
    return matches
        .where((s) => s.latitude != null && s.longitude != null)
        .take(limit)
        .map(
          (s) => SearchLocation(
            id: 'street:${s.ref}',
            displayName: s.name,
            latitude: s.latitude!,
            longitude: s.longitude!,
          ),
        )
        .toList();
  }

  /// Junctions between a street matching [a] and one matching [b].
  List<SearchLocation> findJunctions(String a, String b, int limit) {
    final results = <SearchLocation>[];
    for (final street in _matchingStreets(a)) {
      for (final junction in junctions[street.ref] ?? const []) {
        final other = streets[junction.$1];
        if (other == null || !other.normalized.contains(b)) continue;
        results.add(
          SearchLocation(
            id: 'junction:${street.ref}:${junction.$1}',
            displayName: '${street.name} & ${other.name}',
            latitude: junction.$2,
            longitude: junction.$3,
          ),
        );
        if (results.length >= limit) return results;
      }
    }
    return results;
  }

  /// Whether [streetRef] has at least one well-formed junction.
  bool hasJunctions(String streetRef) =>
      (junctions[streetRef] ?? const []).isNotEmpty;

  /// Every junction of one street, for the drill-down flow.
  List<SearchLocation> junctionsOf(String streetRef) {
    final street = streets[streetRef];
    if (street == null) return const [];
    return [
      for (final junction in junctions[streetRef] ?? const [])
        if (streets[junction.$1] != null)
          SearchLocation(
            id: 'junction:$streetRef:${junction.$1}',
            displayName: '${street.name} & ${streets[junction.$1]!.name}',
            latitude: junction.$2,
            longitude: junction.$3,
          ),
    ];
  }

  /// Exact match first, then prefix, then anything containing the query.
  int _rank(String candidate, String query) {
    if (candidate == query) return 0;
    if (candidate.startsWith(query)) return 1;
    return 2 + math.min(candidate.indexOf(query), 100);
  }
}
