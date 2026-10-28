import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import 'nearby_line.dart';
import 'nearby_lines_data_source.dart';
import 'nearby_radius.dart';
import 'nearby_street_anchor.dart';

/// Where the search anchor came from.
enum NearbyAnchorSource {
  /// A GPS fix.
  device,

  /// The rider long-pressed the map.
  pin,

  /// No fix and no pin yet: the app's default center.
  fallback,

  /// A street picked in the search: every corner of
  /// [NearbyLinesState.street] is an anchor (trufi-sanaa#20).
  street,
}

/// Resolves the device position; null when permission is denied, location
/// services are off, or no fix arrives in time.
typedef NearbyLocateCallback = Future<LatLng?> Function();

class NearbyLinesState extends Equatable {
  const NearbyLinesState({
    required this.anchor,
    required this.anchorSource,
    required this.radius,
    required this.availability,
    this.street,
    this.lines = const [],
    this.counts = const {},
    this.selectedLineKey,
    this.selectedGeometry = const [],
    this.isLoading = false,
    this.isLocating = false,
    this.locationDenied = false,
    this.errorMessage,
  });

  /// Null only until the first [NearbyLinesCubit.start] settles.
  final LatLng? anchor;
  final NearbyAnchorSource anchorSource;
  final NearbyRadius radius;
  final NearbyAvailability availability;

  /// Set while [anchorSource] is [NearbyAnchorSource.street]: [anchor] is
  /// then the street's centre and [lines] the union over its corners.
  final NearbyStreetAnchor? street;

  /// Every row within the widest radius, nearest first.
  final List<NearbyLine> lines;

  /// Chip counts per bracket (cumulative).
  final Map<NearbyRadius, int> counts;

  final String? selectedLineKey;

  /// Polyline of the highlighted line; empty when nothing is selected.
  final List<LatLng> selectedGeometry;

  final bool isLoading;
  final bool isLocating;

  /// The last locate attempt produced no fix; the header explains the pin.
  final bool locationDenied;
  final String? errorMessage;

  List<NearbyLine> get visibleLines =>
      lines.where((line) => line.isWithin(radius)).toList(growable: false);

  NearbyLine? get selectedLine {
    final key = selectedLineKey;
    if (key == null) return null;
    for (final line in lines) {
      if (line.lineKey == key) return line;
    }
    return null;
  }

  bool get hasSelection => selectedLineKey != null;

  NearbyLinesState copyWith({
    LatLng? anchor,
    NearbyAnchorSource? anchorSource,
    NearbyRadius? radius,
    NearbyAvailability? availability,
    NearbyStreetAnchor? street,
    List<NearbyLine>? lines,
    Map<NearbyRadius, int>? counts,
    String? selectedLineKey,
    List<LatLng>? selectedGeometry,
    bool? isLoading,
    bool? isLocating,
    bool? locationDenied,
    String? errorMessage,
    bool clearSelection = false,
    bool clearError = false,
    bool clearStreet = false,
  }) {
    return NearbyLinesState(
      anchor: anchor ?? this.anchor,
      anchorSource: anchorSource ?? this.anchorSource,
      radius: radius ?? this.radius,
      availability: availability ?? this.availability,
      street: clearStreet ? null : (street ?? this.street),
      lines: lines ?? this.lines,
      counts: counts ?? this.counts,
      selectedLineKey: clearSelection
          ? null
          : (selectedLineKey ?? this.selectedLineKey),
      selectedGeometry: clearSelection
          ? const []
          : (selectedGeometry ?? this.selectedGeometry),
      isLoading: isLoading ?? this.isLoading,
      isLocating: isLocating ?? this.isLocating,
      locationDenied: locationDenied ?? this.locationDenied,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    anchor,
    anchorSource,
    radius,
    availability,
    street,
    lines,
    counts,
    selectedLineKey,
    selectedGeometry,
    isLoading,
    isLocating,
    locationDenied,
    errorMessage,
  ];
}

/// Owns the anchor, the radius filter and the highlighted line of the
/// nearby-lines screen. No widget imports: the screen renders the state and
/// calls the methods.
class NearbyLinesCubit extends Cubit<NearbyLinesState> {
  NearbyLinesCubit({
    required this.dataSource,
    required this.defaultAnchor,
    required this.locate,
    NearbyRadius initialRadius = NearbyRadius.m300,
  }) : super(
         NearbyLinesState(
           anchor: null,
           anchorSource: NearbyAnchorSource.fallback,
           radius: initialRadius,
           availability: dataSource?.availability ?? NearbyAvailability.missing,
           isLoading: true,
         ),
       );

  /// Null when the app registered no offline feed: the screen shows the
  /// unavailable state and never queries.
  final NearbyLinesDataSource? dataSource;

  /// Anchor when there is neither a fix nor a pin (the map's default center).
  final LatLng defaultAnchor;

  final NearbyLocateCallback locate;

  /// Bumped by every [start] / [useMyLocation]; an async step that resumes
  /// with an older token belongs to a superseded visit and is dropped.
  int _startToken = 0;

  static Map<NearbyRadius, int> get _zeroCounts => {
    for (final radius in NearbyRadius.values) radius: 0,
  };

  /// Runs on every screen visit: load the feed, locate, query.
  Future<void> start() async {
    final token = ++_startToken;
    if (!await _loadFeed(token)) return;
    await _locateAndQuery(token);
  }

