import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;
import 'package:trufi_core_utils/trufi_core_utils.dart';

/// A trip shaped like Sana'a's (trufi-sanaa#18, #1059): a walk to the line,
/// a bus leg whose 44 "stops" are way nodes ~27 m apart, and a walk to the
/// destination. The line turns a corner after node 20, so the straight line
/// from the boarding stop to the alighting one (~0.9 km) is visibly shorter
/// than the ride (~1.2 km).
class SanaaTrip {
  SanaaTrip._();

  static const nodeCount = 44;
  static const _step = 0.00025;

  static const origin = LatLng(15.35, 44.1986);
  static const boarding = LatLng(15.35, 44.2);
  static const destination = LatLng(15.35625, 44.2068);

  /// Way node [i] (1-based): 20 going east, the rest going north.
  static LatLng node(int i) => i <= 20
      ? LatLng(15.35, 44.2 + _step * i)
      : LatLng(15.35 + _step * (i - 20), 44.2 + _step * 20);

  static final alighting = node(nodeCount + 1);

  static final nodes = [for (var i = 1; i <= nodeCount; i++) node(i)];

  /// The bus line, boarding to alighting.
  static final line = [boarding, ...nodes, alighting];

  static String nodeName(int i) => 'Way node $i';

  static final _day = DateTime(2026, 11, 17, 9);

  static routing.Place place(String name, LatLng position) => routing.Place(
    name: name,
    lat: position.latitude,
    lon: position.longitude,
    stopId: name,
  );

  static routing.Leg walkLeg({
    required routing.Place? from,
    required routing.Place? to,
    required List<LatLng> points,
    required int startMinute,
    required int minutes,
  }) => routing.Leg(
    mode: 'WALK',
    startTime: _day.add(Duration(minutes: startMinute)),
    endTime: _day.add(Duration(minutes: startMinute + minutes)),
    duration: Duration(minutes: minutes),
    distance: minutes * 80.0,
    transitLeg: false,
    decodedPoints: points,
    fromPlace: from,
    toPlace: to,
  );

  static routing.Leg busLeg({
    required routing.Place? from,
    required routing.Place? to,
    required List<LatLng> points,
    required List<routing.Place>? intermediatePlaces,
    required int startMinute,
    required int minutes,
    String shortName = '7',
    String? longName = 'Line 7',
    String? color = '1E88E5',
  }) => routing.Leg(
    mode: 'BUS',
    startTime: _day.add(Duration(minutes: startMinute)),
    endTime: _day.add(Duration(minutes: startMinute + minutes)),
    duration: Duration(minutes: minutes),
    distance: minutes * 300.0,
    transitLeg: true,
    decodedPoints: points,
    route: routing.Route(
      gtfsId: '1:$shortName',
      shortName: shortName,
      longName: longName,
      color: color,
    ),
    shortName: shortName,
    routeLongName: longName,
    fromPlace: from,
    toPlace: to,
    intermediatePlaces: intermediatePlaces,
  );

  static routing.Itinerary itineraryOf(List<routing.Leg> legs) {
    final duration = legs.fold(Duration.zero, (sum, leg) => sum + leg.duration);
    return routing.Itinerary(
      legs: legs,
      startTime: _day,
      endTime: _day.add(duration),
      walkTime: legs
          .where((leg) => !leg.transitLeg)
          .fold(Duration.zero, (sum, leg) => sum + leg.duration),
      duration: duration,
      walkDistance: 0,
    );
  }

  /// Walk (2 min) → bus 7 over the 44 way nodes (30 min) → walk (3 min).
  static routing.Itinerary itinerary() => itineraryOf([
    walkLeg(
      from: place('Home', origin),
      to: place('Boarding stop', boarding),
      points: [origin, boarding],
      startMinute: 0,
      minutes: 2,
    ),
    busLeg(
      from: place('Boarding stop', boarding),
      to: place('Alighting stop', alighting),
      points: line,
      intermediatePlaces: [
        for (var i = 1; i <= nodeCount; i++) place(nodeName(i), node(i)),
      ],
      startMinute: 2,
      minutes: 30,
    ),
    walkLeg(
      from: place('Alighting stop', alighting),
      to: place('University', destination),
      points: [alighting, destination],
      startMinute: 32,
      minutes: 3,
    ),
  ]);

