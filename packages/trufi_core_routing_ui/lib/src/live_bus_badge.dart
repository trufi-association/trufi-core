import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;

/// Small pulsing wifi-style indicator shown on transit leg UI when the leg's
/// route currently has live vehicle data flowing.
///
/// Consumers wire this up by providing a [RealtimeVehiclesProvider] and the
/// widget polls [provider.hasDataForRoute] reactively.
class LiveBusBadge extends StatefulWidget {
  const LiveBusBadge({
    super.key,
    required this.provider,
    required this.routeGtfsId,
    this.color = const Color(0xFF22C55E),
    this.size = 14,
  });

  /// Builder that returns [LiveBusBadge] only when the provider actually has
  /// data for the given route, otherwise a [SizedBox.shrink].
  static Widget whenLive({
    required RealtimeVehiclesProvider? provider,
    required routing.Leg leg,
    Color color = const Color(0xFF22C55E),
    double size = 14,
  }) {
    if (provider == null || !leg.transitLeg) {
      return const SizedBox.shrink();
    }
    final rid = leg.route?.gtfsId;
    if (rid == null || rid.isEmpty) {
      return const SizedBox.shrink();
    }
    return _ReactiveLiveBusBadge(
      provider: provider,
      routeGtfsId: rid,
      color: color,
      size: size,
    );
  }

  final RealtimeVehiclesProvider provider;
  final String routeGtfsId;
  final Color color;
  final double size;

  @override
  State<LiveBusBadge> createState() => _LiveBusBadgeState();
}

class _LiveBusBadgeState extends State<LiveBusBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final t = _pulse.value;
        final scale = 0.8 + (t * 0.4);
        final opacity = (1 - t).clamp(0.0, 1.0);
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Container(
                width: widget.size * 0.55,
                height: widget.size * 0.55,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Rebuilds on provider stream ticks; only shows the badge while there is
/// at least one vehicle reported for [routeGtfsId].
class _ReactiveLiveBusBadge extends StatefulWidget {
  const _ReactiveLiveBusBadge({
    required this.provider,
    required this.routeGtfsId,
    required this.color,
    required this.size,
  });

  final RealtimeVehiclesProvider provider;
  final String routeGtfsId;
  final Color color;
  final double size;

  @override
  State<_ReactiveLiveBusBadge> createState() => _ReactiveLiveBusBadgeState();
}

class _ReactiveLiveBusBadgeState extends State<_ReactiveLiveBusBadge> {
  late bool _live;
  StreamSubscription<List<VehiclePosition>>? _sub;

  @override
  void initState() {
    super.initState();
    _live = widget.provider.hasDataForRoute(widget.routeGtfsId);
    _sub = widget.provider.positionsStream.listen((_) {
      final next = widget.provider.hasDataForRoute(widget.routeGtfsId);
      if (mounted && next != _live) {
        setState(() => _live = next);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_live) return const SizedBox.shrink();
    return LiveBusBadge(
      provider: widget.provider,
      routeGtfsId: widget.routeGtfsId,
      color: widget.color,
      size: widget.size,
    );
  }
}
