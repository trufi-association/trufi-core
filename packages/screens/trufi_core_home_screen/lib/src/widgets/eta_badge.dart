import 'package:flutter/material.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart';

import '../../l10n/home_screen_localizations.dart';
import '../models/vehicle_eta_state.dart';

/// What the badge shows, derived from the cubit status and the route's
/// estimate by [EtaBadge.kindFor].
enum EtaBadgeKind {
  /// Nothing rendered (no plan loaded).
  hidden,

  /// First request in flight, no previous value to show.
  loading,

  /// An estimate exists and is current.
  ready,

  /// An estimate exists but a refresh is in flight: shown dimmed.
  stale,

  /// The route has vehicles but none heads to the stop.
  noneNearby,

  /// The source failed or answered without an estimate for this route.
  unavailable,
}

typedef _LeadingBuilder = Widget Function(ColorScheme scheme);
typedef _LabelBuilder =
    String Function(HomeScreenLocalizations l10n, VehicleEta? eta);

/// Small outlined pill with the next-vehicle estimate of one route
/// ("Arrives in ~4 min"), its loading state, "No buses nearby right now" or
/// the "Live ETA unavailable" fallback (#1004). A route without live data
/// shows nothing. Presentational: feed it the cubit status and the
/// route's estimate; it never reads a cubit itself. Not interactive, so no
/// haptics.
class EtaBadge extends StatelessWidget {
  const EtaBadge({super.key, required this.status, this.eta, this.fetchedAt});

  final VehicleEtaStatus status;

  /// Estimate for the badge's route, if the source has one.
  final VehicleEta? eta;

  /// Time of the last successful answer, shown in the tooltip.
  final DateTime? fetchedAt;

  static const double _iconSize = 12;
  static const double _spinnerSize = 10;
  static const double _spinnerStroke = 1.5;
  static const double _gap = 4;
  static const double _radius = 999;
  static const double _borderAlpha = 0.4;
  static const double _fillAlpha = 0.08;
  static const double _staleOpacity = 0.6;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 3,
  );

  /// Kinds that carry a live estimate (primary colour, tooltip).
  static const Set<EtaBadgeKind> _liveKinds = {
    EtaBadgeKind.ready,
    EtaBadgeKind.stale,
  };

  /// Pure visual dispatch: idle and no live data hide; an estimate is shown
  /// (dimmed while a refresh loads); otherwise the first load spins, "none
  /// nearby" says so and anything else reads as unavailable.
  static EtaBadgeKind kindFor(VehicleEtaStatus status, VehicleEta? eta) {
    if (status == VehicleEtaStatus.idle ||
        status == VehicleEtaStatus.noLiveData) {
      return EtaBadgeKind.hidden;
    }
    if (eta != null) {
      return status == VehicleEtaStatus.loading
          ? EtaBadgeKind.stale
          : EtaBadgeKind.ready;
    }
    if (status == VehicleEtaStatus.loading) return EtaBadgeKind.loading;
    if (status == VehicleEtaStatus.noneNearby) return EtaBadgeKind.noneNearby;
    return EtaBadgeKind.unavailable;
  }

  static Widget _liveIcon(ColorScheme scheme) =>
      Icon(Icons.sensors_rounded, size: _iconSize, color: scheme.primary);

  static Widget _noLiveIcon(ColorScheme scheme) => Icon(
    Icons.sensors_off_rounded,
    size: _iconSize,
    color: scheme.onSurfaceVariant,
  );

  static final Map<EtaBadgeKind, _LeadingBuilder> _leadingByKind = {
    EtaBadgeKind.ready: _liveIcon,
    EtaBadgeKind.stale: _liveIcon,
    EtaBadgeKind.loading: (scheme) => SizedBox(
      width: _spinnerSize,
      height: _spinnerSize,
      child: CircularProgressIndicator(
        strokeWidth: _spinnerStroke,
        color: scheme.primary,
      ),
    ),
    EtaBadgeKind.noneNearby: _noLiveIcon,
    EtaBadgeKind.unavailable: _noLiveIcon,
  };

  // `eta!` is safe: kindFor only yields ready/stale when eta != null.
  static String _arrivesIn(HomeScreenLocalizations l10n, VehicleEta? eta) =>
      l10n.etaArrivesIn(eta!.minutes);

  static final Map<EtaBadgeKind, _LabelBuilder> _labelByKind = {
    EtaBadgeKind.ready: _arrivesIn,
    EtaBadgeKind.stale: _arrivesIn,
    EtaBadgeKind.loading: (l10n, _) => l10n.etaLoading,
    EtaBadgeKind.noneNearby: (l10n, _) => l10n.etaNoneNearby,
    EtaBadgeKind.unavailable: (l10n, _) => l10n.etaUnavailable,
  };

  @override
  Widget build(BuildContext context) {
    final kind = kindFor(status, eta);
    if (kind == EtaBadgeKind.hidden) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = HomeScreenLocalizations.of(context);
    final live = _liveKinds.contains(kind);
    final foreground = live ? scheme.primary : scheme.onSurfaceVariant;

    Widget badge = Container(
      padding: _padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(
          color: live
              ? scheme.primary.withValues(alpha: _borderAlpha)
              : scheme.outlineVariant,
        ),
        color: live ? scheme.primary.withValues(alpha: _fillAlpha) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _leadingByKind[kind]!(scheme),
          const SizedBox(width: _gap),
          // Narrow cards (320 dp with a transfer chip and "Kommt in ~12
          // Min.") would ellipsize mid-word; scaling the label down keeps
          // the minutes readable.
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                _labelByKind[kind]!(l10n, eta),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
    if (kind == EtaBadgeKind.stale) {
      badge = Opacity(opacity: _staleOpacity, child: badge);
    }
    final updatedAt = fetchedAt;
    if (live && updatedAt != null) {
      // Sources may stamp `fetchedAt` in UTC (ISO `...Z`, epoch): render
      // the rider's wall clock, never the source's.
      badge = Tooltip(
        message: l10n.etaUpdated(formatClockTime(context, updatedAt.toLocal())),
        child: badge,
      );
    }
    return badge;
  }
}
