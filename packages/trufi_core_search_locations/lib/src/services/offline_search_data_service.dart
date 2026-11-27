import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart';

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
/// { "streets": { "<ref>": [name, alternativeNames, [lon, lat], region] },
///   "streetJunctions": { "<ref>": [[otherStreetRef, [lon, lat]], …] } }
/// ```
///
/// `region` is the municipality the street centre falls in (the OSM
/// `admin_level=8` boundary). It becomes the row's subtitle, so the
/// "Calle Sucre" of Cochabamba and the one of Sacaba can be told apart
/// (#972); an index that lacks it only loses the subtitle. This assumes
/// one street entry per (name, municipality), which the exporter emits
/// from 1.2.0 on: an older index merges every same-named way of the
/// extract into one entry with one centre, and its `region` (when present)
/// can name a homonym 40 km away — regenerate the index rather than trust
/// such a subtitle.
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
  ///
  /// Which streets make the cut is a total order, so it depends neither on
  /// the index's order nor on the sort (#1054): the streets with a word equal
  /// to each query word, then those where a query word only starts a word
  /// ("1" in "Calle 100"), then those that only contain it ("ica" in
  /// "Arica"); inside each, the type class ([streetTypeRanks]), then — with a [focus] — the street named
  /// like the query before one only known by it and the nearest one, or
  /// without it the best text match, the street named like the query before
  /// one only known by it, and the one with more corners; name, municipality
  /// and ref close the tie.
  final int limitPerCategory;

  /// Word used between two streets in this language ("y" in Spanish,
  /// "and" in English). Queries like `ayacucho y heroinas` are read as a
  /// junction lookup.
  final List<String> junctionSeparators;

  /// A point of the city (its centre, say). Among streets of the same match
  /// quality, type class and name kind, the nearest to it comes first;
  /// without it, the text rank decides (the street named like the query
  /// first), then the one with more corners.
  final LatLng? focus;

  /// Street types by class, as normalized prefixes (no accents, lowercase):
  /// index 0 is listed first, the last class last. A name with no listed
  /// type counts as the class at index 1 (where "calle" sits in the default).
  /// Prefixes must be normalized, or they never match (asserted). A query
  /// that starts with a type ("avenida grau") finds the streets of that
  /// class, and also the names that contain every word of it, the type as a
  /// whole word ("Avenida Calle 26" for "calle 26").
  /// Defaults to Spanish; another language simply never matches a type.
  final List<List<String>> streetTypeRanks;

  _SearchData? _data;
  Future<_SearchData>? _loading;

  OfflineSearchDataService({
    this.assetPath = 'assets/search/search.json',
    this.limitPerCategory = 10,
    this.junctionSeparators = const ['y', 'and', 'esq', 'esquina', 'con', '&'],
    this.focus,
    this.streetTypeRanks = defaultStreetTypeRanks,
  });

  /// Spanish street types: avenues and main roads, then calles and jirones,
  /// then pasajes.
  static const defaultStreetTypeRanks = <List<String>>[
    [
      'avenida', 'av', 'av.', 'via expresa', 'carretera', 'autopista',
      'ovalo', 'panamericana', 'boulevard', 'bulevar', 'alameda', 'malecon',
      'paseo',
    ],
    ['calle', 'jiron', 'jr', 'jr.', 'prolongacion', 'camino', 'circunvalacion'],
    ['pasaje', 'psje', 'psje.', 'pje', 'pje.', 'callejon', 'sendero'],
  ];

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
    return _SearchData.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
      types: _StreetTypes(streetTypeRanks),
      focus: focus,
    );
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

/// Subtitle of the corner of [street] and [other]: the municipality of
/// [street], plus the other's when the corner sits on a boundary
/// ("Cercado / Sacaba"). Whichever one is known when the other isn't;
/// null when neither is. Relies on each street entry belonging to a
/// single municipality (see the class doc): the corner itself carries no
/// region in the index, only the two streets do.
String? _junctionAddress(_Street street, _Street other) {
  final region = street.region;
  final otherRegion = other.region;
  if (region == null) return otherRegion;
  if (otherRegion == null || otherRegion == region) return region;
  return '$region / $otherRegion';
}