  /// The fixes of a rider doing the whole trip: the origin, halfway to the
  /// line, every point of the line, halfway to the destination, the
  /// destination.
  static final track = [
    origin,
    _midpoint(origin, boarding),
    ...line,
    _midpoint(alighting, destination),
    destination,
  ];

  static LatLng _midpoint(LatLng a, LatLng b) =>
      LatLng((a.latitude + b.latitude) / 2, (a.longitude + b.longitude) / 2);
}

/// A trip on two lines (#1059): a walk to line 7, ten way nodes going east
/// to the stop where it is left, line 12 over ten more nodes going north,
/// and a walk to the destination.
///
/// With [walkAtTransfer] line 12 is boarded at another stop, ~66 m further
/// north, and a walking leg joins the two. Without it both lines share the
/// stop and no leg sits between them, which is how `TrufiPlannerProvider`
/// builds a transfer at one stop.
class TransferTrip {
  TransferTrip({required this.walkAtTransfer});

  final bool walkAtTransfer;

  static const nodesPerLine = 10;
  static const _step = 0.00025;

  static const origin = LatLng(15.35, 44.1986);
  static const boardA = LatLng(15.35, 44.2);

  /// Way node [i] of line 7 (1-based), going east.
  static LatLng nodeA(int i) => LatLng(15.35, 44.2 + _step * i);

  static final alightA = nodeA(nodesPerLine + 1);

  late final LatLng boardB = walkAtTransfer
      ? LatLng(15.3506, alightA.longitude)
      : alightA;

  /// Way node [i] of line 12 (1-based), going north.
  LatLng nodeB(int i) => LatLng(boardB.latitude + _step * i, boardB.longitude);

  late final LatLng alightB = nodeB(nodesPerLine + 1);

  late final LatLng destination = LatLng(
    alightB.latitude,
    alightB.longitude + 0.00175,
  );

  late final List<LatLng> lineA = [
    boardA,
    for (var i = 1; i <= nodesPerLine; i++) nodeA(i),
    alightA,
  ];

  late final List<LatLng> lineB = [
    boardB,
    for (var i = 1; i <= nodesPerLine; i++) nodeB(i),
    alightB,
  ];

  /// Walk → bus 7 → (walk) → bus 12 → walk. The stop where line 7 is left is
  /// "Alight A" either way; without the walk it is also where line 12 is
  /// boarded.
  routing.Itinerary itinerary() => SanaaTrip.itineraryOf([
    SanaaTrip.walkLeg(
      from: SanaaTrip.place('Home', origin),
      to: SanaaTrip.place('Board A', boardA),
      points: [origin, boardA],
      startMinute: 0,
      minutes: 2,
    ),
    SanaaTrip.busLeg(
      from: SanaaTrip.place('Board A', boardA),
      to: SanaaTrip.place('Alight A', alightA),
      points: lineA,
      intermediatePlaces: [
        for (var i = 1; i <= nodesPerLine; i++)
          SanaaTrip.place('A node $i', nodeA(i)),
      ],
      startMinute: 2,
      minutes: 10,
    ),
    if (walkAtTransfer)
      SanaaTrip.walkLeg(
        from: SanaaTrip.place('Alight A', alightA),
        to: SanaaTrip.place('Board B', boardB),
        points: [alightA, boardB],
        startMinute: 12,
        minutes: 1,
      ),
    SanaaTrip.busLeg(
      from: SanaaTrip.place(walkAtTransfer ? 'Board B' : 'Alight A', boardB),
      to: SanaaTrip.place('Alight B', alightB),
      points: lineB,
      intermediatePlaces: [
        for (var i = 1; i <= nodesPerLine; i++)
          SanaaTrip.place('B node $i', nodeB(i)),
      ],
      startMinute: 13,
      minutes: 10,
      shortName: '12',
      longName: 'Line 12',
      color: 'E53935',
    ),
    SanaaTrip.walkLeg(
      from: SanaaTrip.place('Alight B', alightB),
      to: SanaaTrip.place('University', destination),
      points: [alightB, destination],
      startMinute: 23,
      minutes: 3,
    ),
  ]);

