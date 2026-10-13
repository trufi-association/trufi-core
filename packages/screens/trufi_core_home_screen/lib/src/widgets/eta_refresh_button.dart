import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/home_screen_localizations.dart';
import '../cubit/vehicle_eta_cubit.dart';
import '../models/vehicle_eta_state.dart';

/// Manual refresh of the vehicle ETAs (#1004): re-asks the telemetry source
/// without re-planning the trip.
///
/// Hidden when no [VehicleEtaCubit] is provided (feature off) or nothing is
/// loaded yet; disabled — with a countdown in the tooltip — while the
/// throttle cooldown runs or a request is in flight. Re-enables by itself:
/// a one-second ticker runs only while a countdown is showing.
class EtaRefreshButton extends StatefulWidget {
  const EtaRefreshButton({
    super.key,
    this.compact = false,
    this.padding = EdgeInsets.zero,
    this.now,
  });

  /// True = 28 px circle matching the results sheet's share button; false =
  /// a regular filled icon button like the side panel's.
  final bool compact;

  /// Applied only when the button is visible, so a hidden button changes
  /// nothing in the row.
  final EdgeInsetsGeometry padding;

  /// Injectable clock for tests; defaults to [DateTime.now].
  final DateTime Function()? now;

  @override
  State<EtaRefreshButton> createState() => _EtaRefreshButtonState();
}

class _EtaRefreshButtonState extends State<EtaRefreshButton> {
  static const double _iconSize = 18;
  static const double _spinnerSize = 14;
  static const double _spinnerStroke = 2;
  static const double _compactSize = 28;
  static const double _backgroundAlpha = 0.1;
  static const double _disabledForegroundAlpha = 0.6;
  static const Duration _tick = Duration(seconds: 1);

  VehicleEtaCubit? _cubit;
  Timer? _ticker;

  DateTime _now() => (widget.now ?? DateTime.now)();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // `read`, not `watch`: the BlocConsumer below scopes the rebuilds.
    final cubit = context.read<VehicleEtaCubit?>();
    if (identical(cubit, _cubit)) return;
    _cubit = cubit;
    _syncTicker(cubit?.state);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  /// Runs the ticker only while a countdown is showing; a cubit emission
  /// covers every other transition.
  void _syncTicker(VehicleEtaState? state) {
    final wanted =
        state != null &&
        state.hasRequest &&
        state.cooldownRemaining(_now()) > Duration.zero;
    if (wanted == (_ticker != null)) return;
    if (wanted) {
      _ticker = Timer.periodic(_tick, _onTick);
    } else {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  void _onTick(Timer _) {
    if (!mounted) return;
    setState(() {});
    _syncTicker(_cubit?.state);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = _cubit;
    if (cubit == null) return const SizedBox.shrink();
    return BlocConsumer<VehicleEtaCubit, VehicleEtaState>(
      bloc: cubit,
      listener: (_, state) => _syncTicker(state),
      builder: (context, state) {
        if (!state.hasRequest) return const SizedBox.shrink();
        final now = _now();
        final enabled = state.canRefreshAt(now);
        final remainingSeconds =
            (state.cooldownRemaining(now).inMilliseconds /
                    Duration.millisecondsPerSecond)
                .ceil();
        final loading = state.status == VehicleEtaStatus.loading;
        final l10n = HomeScreenLocalizations.of(context);
        final scheme = Theme.of(context).colorScheme;
        return Padding(
          padding: widget.padding,
          child: IconButton.filled(
            icon: loading
                ? SizedBox(
                    width: _spinnerSize,
                    height: _spinnerSize,
                    child: CircularProgressIndicator(
                      strokeWidth: _spinnerStroke,
                      color: scheme.onSurfaceVariant,
                    ),
                  )
                : const Icon(Icons.refresh_rounded, size: _iconSize),
            tooltip: enabled
                ? l10n.etaRefresh
                : l10n.etaRefreshCooldown(remainingSeconds),
            onPressed: enabled
                ? () {
                    HapticFeedback.lightImpact();
                    cubit.refresh();
                  }
                : null,
            padding: widget.compact ? EdgeInsets.zero : null,
            constraints: widget.compact
                ? const BoxConstraints.tightFor(
                    width: _compactSize,
                    height: _compactSize,
                  )
                : null,
            style: IconButton.styleFrom(
              backgroundColor: scheme.primary.withValues(
                alpha: _backgroundAlpha,
              ),
              foregroundColor: scheme.primary,
              disabledBackgroundColor: scheme.surfaceContainerHighest,
              disabledForegroundColor: scheme.onSurfaceVariant.withValues(
                alpha: _disabledForegroundAlpha,
              ),
              // The sheet header is a 28 px row: no 48 px tap-target halo.
              tapTargetSize: widget.compact
                  ? MaterialTapTargetSize.shrinkWrap
                  : null,
            ),
          ),
        );
      },
    );
  }
}