/// A street name split into its type and the rest, once, at load time.
class _ParsedName {
  final String normalized;
  final int typeClass;

  /// [normalized] without its type ("avenida grau" → "grau").
  final String base;
  final List<String> words;
  final List<String> baseWords;

  _ParsedName(this.normalized, this.typeClass, this.base)
    : words = _wordsOf(normalized),
      baseWords = _wordsOf(base);

  bool get hasType => base != normalized;
}

final _wordSeparators = RegExp(r'[^\p{L}\p{M}\p{N}]+', unicode: true);

List<String> _wordsOf(String text) =>
    text.split(_wordSeparators).where((w) => w.isNotEmpty).toList();

/// How [queryWords] answer [nameWords]: [_Query.wholeWordMatch] when each
/// equals a word of the name, [_Query.prefixMatch] when some only start one,
/// null when one matches no word.
int? _wordMatch(List<String> queryWords, List<String> nameWords) {
  var level = _Query.wholeWordMatch;
  for (final queryWord in queryWords) {
    int? best;
    for (final word in nameWords) {
      if (word == queryWord) {
        best = _Query.wholeWordMatch;
        break;
      }
      if (word.startsWith(queryWord)) best = _Query.prefixMatch;
    }
    if (best == null) return null;
    level = math.max(level, best);
  }
  return level;
}

/// Reads the type at the start of a normalized name or query.
class _StreetTypes {
  /// Class of a name whose type is not listed: the one of "calle".
  static const untypedClass = 1;

  /// (prefix, class), longest prefix first so "via expresa" beats "via".
  final List<(String, int)> _prefixes;

  _StreetTypes(List<List<String>> ranks)
    : assert(
        ranks.every((types) => types.every((p) => p == _normalize(p))),
        'streetTypeRanks must be normalized: lowercase, no accents',
      ),
      _prefixes = [
        for (var i = 0; i < ranks.length; i++)
          for (final prefix in ranks[i]) (prefix, i),
      ]..sort((a, b) => b.$1.length.compareTo(a.$1.length));

  _ParsedName parse(String normalized) {
    for (final (prefix, typeClass) in _prefixes) {
      if (normalized.startsWith('$prefix ')) {
        return _ParsedName(
          normalized,
          typeClass,
          normalized.substring(prefix.length + 1),
        );
      }
    }
    return _ParsedName(normalized, untypedClass, normalized);
  }
}

/// What the user typed, read once per search.
class _Query {
  final _ParsedName parsed;

  /// The query starts with a street type: its words match only names of that
  /// class, unless the whole name contains them.
  final bool isTyped;

  /// The words of the typed type ("via expresa"); empty when untyped.
  final List<String> typeWords;

  _Query._(this.parsed)
    : isTyped = parsed.base != parsed.normalized,
      typeWords = _wordsOf(
        parsed.normalized.substring(
          0,
          parsed.normalized.length - parsed.base.length,
        ),
      );

  factory _Query(_StreetTypes types, String normalized) =>
      _Query._(types.parse(normalized));

  String get normalized => parsed.normalized;

  /// Cheap test that leaves out most streets before any word is compared:
  /// every match contains each query word as text.
  bool canMatch(_Street street) =>
      parsed.words.every(street.normalized.contains);

  /// How [name] answers the query: [wholeWordMatch], [prefixMatch],
  /// [substringMatch], or null.
  int? matchGroup(_ParsedName name) {
    final sameClass = !isTyped || name.typeClass == parsed.typeClass;
    var best = sameClass ? _wordMatch(parsed.baseWords, name.baseWords) : null;
    if (best != wholeWordMatch) {
      final full = _fullNameMatch(name);
      if (full != null && (best == null || full < best)) best = full;
    }
    if (best != null) return best;
    if (!isTyped && name.normalized.contains(normalized)) {
      return substringMatch;
    }
    return null;
  }

  /// The query against every word of the name, type included. A typed query
  /// must find its type word whole ("calle" is no "Callejón").
  int? _fullNameMatch(_ParsedName name) {
    if (!isTyped) return _wordMatch(parsed.words, name.words);
    if (_wordMatch(typeWords, name.words) != wholeWordMatch) return null;
    return _wordMatch(parsed.baseWords, name.words);
  }

