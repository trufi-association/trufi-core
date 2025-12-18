import 'package:flutter/material.dart';

import '../../models/navigation_instruction.dart';
import '../../models/navigation_state.dart';

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
  final List<NavigationLeg> legs;
  final NavigationLeg? currentLeg;
  final Duration? totalDuration;

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
    this.legs = const [],
    this.currentLeg,
    this.totalDuration,
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

          // Itinerary summary bar (like home screen)
          if (legs.isNotEmpty) _buildItinerarySummary(context),

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

    // Use currentLeg info if available, otherwise fall back to instruction
    final leg = currentLeg;
    if (leg != null) {
      // Determine color and content based on leg type
      final Color bgColor;
      final Widget content;

      if (leg.isTransit) {
        bgColor = leg.color != null ? Color(leg.color!) : colorScheme.primary;
        final routeName = leg.routeName ?? '';
        // Show icon + route name for transit
        content = Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getModeIcon(leg.modeName),
              color: Colors.white,
              size: 22,
            ),
            if (routeName.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                routeName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: routeName.length > 3 ? 14 : 16,
                ),
              ),
            ],
          ],
        );
      } else if (leg.isBicycle) {
        bgColor = const Color(0xFF4CAF50);
        content = const Icon(
          Icons.directions_bike_rounded,
          color: Colors.white,
          size: 28,
        );
      } else {
        // Walking
        bgColor = colorScheme.primaryContainer;
        content = Icon(
          Icons.directions_walk_rounded,
          color: colorScheme.onPrimaryContainer,
          size: 28,
        );
      }

      // Use wider container for transit with route name
      final isWideTransit = leg.isTransit && (leg.routeName?.isNotEmpty ?? false);

      return Container(
        width: isWideTransit ? 80 : 56,
        height: 56,
        padding: isWideTransit ? const EdgeInsets.symmetric(horizontal: 8) : null,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(child: content),
      );
    }

    // Fallback to instruction-based icon
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

  IconData _getModeIcon(String? mode) {
    switch (mode?.toUpperCase()) {
      case 'BUS':
        return Icons.directions_bus_rounded;
      case 'RAIL':
      case 'TRAIN':
        return Icons.train_rounded;
      case 'SUBWAY':
      case 'METRO':
        return Icons.subway_rounded;
      case 'TRAM':
        return Icons.tram_rounded;
      case 'FERRY':
        return Icons.directions_boat_rounded;
      case 'WALK':
        return Icons.directions_walk_rounded;
      case 'BICYCLE':
        return Icons.directions_bike_rounded;
      default:
        return Icons.directions_transit_rounded;
    }
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

  Widget _buildItinerarySummary(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final routeColor = instruction.routeColor ?? colorScheme.primary;

    // Calculate progress percentage
    final progressPercent = totalStops > 1 ? currentStopIndex / (totalStops - 1) : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Duration chip and transport legs
          Row(
            children: [
              // Duration chip
              if (totalDuration != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _formatDuration(totalDuration!),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              if (totalDuration != null) const SizedBox(width: 8),
              // Transport legs summary (scrollable)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int i = 0; i < legs.length; i++) ...[
                        _LegChipWidget(leg: legs[i]),
                        if (i < legs.length - 1)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Icon(
                              Icons.chevron_right_rounded,
                              size: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: Row(
                children: [
                  // Passed portion (gray)
                  if (progressPercent > 0)
                    Expanded(
                      flex: (progressPercent * 100).round(),
                      child: Container(
                        color: Colors.grey.withValues(alpha: 0.4),
                      ),
                    ),
                  // Remaining portion (route color)
                  if (progressPercent < 1)
                    Expanded(
                      flex: ((1 - progressPercent) * 100).round(),
                      child: Container(
                        color: routeColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip showing transport leg information for navigation.
class _LegChipWidget extends StatelessWidget {
  final NavigationLeg leg;

  const _LegChipWidget({required this.leg});

  @override
  Widget build(BuildContext context) {
    if (leg.isWalking || leg.isBicycle) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              leg.isWalking
                  ? Icons.directions_walk_rounded
                  : Icons.directions_bike_rounded,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 3),
            Text(
              '${leg.duration.inMinutes}\'',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Transit leg
    final color = leg.color != null ? Color(leg.color!) : Colors.blue;
    final routeName = leg.routeName ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getModeIcon(leg.modeName),
            size: 14,
            color: Colors.white,
          ),
          if (routeName.isNotEmpty) ...[
            const SizedBox(width: 3),
            Text(
              routeName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getModeIcon(String? mode) {
    switch (mode?.toUpperCase()) {
      case 'BUS':
        return Icons.directions_bus_rounded;
      case 'RAIL':
      case 'TRAIN':
        return Icons.train_rounded;
      case 'SUBWAY':
      case 'METRO':
        return Icons.subway_rounded;
      case 'TRAM':
        return Icons.tram_rounded;
      case 'FERRY':
        return Icons.directions_boat_rounded;
      case 'WALK':
        return Icons.directions_walk_rounded;
      case 'BICYCLE':
        return Icons.directions_bike_rounded;
      default:
        return Icons.directions_transit_rounded;
    }
  }
}
