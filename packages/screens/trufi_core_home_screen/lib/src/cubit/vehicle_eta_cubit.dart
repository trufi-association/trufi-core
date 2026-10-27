import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;

import '../models/vehicle_eta_state.dart';

/// Route key the ETA lookup uses for [leg]: `route.gtfsId`, else
/// `route.id`, else null. Empty strings count as missing.
String? etaRouteKeyForLeg(routing.Leg leg) {
  final route = leg.route;
  if (route == null) return null;
  final gtfsId = route.gtfsId;
  if (gtfsId != null && gtfsId.isNotEmpty) return gtfsId;
  final id = route.id;
  if (id != null && id.isNotEmpty) return id;
  return null;
}

/// Route key of the itinerary's FIRST boarding vehicle only — on a
/// multi-leg ride the rider waits for the initial bus, the connections come
/// later (issue #1004, "transfer/multi-leg support").
String? etaRouteKeyForItinerary(routing.Itinerary itinerary) {
  final leg = itinerary.firstTransitLeg;
  return leg == null ? null : etaRouteKeyForLeg(leg);
}

/// One request for the whole plan: every itinerary's first transit route
/// (raw ids, as the planner reports them), their boarding stop ids as a
/// hint and, per route, the boarding stop's coordinates (`leg.fromPlace`),
/// so a source answers "when does the bus reach my stop" rather than "when
/// does it reach me". When two itineraries board the same route at
/// different stops the first one wins — the planner lists them by
/// preference. Null when no itinerary has an identifiable transit route
/// (walk-only plans) — nothing to ask for.
VehicleEtaRequest? buildVehicleEtaRequest(
  routing.Plan plan,
  TrufiLatLng origin,
) {
  final routeIds = <String>{};
  final stopIds = <String>{};
  final boardingPoints = <String, TrufiLatLng>{};
  for (final itinerary in plan.itineraries ?? const <routing.Itinerary>[]) {
    final leg = itinerary.firstTransitLeg;
    if (leg == null) continue;
    final routeKey = etaRouteKeyForLeg(leg);
    if (routeKey == null) continue;
    routeIds.add(routeKey);
    final boarding = leg.fromPlace;
    if (boarding == null) continue;
    final stopId = boarding.stopId;
    if (stopId != null && stopId.isNotEmpty) stopIds.add(stopId);
    boardingPoints.putIfAbsent(
      routeKey,
      () => TrufiLatLng(boarding.lat, boarding.lon),
    );
  }
  if (routeIds.isEmpty) return null;
  return VehicleEtaRequest(
    origin: origin,
    routeIds: routeIds,
    stopIds: stopIds.isEmpty ? null : stopIds,
    boardingPoints: boardingPoints.isEmpty ? null : boardingPoints,
  );
}

/// Loads "next vehicle" estimates for the current plan from a
/// [VehicleEtaProvider] and throttles the manual refresh (#1004).
///
/// On-demand snapshots only: one request per new plan or refresh, never a
/// timer. [loadForPlan] always fetches (a new plan means new routes);
/// [refresh] re-sends the stored request and is a no-op while a request is
/// in flight or the [cooldown] runs; [clear] forgets everything. Answers of
/// superseded requests are dropped, so a late reply never overwrites a
/// newer plan's badges. The clock is injectable for tests.
class VehicleEtaCubit extends Cubit<VehicleEtaState> {
  VehicleEtaCubit({
    VehicleEtaProvider? provider,
    this.cooldown = defaultEtaRefreshCooldown,
    DateTime Function()? now,
  }) : _provider = provider,
       _now = now ?? DateTime.now,
       super(const VehicleEtaState());

  VehicleEtaProvider? _provider;

  /// The telemetry source in use, if any. Without one the cubit stays idle
  /// and the badges hide (#1018): the home hands it the selected engine's
  /// provider and swaps it on engine change ([useProvider]).
  VehicleEtaProvider? get provider => _provider;

  routing.Plan? _lastPlan;
  TrufiLatLng? _lastOrigin;

  /// Switches the telemetry source. Null clears the estimates and hides the
  /// badges; a new source re-asks for the last plan so the badges follow
  /// the engine the rider just picked.
  void useProvider(VehicleEtaProvider? next) {
    if (identical(next, _provider)) return;
    _provider = next;
    final plan = _lastPlan;
    final origin = _lastOrigin;
    if (next == null || plan == null || origin == null) {
      _reset();
      return;
    }
    loadForPlan(plan, origin);
  }

  /// Minimum gap between two requests started by the user.
  final Duration cooldown;

  final DateTime Function() _now;

  VehicleEtaRequest? _lastRequest;

  /// Bumped by every load and clear; a reply whose id is stale is ignored.
  int _requestId = 0;

  /// Asks the provider for the first boarding vehicle of every itinerary of
  /// [plan] at [origin]. Walk-only plans reset the cubit without a request.
  Future<void> loadForPlan(routing.Plan plan, TrufiLatLng origin) {
    _lastPlan = plan;
    _lastOrigin = origin;
    final request = buildVehicleEtaRequest(plan, origin);
    if (request == null || _provider == null) {
      _reset();
      return Future.value();
    }
    return _fetch(request);
  }

  /// Re-sends the current plan's request. Never re-plans; silently ignored
  /// unless [VehicleEtaState.canRefreshAt] holds (nothing loaded, a request
  /// in flight, or the cooldown still running).
  Future<void> refresh() {
    final request = _lastRequest;
    if (request == null || !state.canRefreshAt(_now())) return Future.value();
    return _fetch(request);
  }

  /// Forgets the plan and its estimates; any in-flight answer is dropped.
  void clear() {
    _lastPlan = null;
    _lastOrigin = null;
    _reset();
  }

  /// Drops the estimates and any in-flight reply; keeps the last plan so a
  /// later source ([useProvider]) can ask for it again.
  void _reset() {
    _requestId++;
    _lastRequest = null;
    emit(const VehicleEtaState());
  }

  Future<void> _fetch(VehicleEtaRequest request) async {
    final id = ++_requestId;
    _lastRequest = request;
    // The gate is armed when the request STARTS, so a slow backend cannot
    // be hammered by taps while it is still answering.
    emit(
      VehicleEtaState(
        status: VehicleEtaStatus.loading,
        etasByRoute: state.etasByRoute,
        fetchedAt: state.fetchedAt,
        nextAllowedAt: _now().add(cooldown),
        hasRequest: true,
      ),
    );
    final provider = _provider;
    if (provider == null) {
      _reset();
      return;
    }
    final VehicleEtaSnapshot snapshot;
    try {
      snapshot = await provider.fetchEtas(request);
    } catch (e) {
      if (isClosed || id != _requestId) return;
      emit(
        state.copyWith(
          status: VehicleEtaStatus.error,
          etasByRoute: const {},
          error: e.toString(),
        ),
      );
      return;
    }
    if (isClosed || id != _requestId) return;
    final etas = snapshot.bestEtaByRoute;
    emit(
      VehicleEtaState(
        status: etas.isEmpty
            ? VehicleEtaStatus.unavailable
            : VehicleEtaStatus.ready,
        etasByRoute: etas,
        fetchedAt: snapshot.fetchedAt,
        nextAllowedAt: state.nextAllowedAt,
        hasRequest: true,
      ),
    );
  }
}
