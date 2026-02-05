import 'package:flutter/material.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

/// Beautiful default initialization screen with animations.
class DefaultInitScreen extends StatefulWidget {
  final AppInitStep? currentStep;
  final String? errorMessage;
  final VoidCallback onRetry;

  const DefaultInitScreen({
    super.key,
    this.currentStep,
    this.errorMessage,
    required this.onRetry,
  });

  @override
  State<DefaultInitScreen> createState() => _DefaultInitScreenState();
}

class _DefaultInitScreenState extends State<DefaultInitScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _stepToDisplayText(AppInitStep? step) {
    return switch (step) {
      AppInitStep.starting => 'Starting...',
      AppInitStep.initializingOverlays => 'Initializing...',
      AppInitStep.loadingMaps => 'Loading maps...',
      AppInitStep.loadingRoutes => 'Loading routes...',
      AppInitStep.preparingScreens => 'Almost ready...',
      null => 'Loading...',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withValues(alpha: 0.1),
              colorScheme.surface,
              colorScheme.secondary.withValues(alpha: 0.05),
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated icon
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.directions_bus_rounded,
                  size: 50,
                  color: colorScheme.primary,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 48),

        // Loading indicator
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 24),

        // Current step
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _stepToDisplayText(widget.currentStep),
            key: ValueKey(widget.currentStep),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Error icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: colorScheme.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.cloud_off_rounded,
            size: 50,
            color: colorScheme.error,
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
        Text(
          widget.errorMessage ?? 'An unexpected error occurred',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
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
          ),
        ),
      ],
    );
  }
}