  /// Every query word equals a word of the name.
  static const wholeWordMatch = 0;

  /// Every query word starts a word of the name, some only start it
  /// ("1" in "Calle 100").
  static const prefixMatch = 1;

  /// The query only appears inside a word ("ica" in "Arica").
  static const substringMatch = 2;
}

class _Street {
  final String ref;
  final String name;
  final List<String> alternativeNames;
  final double? latitude;
  final double? longitude;

  /// Municipality the street lies in; null when the index has none.
  final String? region;

  /// [name] alone, normalized and split: tells the street named exactly
  /// like the query, and orders streets that match equally well.
  final _ParsedName parsedName;

  /// [alternativeNames], normalized and split one by one.
  final List<_ParsedName> parsedAlternativeNames;

  /// Metres to the focus; null without one or without coordinates.
  final double? distanceToFocus;

  _Street({
    required this.ref,
    required this.name,
    required this.alternativeNames,
    required this.latitude,
    required this.longitude,
    required this.region,
    required _StreetTypes types,
    required LatLng? focus,
  }) : parsedName = types.parse(_normalize(name)),
       parsedAlternativeNames = [
         for (final alternative in alternativeNames)
           types.parse(_normalize(alternative)),
       ],
       distanceToFocus = focus == null || latitude == null || longitude == null
           ? null
           : const Distance().as(
               LengthUnit.Meter,
               focus,
               LatLng(latitude, longitude),
             );

  String get normalizedName => parsedName.normalized;

  /// Name and alternative names joined, for the junction lookup.
  late final String normalized = [
    parsedName,
    ...parsedAlternativeNames,
  ].map((n) => n.normalized).join(' | ');
}

/// A street that answers a query, with what the order needs of it.
class _Match {
  /// Tier of a match that is no text of the main name.
  static const _farTier = 104;

  final _Street street;

  /// [_Query.wholeWordMatch], [_Query.prefixMatch] or
  /// [_Query.substringMatch]: the best of its names.
  final int group;

  /// Lowest type class among the names that match in [group].
  final int typeClass;

  /// 0 when the street's own name matches in [group], 1 when only an
  /// alternative name does.
  final int nameKind;

  /// How well the name matches, lower first (no focus): named like the
  /// query, only an alternative name is, starts with it, contains it.
  final int tier;

  _Match._(this.street, this.group, this.typeClass, this.nameKind, this.tier);

  /// Null when [street] does not answer [query].
  static _Match? of(_Street street, _Query query) {
    if (!query.canMatch(street)) return null;
    final mainGroup = query.matchGroup(street.parsedName);
    var group = mainGroup;
    var typeClass = street.parsedName.typeClass;
    for (final name in street.parsedAlternativeNames) {
      final alternativeGroup = query.matchGroup(name);
      if (alternativeGroup == null) continue;
      if (group == null || alternativeGroup < group) {
        group = alternativeGroup;
        typeClass = name.typeClass;
      } else if (alternativeGroup == group) {
        typeClass = math.min(typeClass, name.typeClass);
      }
    }
    if (group == null) return null;
    return _Match._(
      street,
      group,
      typeClass,
      mainGroup == group ? 0 : 1,
      _tierOf(street, query),
    );
  }

  static int _tierOf(_Street street, _Query query) {
    final main = street.parsedName;
    final text = query.normalized;
    if (main.normalized == text) return 0;
    if (street.parsedAlternativeNames.any((n) => n.normalized == text)) {
      return 1;
    }
    final index = main.base.indexOf(query.parsed.base);
    if (index < 0) return _farTier;
    if (index == 0 && !main.hasType) return 2;
    return 3 + math.min(index, 100);
  }
}

class _SearchData {
  final Map<String, _Street> streets;
  final Map<String, List<(String ref, double lat, double lon)>> junctions;
  final _StreetTypes types;
  _SearchData({
    required this.streets,
    required this.junctions,
    required this.types,
  });

