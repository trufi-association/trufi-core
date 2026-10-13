import 'package:equatable/equatable.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

/// Minimum gap between two user-triggered ETA requests. Issue #1004 asks for
/// a 10–15 s client-side throttle so a tap-happy rider cannot flood the
/// telemetry backend.
const Duration defaultEtaRefreshCooldown = Duration(seconds: 12);

/// Lifecycle of the "next vehicle" lookup for the current plan.
enum VehicleEtaStatus {
  /// No plan with a transit route is loaded: nothing to show.
  idle,

  /// A request is in flight (previous estimates, if any, are kept).
  loading,

  /// The source answered with at least one estimate.
  ready,

  /// The source answered but no vehicle of the plan's routes is reporting.
  unavailable,

  /// The source could not be reached or answered garbage.
  error,
}

/// State of [VehicleEtaCubit]: the estimates of the current plan plus the
/// throttle gate for the manual refresh.
class VehicleEtaState extends Equatable {
  const VehicleEtaState({
    this.status = VehicleEtaStatus.idle,
    this.etasByRoute = const {},
    this.fetchedAt,
    this.nextAllowedAt,
    this.error,
    this.hasRequest = false,
  });

  final VehicleEtaStatus status;

  /// Soonest estimate per route, keyed by the prefix-stripped route id (see
  /// `stripGtfsFeedPrefix`); look up with [etaFor].
  final Map<String, VehicleEta> etasByRoute;

  /// `fetchedAt` of the last successful answer; kept while a refresh loads
  /// so the badge can show the previous value dimmed.
  final DateTime? fetchedAt;

  /// Throttle gate: refreshes before this instant are ignored. Null = no
  /// request was ever sent.
  final DateTime? nextAllowedAt;

  /// Last failure, for logs and tests; never rendered.
  final String? error;

  /// True once a plan with at least one identifiable transit route has been
  /// loaded — only then does a refresh button make sense.
  final bool hasRequest;

  /// Estimate for [routeGtfsId] with either spelling of the id (`1:1132`
  /// from OTP, `1132` from a bundled GTFS), or null.
  VehicleEta? etaFor(String routeGtfsId) =>
      etasByRoute[stripGtfsFeedPrefix(routeGtfsId)];

  /// Time left before a refresh is allowed; zero when the gate is open.
  Duration cooldownRemaining(DateTime now) {
    final gate = nextAllowedAt;
    if (gate == null) return Duration.zero;
    final remaining = gate.difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Whether a manual refresh at [now] would be sent.
  bool canRefreshAt(DateTime now) =>
      hasRequest &&
      status != VehicleEtaStatus.loading &&
      cooldownRemaining(now) == Duration.zero;

  /// Non-null semantics: a field is only replaced when given. To null a
  /// field, construct the state explicitly.
  VehicleEtaState copyWith({
    VehicleEtaStatus? status,
    Map<String, VehicleEta>? etasByRoute,
    DateTime? fetchedAt,
    DateTime? nextAllowedAt,
    String? error,
    bool? hasRequest,
  }) {
    return VehicleEtaState(
      status: status ?? this.status,
      etasByRoute: etasByRoute ?? this.etasByRoute,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      nextAllowedAt: nextAllowedAt ?? this.nextAllowedAt,
      error: error ?? this.error,
      hasRequest: hasRequest ?? this.hasRequest,
    );
  }

  @override
  List<Object?> get props => [
    status,
    etasByRoute,
    fetchedAt,
    nextAllowedAt,
    error,
    hasRequest,
  ];
}
