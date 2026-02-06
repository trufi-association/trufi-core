import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

/// Beautiful default initialization screen with animations.
class DefaultInitScreen extends StatefulWidget {
  final AppInitStep? currentStep;
  final String? errorMessage;
  final VoidCallback onRetry;

  /// Optional custom logo widget to display instead of the default bus icon.
  final Widget? logo;

  const DefaultInitScreen({
    super.key,
    this.currentStep,
    this.errorMessage,
    required this.onRetry,
    this.logo,
  });

  @override
  State<DefaultInitScreen> createState() => _DefaultInitScreenState();
}

class _DefaultInitScreenState extends State<DefaultInitScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;

  static const _steps = AppInitStep.values;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  int get _currentStepIndex {
    if (widget.currentStep == null) return 0;
    return _steps.indexOf(widget.currentStep!);
  }

  String _stepToDisplayText(AppInitStep step) {
    return switch (step) {
      AppInitStep.starting => 'Starting',
      AppInitStep.initializingOverlays => 'Initializing',
      AppInitStep.loadingMaps => 'Loading maps',
      AppInitStep.loadingRoutes => 'Loading routes',
      AppInitStep.preparingScreens => 'Almost ready',
    };
  }

  IconData _stepToIcon(AppInitStep step) {
    return switch (step) {
      AppInitStep.starting => Icons.play_arrow_rounded,
      AppInitStep.initializingOverlays => Icons.layers_rounded,
      AppInitStep.loadingMaps => Icons.map_rounded,
      AppInitStep.loadingRoutes => Icons.route_rounded,
      AppInitStep.preparingScreens => Icons.check_circle_outline_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              colorScheme.primary.withValues(alpha: 0.08),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: widget.errorMessage != null
                  ? _buildErrorContent(context)
                  : _buildLoadingContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated icon with ripples
        SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ripple waves
              ...List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _rippleController,
                  builder: (context, child) {
                    final delay = index * 0.33;
                    final value = (_rippleController.value + delay) % 1.0;
                    return Opacity(
                      opacity: (1 - value) * 0.3,
                      child: Transform.scale(
                        scale: 0.5 + (value * 0.8),
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),

              // Rotating decorative ring
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationController.value * 2 * math.pi,
                    child: CustomPaint(
                      size: const Size(130, 130),
                      painter: _DottedCirclePainter(
                        color: primaryColor.withValues(alpha: 0.3),
                        dotCount: 12,
                      ),
                    ),
                  );
                },
              ),

              // Main icon container or custom logo
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: widget.logo ??
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                primaryColor,
                                primaryColor.withValues(alpha: 0.8),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.directions_bus_rounded,
                            size: 42,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),

        // Steps progress indicator
        _buildStepsIndicator(context),
        const SizedBox(height: 32),

        // Current step text
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Text(
            widget.currentStep != null
                ? _stepToDisplayText(widget.currentStep!)
                : 'Loading...',
            key: ValueKey(widget.currentStep),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepsIndicator(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_steps.length, (index) {
        final isCompleted = index < _currentStepIndex;
        final isCurrent = index == _currentStepIndex;

        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              width: isCurrent ? 36 : 28,
              height: isCurrent ? 36 : 28,
              decoration: BoxDecoration(
                color: isCompleted
                    ? primaryColor
                    : isCurrent
                        ? primaryColor.withValues(alpha: 0.15)
                        : colorScheme.outline.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: isCurrent
                    ? Border.all(color: primaryColor, width: 2)
                    : null,
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isCompleted
                      ? Icon(
                          Icons.check_rounded,
                          key: const ValueKey('check'),
                          size: 16,
                          color: colorScheme.onPrimary,
                        )
                      : Icon(
                          _stepToIcon(_steps[index]),
                          key: ValueKey(_steps[index]),
                          size: isCurrent ? 18 : 14,
                          color: isCurrent
                              ? primaryColor
                              : colorScheme.outline.withValues(alpha: 0.5),
                        ),
                ),
              ),
            ),
            if (index < _steps.length - 1)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 24,
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: index < _currentStepIndex
                      ? primaryColor
                      : colorScheme.outline.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildErrorContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Error icon with shake animation
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.error.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: colorScheme.onErrorContainer,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Error title
        Text(
          'Unable to start',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),

        // Error message
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.errorMessage ?? 'An unexpected error occurred',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                ),
          ),
        ),
        const SizedBox(height: 32),

        // Retry button
        FilledButton.icon(
          onPressed: widget.onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Try again'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for the dotted decorative circle.
class _DottedCirclePainter extends CustomPainter {
  final Color color;
  final int dotCount;

  _DottedCirclePainter({
    required this.color,
    this.dotCount = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < dotCount; i++) {
      final angle = (2 * math.pi / dotCount) * i;
      final dotCenter = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawCircle(dotCenter, 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DottedCirclePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.dotCount != dotCount;
  }
}
