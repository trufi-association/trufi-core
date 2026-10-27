import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

/// One-shot loader of a vehicle fleet, e.g. `OtpVehiclePositionsProvider.fetchOnce`.
/// One-shot loader of a vehicle fleet, e.g. `OtpVehiclePositionsProvider.fetchOnce`;
/// [routeIds] lets it ask the backend for the requested routes only (#1017).
typedef VehicleSnapshotLoader =
    Future<List<VehiclePosition>> Function({Set<String>? routeIds});

/// [VehicleEtaProvider] derived from live vehicle positions: for every
/// requested route, the soonest-arriving reporting vehicle — not the
/// nearest one: a close bus crawling loses to a farther one at speed —
/// by its straight-line distance to the route's boarding point — the rider's origin when the request
/// carries none ([VehicleEtaRequest.pointFor]) — over its reported speed
/// (when plausible) or over [averageSpeedKmh].
///
/// Makes the ETA badges work today wherever a GTFS-RT feed exists (OTP 2.x
/// `vehiclePositions`); an external telemetry client implements the same
/// [VehicleEtaProvider] interface and plugs into the same UI.
///
/// MVP simplifications, on purpose: direction and route geometry are
/// ignored, so a vehicle driving away from the origin still yields an ETA.
/// Deterministic given [now], which tests inject.
class RealtimeVehiclesEtaProvider implements VehicleEtaProvider {
  RealtimeVehiclesEtaProvider({
    required this.vehicles,
    this.snapshotLoader,
    this.averageSpeedKmh = defaultAverageSpeedKmh,
    this.maxDistanceMeters = defaultMaxDistanceMeters,
    this.maxVehicleAge = defaultMaxVehicleAge,
    DateTime Function()? now,
  }) : assert(averageSpeedKmh > 0, 'averageSpeedKmh must be positive'),
       _now = now ?? DateTime.now;

  /// Typical urban bus speed including stops; used when a vehicle reports
  /// no speed or an implausible one.
  static const double defaultAverageSpeedKmh = 15;

  /// Vehicles farther than this are not "approaching" in any useful sense.
  static const double defaultMaxDistanceMeters = 10000;

  /// Reports older than this are stale: the vehicle is no longer where the
  /// feed says it is.
  static const Duration defaultMaxVehicleAge = Duration(minutes: 5);

  /// Reported speeds (m/s on the GTFS-RT wire) outside this window are
  /// treated as noise: below ~3.6 km/h the bus is stopped at a light or the
  /// GPS is drifting, above 108 km/h it is a sensor glitch.
  static const double minPlausibleSpeedMps = 1.0;
  static const double maxPlausibleSpeedMps = 30.0;

  /// Diagnostic tag written into [VehicleEtaSnapshot.source].
  static const String source = 'realtime_vehicles';

  static const double _mpsPerKmh = 1 / 3.6;

  final RealtimeVehiclesProvider vehicles;

  /// Optional one-shot loader used instead of [RealtimeVehiclesProvider.latest]
  /// (e.g. `OtpVehiclePositionsProvider.fetchOnce`), so the estimate is
  /// fresh even while the "Live buses" layer — and its polling — is off.
  /// Null → the current snapshot of [vehicles] is used as is.
  final VehicleSnapshotLoader? snapshotLoader;

  final double averageSpeedKmh;
  final double maxDistanceMeters;
  final Duration maxVehicleAge;
  final DateTime Function() _now;

  /// Pure estimate: `distance / speed`, where speed is the reported one when
  /// plausible, else [averageSpeedKmh]. Public for tests.
  Duration estimate({
    required double distanceMeters,
    double? reportedSpeedMps,
  }) {
    final plausible =
        reportedSpeedMps != null &&
        reportedSpeedMps >= minPlausibleSpeedMps &&
        reportedSpeedMps <= maxPlausibleSpeedMps;
    final speedMps = plausible
        ? reportedSpeedMps
        : averageSpeedKmh * _mpsPerKmh;
    return Duration(seconds: (distanceMeters / speedMps).round());
  }

  @override
  Future<VehicleEtaSnapshot> fetchEtas(VehicleEtaRequest request) async {
    final positions = await _loadPositions(request);
    final now = _now();
    final etas = <VehicleEta>[];
    for (final routeId in request.routeIds) {
      final best = _bestEtaForRoute(
        routeId,
        positions,
        request.pointFor(routeId),
        now,
      );
      if (best != null) etas.add(best);
    }
    return VehicleEtaSnapshot(etas: etas, fetchedAt: now, source: source);
  }

  Future<List<VehiclePosition>> _loadPositions(
    VehicleEtaRequest request,
  ) async {
    final loader = snapshotLoader;
    if (loader == null) return vehicles.latest;
    try {
      return await loader(routeIds: request.routeIds);
    } catch (e) {
      throw VehicleEtaException('vehicle snapshot failed', cause: e);
    }
  }

  /// Soonest estimate among the reporting vehicles of [routeId] (matched
  /// feed-agnostically, like `vehiclesForRoute`) to reach [target] — the
  /// route's boarding stop, or the rider's origin — or null when none is
  /// fresh and close enough.
  VehicleEta? _bestEtaForRoute(
    String routeId,
    List<VehiclePosition> positions,
    TrufiLatLng target,
    DateTime now,
  ) {
    final want = stripGtfsFeedPrefix(routeId);
    VehicleEta? best;
    for (final vehicle in positions) {
      final vehicleRoute = vehicle.routeId;
      if (vehicleRoute == null || stripGtfsFeedPrefix(vehicleRoute) != want) {
        continue;
      }
      final reportedAt = vehicle.timestamp;
      if (reportedAt != null && now.difference(reportedAt) > maxVehicleAge) {
        continue;
      }
      final distance = vehicle.position.distanceTo(target);
      if (distance > maxDistanceMeters) continue;
      final eta = estimate(
        distanceMeters: distance,
        reportedSpeedMps: vehicle.speed,
      );
      if (best == null || eta < best.eta) {
        best = VehicleEta(
          routeId: routeId,
          eta: eta,
          timestamp: reportedAt ?? now,
          vehicleId: vehicle.vehicleId,
          distanceMeters: distance,
        );
      }
    }
    return best;
  }
}