  /// The lines along [street] (trufi-sanaa#20): the union of the nearby
  /// lines of its corners, each line once at its nearest corner. Replaces a
  /// fix or a pin; a long-press or [useMyLocation] leaves the street again.
  Future<void> startAlongStreet(NearbyStreetAnchor street) async {
    final token = ++_startToken;
    emit(
      state.copyWith(
        anchor: street.center ?? state.anchor ?? defaultAnchor,
        anchorSource: NearbyAnchorSource.street,
        street: street,
        locationDenied: false,
        isLocating: false,
        clearSelection: true,
      ),
    );
    if (!await _loadFeed(token)) return;
    _query();
  }

  /// Shared prologue of [start] and [startAlongStreet]: settles
  /// [NearbyLinesState.availability]. False when nothing can be queried —
  /// no source, feed missing — or when a newer start superseded [token].
  Future<bool> _loadFeed(int token) async {
    final source = dataSource;
    if (source == null) {
      emit(
        state.copyWith(
          availability: NearbyAvailability.missing,
          anchor: state.anchor ?? defaultAnchor,
          isLoading: false,
        ),
      );
      return false;
    }

    emit(
      state.copyWith(
        isLoading: true,
        availability: source.availability == NearbyAvailability.available
            ? NearbyAvailability.available
            : NearbyAvailability.loading,
        clearError: true,
      ),
    );
    await source.ensureLoaded();
    if (token != _startToken || isClosed) return false;

    if (source.availability != NearbyAvailability.available) {
      emit(
        state.copyWith(
          availability: NearbyAvailability.missing,
          anchor: state.anchor ?? defaultAnchor,
          isLoading: false,
        ),
      );
      return false;
    }
    emit(state.copyWith(availability: NearbyAvailability.available));
    return true;
  }

  /// Re-anchors on a fresh fix; a pin set earlier survives a failed fix.
  Future<void> useMyLocation() async {
    final source = dataSource;
    if (source == null || source.availability != NearbyAvailability.available) {
      return start();
    }
    await _locateAndQuery(++_startToken);
  }

  /// Map long-press: the pin becomes the anchor (and a street is left).
  void setAnchor(LatLng point) {
    emit(
      state.copyWith(
        anchor: point,
        anchorSource: NearbyAnchorSource.pin,
        locationDenied: false,
        clearStreet: true,
      ),
    );
    _query();
  }

  /// Only filters: the rows already cover the widest radius.
  void setRadius(NearbyRadius radius) => emit(state.copyWith(radius: radius));

  /// Highlights [lineKey]; the same key again clears the highlight.
  void toggleLine(String lineKey) {
    if (state.selectedLineKey == lineKey) {
      clearSelection();
      return;
    }
    NearbyLine? line;
    for (final candidate in state.lines) {
      if (candidate.lineKey == lineKey) {
        line = candidate;
        break;
      }
    }
    if (line == null) return;
    emit(
      state.copyWith(
        selectedLineKey: lineKey,
        selectedGeometry: _geometryOf(line),
      ),
    );
  }

  void clearSelection() => emit(state.copyWith(clearSelection: true));

  /// Re-checks the feed and re-queries at the current anchor.
  Future<void> refresh() async {
    final source = dataSource;
    if (source != null &&
        source.availability == NearbyAvailability.available &&
        state.anchor != null) {
      emit(state.copyWith(availability: NearbyAvailability.available));
      _query();
      return;
    }
    await start();
  }

  Future<void> _locateAndQuery(int token) async {
    emit(state.copyWith(isLocating: true));
    LatLng? point;
    try {
      point = await locate();
    } catch (_) {
      point = null;
    }
    if (token != _startToken || isClosed) return;

    if (point != null) {
      emit(
        state.copyWith(
          anchor: point,
          anchorSource: NearbyAnchorSource.device,
          locationDenied: false,
          isLocating: false,
          clearStreet: true,
        ),
      );
    } else {
      emit(
        state.copyWith(
          anchor: state.anchor ?? defaultAnchor,
          anchorSource: state.anchor == null
              ? NearbyAnchorSource.fallback
              : state.anchorSource,
          locationDenied: true,
          isLocating: false,
        ),
      );
    }
    _query();
  }

  void _query() {
    final source = dataSource;
    final anchor = state.anchor;
    if (source == null || anchor == null) return;
    try {
      final street = state.street;
      final result = street == null
          ? source.findNearby(anchor)
          : NearbyLinesResult.union([
              for (final corner in street.corners) source.findNearby(corner),
            ], anchor: anchor);
      final selected = state.selectedLineKey;
      NearbyLine? stillSelected;
      if (selected != null) {
        for (final line in result.lines) {
          if (line.lineKey == selected) {
            stillSelected = line;
            break;
          }
        }
      }
      emit(
        state.copyWith(
          lines: result.lines,
          counts: result.bracketCounts,
          isLoading: false,
          clearError: true,
          clearSelection: stillSelected == null,
          selectedGeometry: stillSelected == null
              ? null
              : _geometryOf(stillSelected),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          lines: const [],
          counts: _zeroCounts,
          isLoading: false,
          errorMessage: e.toString(),
          clearSelection: true,
        ),
      );
    }
  }

  List<LatLng> _geometryOf(NearbyLine line) {
    try {
      final polyline = dataSource?.geometryOf(line)?.polyline;
      if (polyline != null && polyline.isNotEmpty) return polyline;
    } catch (_) {
      // Fall through: a line with unreadable geometry still gets its marker.
    }
    return [line.nearestPoint];
  }
}
