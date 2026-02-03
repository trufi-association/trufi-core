import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:trufi_core_utils/overlay_manager.dart';

/// Widget that renders overlays from OverlayManager on top of its child
class OverlayContainer extends StatelessWidget {
  final Widget child;

  const OverlayContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final overlayManager = OverlayManager.watch(context);

    // Render overlays in reverse order so first-pushed overlay is on top
    // This makes the order in managers list intuitive: first manager shows first
    final overlays = overlayManager.overlays.reversed.toList();

    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        // Render all overlays (reversed so first-pushed is on top)
        for (final entry in overlays)
          Positioned.fill(
            child: _OverlayWidget(
              key: entry.key,
              entry: entry,
              onDismiss: entry.config.dismissible ? overlayManager.pop : null,
            ),
          ),
      ],
    );
  }
}

/// Individual overlay widget with animations and positioning
class _OverlayWidget extends StatefulWidget {
  final AppOverlayEntry entry;
  final VoidCallback? onDismiss;

  const _OverlayWidget({
    super.key,
    required this.entry,
    this.onDismiss,
  });

  @override
  State<_OverlayWidget> createState() => _OverlayWidgetState();
}

class _OverlayWidgetState extends State<_OverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Tween<Offset> _slideTween;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.entry.config.animationDuration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideTween = _getSlideTween();

    _controller.forward();
  }

  Tween<Offset> _getSlideTween() {
    switch (widget.entry.config.type) {
      case OverlayType.bottomSheet:
      case OverlayType.bottomBanner:
        return Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        );
      case OverlayType.topBanner:
        return Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        );
      case OverlayType.fullScreen:
      case OverlayType.custom:
        return Tween<Offset>(
          begin: Offset.zero,
          end: Offset.zero,
        );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.entry.config;
    final barrierColor = config.barrierColor ?? Colors.black54;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // Barrier (background) - blocks all touch events
            // PointerInterceptor is needed to block platform view (map) gestures on web
            if (config.type == OverlayType.fullScreen ||
                config.type == OverlayType.bottomSheet)
              Positioned.fill(
                child: PointerInterceptor(
                  child: ModalBarrier(
                    dismissible: config.dismissible,
                    onDismiss: widget.onDismiss,
                    color: barrierColor.withAlpha(
                      ((barrierColor.a * 255) * _fadeAnimation.value).round(),
                    ),
                  ),
                ),
              ),
            // Content
            _buildContent(),
          ],
        );
      },
    );
  }

  Widget _buildContent() {
    final config = widget.entry.config;

    Widget content = SlideTransition(
      position: _slideTween.animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.entry.child,
      ),
    );

    switch (config.type) {
      case OverlayType.fullScreen:
        return Positioned.fill(
          child: SafeArea(child: content),
        );

      case OverlayType.bottomSheet:
        return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: content,
          ),
        );

      case OverlayType.topBanner:
        return Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: SafeArea(
            bottom: false,
            child: content,
          ),
        );

      case OverlayType.bottomBanner:
        return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: content,
          ),
        );

      case OverlayType.custom:
        return content;
    }
  }
}
