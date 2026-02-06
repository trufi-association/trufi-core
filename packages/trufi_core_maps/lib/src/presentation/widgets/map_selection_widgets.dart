import 'package:flutter/material.dart';

/// Shared widget for toggling between online and offline maps.
///
/// This widget provides a consistent UI across different screens
/// (onboarding, settings, map type selection) for switching between
/// online and offline map types.
class MapOnlineOfflineToggle extends StatelessWidget {
  /// Whether to show online maps (true) or offline maps (false).
  final bool showOnline;

  /// Callback when the toggle value changes.
  final ValueChanged<bool> onToggle;

  /// Whether to use compact visual density (smaller size).
  /// Defaults to true for use in settings and onboarding screens.
  final bool compact;

  const MapOnlineOfflineToggle({
    super.key,
    required this.showOnline,
    required this.onToggle,
    this.compact = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SegmentedButton<bool>(
      segments: [
        ButtonSegment<bool>(
          value: true,
          label: const Text('Online'),
          icon: Icon(
            Icons.cloud_outlined,
            size: compact ? 18 : 20,
          ),
        ),
        ButtonSegment<bool>(
          value: false,
          label: const Text('Offline'),
          icon: Icon(
            Icons.offline_bolt_outlined,
            size: compact ? 18 : 20,
          ),
        ),
      ],
      selected: {showOnline},
      onSelectionChanged: (Set<bool> newSelection) {
        onToggle(newSelection.first);
      },
      style: ButtonStyle(
        visualDensity: compact ? VisualDensity.compact : null,
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primaryContainer;
            }
            return compact
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                : colorScheme.surfaceContainerLow;
          },
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.onPrimaryContainer;
            }
            return colorScheme.onSurface;
          },
        ),
      ),
    );
  }
}
