import 'package:flutter/material.dart';

import '../../models/navigation_instruction.dart';

/// Card displaying the current navigation instruction.
class NavigationInstructionCard extends StatelessWidget {
  final NavigationInstruction instruction;
  final NavigationInstruction? nextInstruction;
  final int remainingStops;
  final int totalStops;
  final int currentStopIndex;
  final double? distanceToNextStop;
  final Duration? etaToDestination;
  final bool isOffRoute;
  final bool isGpsWeak;

  const NavigationInstructionCard({
    super.key,
    required this.instruction,
    this.nextInstruction,
    required this.remainingStops,
    required this.totalStops,
    required this.currentStopIndex,
    this.distanceToNextStop,
    this.etaToDestination,
    this.isOffRoute = false,
    this.isGpsWeak = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Warning banner if off route or GPS weak
          if (isOffRoute || isGpsWeak) _buildWarningBanner(context),

          // Main instruction
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Instruction icon
                _buildInstructionIcon(context),
                const SizedBox(width: 16),

                // Instruction text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Primary text (stop name)
                      Text(
                        instruction.primaryText,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      if (instruction.secondaryText != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          instruction.secondaryText!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Distance/ETA
                if (distanceToNextStop != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatDistance(distanceToNextStop!),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      if (etaToDestination != null)
                        Text(
                          '~${_formatDuration(etaToDestination!)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),

          // Progress indicator
          _buildProgressIndicator(context),

          // Next instruction preview
          if (nextInstruction != null && remainingStops > 1)
            _buildNextPreview(context),
        ],
      ),
    );
  }

  Widget _buildWarningBanner(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isError = isOffRoute;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isError
            ? colorScheme.errorContainer
            : colorScheme.tertiaryContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Icon(
            isOffRoute ? Icons.wrong_location_rounded : Icons.gps_off_rounded,
            size: 18,
            color: isError
                ? colorScheme.onErrorContainer
                : colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: 8),
          Text(
            isOffRoute
                ? 'You appear to be off the route'
                : 'GPS signal is weak',
            style: TextStyle(
              color: isError
                  ? colorScheme.onErrorContainer
                  : colorScheme.onTertiaryContainer,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionIcon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final routeColor = instruction.routeColor ?? colorScheme.primary;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: instruction.isTransit
            ? routeColor
            : colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: instruction.isTransit && instruction.routeShortName != null
            ? Text(
                instruction.routeShortName!,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: instruction.routeShortName!.length > 3 ? 14 : 18,
                ),
              )
            : Icon(
                instruction.icon,
                color: instruction.isTransit
                    ? Colors.white
                    : colorScheme.onPrimaryContainer,
                size: 28,
              ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final routeColor = instruction.routeColor ?? colorScheme.primary;

    // Use actual total stops, limit to 12 dots for display
    final displayStops = totalStops.clamp(2, 12);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Stop indicators
          SizedBox(
            height: 24,
            child: Row(
              children: List.generate(
                displayStops,
                (index) {
                  // Map display index to actual stop index
                  final actualIndex = totalStops > 12
                      ? (index * (totalStops - 1) / (displayStops - 1)).round()
                      : index;

                  final isPassed = actualIndex <= currentStopIndex;
                  final isCurrent = actualIndex == currentStopIndex;
                  final isNext = actualIndex == currentStopIndex + 1;
                  final isLast = index == displayStops - 1;

                  return Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: (isCurrent || isNext) ? 12 : 8,
                          height: (isCurrent || isNext) ? 12 : 8,
                          decoration: BoxDecoration(
                            color: isPassed
                                ? routeColor
                                : (isNext
                                    ? Colors.white
                                    : colorScheme.outline.withValues(alpha: 0.5)),
                            shape: BoxShape.circle,
                            border: (isCurrent || isNext)
                                ? Border.all(color: routeColor, width: 2)
                                : null,
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: isPassed && actualIndex < currentStopIndex
                                  ? routeColor
                                  : colorScheme.outlineVariant,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextPreview(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.subdirectory_arrow_right_rounded,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            'Next: ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              nextInstruction!.primaryText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes} min';
    }
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}
