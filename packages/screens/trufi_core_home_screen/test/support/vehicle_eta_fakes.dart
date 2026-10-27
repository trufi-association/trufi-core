import 'dart:async';

import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;

/// Shared fixtures for the #1004 vehicle-ETA tests (cubit, badge, refresh
/// button, card). Not a test file: no `_test` suffix.

/// Cochabamba, Plaza 14 de Septiembre.
const etaOrigin = TrufiLatLng(-17.3936, -66.1570);

/// Fixed "now" every fixture starts from.
final etaT0 = DateTime(2026, 10, 13, 10, 30);

/// Scripted [VehicleEtaProvider]: records every request, answers through
/// [answer], throws [failure] when set, or parks the call on [gate] so a
/// test can control when (and whether) the reply lands.
class FakeVehicleEtaProvider implements VehicleEtaProvider {
  final List<VehicleEtaRequest> requests = [];

  int get calls => requests.length;

  Completer<VehicleEtaSnapshot>? gate;
  Object? failure;
  DateTime fetchedAt = etaT0;
  List<VehicleEta> Function(VehicleEtaRequest request) answer = (_) => const [];

  @override
  Future<VehicleEtaSnapshot> fetchEtas(VehicleEtaRequest request) async {
    requests.add(request);
    final pending = gate;
    if (pending != null) return pending.future;
    final error = failure;
    if (error != null) throw error;
    return VehicleEtaSnapshot(etas: answer(request), fetchedAt: fetchedAt);
  }
}

VehicleEta eta(String routeId, int seconds) => VehicleEta(
  routeId: routeId,
  eta: Duration(seconds: seconds),
  timestamp: etaT0,
);

routing.Place stop(String id, {double lat = -17.39, double lon = -66.15}) =>
    routing.Place(name: id, lat: lat, lon: lon, stopId: id);

routing.Leg walkLeg() => routing.Leg(
  mode: 'WALK',
  startTime: etaT0,
  endTime: etaT0.add(const Duration(minutes: 5)),
  duration: const Duration(minutes: 5),
  distance: 400,
  transitLeg: false,
);

/// Transit leg of route [name]; [gtfsId] defaults to `1:<name>` (OTP
/// spelling), [stopId] to `s<name>`; [stopLat]/[stopLon] place the boarding
/// stop (null [stopId] = no `fromPlace` at all).
routing.Leg busLeg(
  String name, {
  String? gtfsId = '',
  String? id,
  String? stopId = '',
  double stopLat = -17.39,
  double stopLon = -66.15,
}) => routing.Leg(
  mode: 'BUS',
  startTime: etaT0.add(const Duration(minutes: 5)),
  endTime: etaT0.add(const Duration(minutes: 35)),
  duration: const Duration(minutes: 30),
  distance: 5000,
  transitLeg: true,
  route: routing.Route(
    gtfsId: gtfsId == '' ? '1:$name' : gtfsId,
    id: id,
    shortName: name,
  ),
  shortName: name,
  fromPlace: stopId == null
      ? null
      : stop(stopId == '' ? 's$name' : stopId, lat: stopLat, lon: stopLon),
);

routing.Itinerary itinerary(List<routing.Leg> legs) => routing.Itinerary(
  legs: legs,
  startTime: etaT0,
  endTime: etaT0.add(const Duration(hours: 1)),
  walkTime: const Duration(minutes: 5),
  duration: const Duration(hours: 1),
  walkDistance: 400,
);

/// [walk → A → B], [walk → C], [walk]: the ETA request must cover A and C
/// only (first boarding vehicle of each ride).
routing.Plan threeRidesPlan() => routing.Plan(
  itineraries: [
    itinerary([walkLeg(), busLeg('A'), busLeg('B')]),
    itinerary([walkLeg(), busLeg('C')]),
    itinerary([walkLeg()]),
  ],
);