  /// The fixes of a rider doing the whole trip, one every ~9 m: dense
  /// enough to see at which point each text of the instruction changes.
  late final List<LatLng> track = fixesAlong([
    origin,
    ...lineA,
    ...lineB,
    destination,
  ]);
}

/// The points of [path] and, between each two, as many evenly spaced ones
/// as it takes to have a fix every [stepMeters] or less.
List<LatLng> fixesAlong(List<LatLng> path, {double stepMeters = 9}) {
  const distance = Distance(roundResult: false);
  final fixes = [path.first];
  for (var i = 1; i < path.length; i++) {
    final from = path[i - 1];
    final to = path[i];
    final steps = (distance(from, to) / stepMeters).ceil();
    for (var k = 1; k <= steps; k++) {
      fixes.add(
        LatLng(
          from.latitude + (to.latitude - from.latitude) * k / steps,
          from.longitude + (to.longitude - from.longitude) * k / steps,
        ),
      );
    }
  }
  return fixes;
}

/// A [LocationService] with the permission granted and no GPS behind it:
/// the test moves the rider with [moveTo]. Distances are the real ones.
class FakeLocationService extends LocationService {
  FakeLocationService({LatLng? initial})
    : _location = initial == null ? null : _result(initial);

  LocationResult? _location;

  static LocationResult _result(LatLng position, {double? accuracy}) =>
      LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: accuracy,
      );

  @override
  LocationResult? get currentLocation => _location;

  @override
  Future<LocationPermissionStatus> requestPermission() async =>
      LocationPermissionStatus.granted;

  @override
  Future<bool> startTracking({
    int distanceFilter = 10,
    Object? accuracy,
  }) async => true;

  @override
  Future<void> stopTracking() async {}

  /// A new fix at [position]; listeners hear about it synchronously.
  void moveTo(LatLng position, {double? accuracy}) {
    _location = _result(position, accuracy: accuracy);
    notifyListeners();
  }

  /// Meters from [from] along [path], point by point.
  double metersAlong(LatLng from, List<LatLng> path) {
    var meters = 0.0;
    var previous = from;
    for (final point in path) {
      meters += distanceBetween(
        previous.latitude,
        previous.longitude,
        point.latitude,
        point.longitude,
      );
      previous = point;
    }
    return meters;
  }
}

/// Just enough of a [MapEngineManager] for
/// `NavigationScreen.showFromItinerary`, which only asks for the current
/// engine (the real one reads SharedPreferences on construction).
class FakeMapEngineManager extends Fake implements MapEngineManager {
  @override
  ITrufiMapEngine get currentEngine => _FakeEngine();
}

class _FakeEngine extends ITrufiMapEngine {
  @override
  String get id => 'fake';
  @override
  String get name => 'Fake';
  @override
  String get description => 'Fake map';

  @override
  Widget buildMap({
    TrufiMapController? controller,
    required TrufiCameraPosition initialCamera,
    TrufiCameraPosition? camera,
    ValueChanged<TrufiCameraPosition>? onCameraChanged,
    void Function(LatLng)? onMapClick,
    void Function(LatLng)? onMapLongClick,
    List<TrufiLayer> layers = const [],
    List<WidgetMarker> widgetMarkers = const [],
  }) => const SizedBox.expand();
}