  factory _SearchData.fromJson(
    Map<String, dynamic> json, {
    required _StreetTypes types,
    required LatLng? focus,
  }) {
    final streets = <String, _Street>{};
    (json['streets'] as Map<String, dynamic>? ?? {}).forEach((ref, value) {
      final row = value as List<dynamic>;
      final coords = row.length > 2 ? row[2] as List<dynamic>? : null;
      // Older indexes stop at the coordinates; some rows carry an empty
      // or null region. All of those simply have no municipality.
      final region = row.length > 3 ? row[3] : null;
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
        region: region is String && region.trim().isNotEmpty
            ? region.trim()
            : null,
        types: types,
        focus: focus,
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

    return _SearchData(
      streets: streets,
      junctions: junctions,
      types: types,
    );
  }

  Iterable<_Street> _matchingStreets(String normalizedQuery) => streets.values
      .where((s) => s.normalized.contains(normalizedQuery));

  /// The [limit] best streets for [q]: by [_compare].
  List<SearchLocation> findStreets(String q, int limit) {
    final query = _Query(types, q);
    final matches = <_Match>[];
    for (final street in streets.values) {
      if (street.latitude == null || street.longitude == null) continue;
      final match = _Match.of(street, query);
      if (match != null) matches.add(match);
    }
    matches.sort(_compare);
    return matches
        .take(limit)
        .map(
          (m) => SearchLocation(
            id: 'street:${m.street.ref}',
            displayName: m.street.name,
            address: m.street.region,
            latitude: m.street.latitude!,
            longitude: m.street.longitude!,
          ),
        )
        .toList();
  }

  /// Order of two matches: a total order, so equal data gives equal
  /// results (#1054).
  ///
  /// The match quality decides first, so an exact "Ica" is never pushed out
  /// by the eighty streets that only contain it ("Arica"). Inside a group
  /// the type class comes next, so a jirón never takes the place of an
  /// avenue with the same name. With a focus the street named by the query
  /// comes before one only known by it, then the nearest. Without one, the
  /// best text match first (the main name equal to the query, then an
  /// alternative name equal to it, then the rest), then the main name
  /// before an alternative one, then the street with more corners.
  ///
  /// Ties are the rule, not the exception: every "Avenida …" is a prefix
  /// match for "avenida", and a city has one "Avenida Circunvalación" per
  /// municipality. `List.sort` is not stable, so without a tie-break the
  /// rows that survive the limit were whatever the sort left first. The
  /// street with more corners is the longer, better connected one — the
  /// avenue a rider most likely means rather than its three-block namesake
  /// two towns away. Name, municipality and ref close the order.
  int _compare(_Match a, _Match b) {
    final byGroup = a.group.compareTo(b.group);
    if (byGroup != 0) return byGroup;
    final byClass = a.typeClass.compareTo(b.typeClass);
    if (byClass != 0) return byClass;
    final aDistance = a.street.distanceToFocus;
    final bDistance = b.street.distanceToFocus;
    if (aDistance != null && bDistance != null) {
      final byKind = a.nameKind.compareTo(b.nameKind);
      if (byKind != 0) return byKind;
      final byDistance = aDistance.compareTo(bDistance);
      if (byDistance != 0) return byDistance;
    } else {
      final byTier = a.tier.compareTo(b.tier);
      if (byTier != 0) return byTier;
      final byKind = a.nameKind.compareTo(b.nameKind);
      if (byKind != 0) return byKind;
      final byCorners = _cornerCount(
        b.street,
      ).compareTo(_cornerCount(a.street));
      if (byCorners != 0) return byCorners;
    }
    final byName = a.street.normalizedName.compareTo(b.street.normalizedName);
    if (byName != 0) return byName;
    final byRegion = (a.street.region ?? '').compareTo(b.street.region ?? '');
    if (byRegion != 0) return byRegion;
    return a.street.ref.compareTo(b.street.ref);
  }

  int _cornerCount(_Street street) => junctions[street.ref]?.length ?? 0;

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
            address: _junctionAddress(street, other),
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
        if (streets[junction.$1] case final other?)
          SearchLocation(
            id: 'junction:$streetRef:${junction.$1}',
            displayName: '${street.name} & ${other.name}',
            address: _junctionAddress(street, other),
            latitude: junction.$2,
            longitude: junction.$3,
          ),
    ];
  }
}
