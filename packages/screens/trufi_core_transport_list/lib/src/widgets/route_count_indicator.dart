import 'package:flutter/material.dart';

/// The "657 routes" pill that heads a list: an icon and a `labelMedium`
/// text on `surfaceContainerHighest`, or on `tertiaryContainer` when the
/// list is narrowed by a filter. Shared by the routes list and the
/// nearby-lines sheet so both count their rows the same way.
class RouteCountIndicator extends StatelessWidget {
  const RouteCountIndicator({
    super.key,
    required this.label,
    this.icon = Icons.route_rounded,
    this.isFiltered = false,
  });

  /// Already localized ("657 routes", "12 lines within 300 m").
  final String label;
  final IconData icon;
  final bool isFiltered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final foreground = isFiltered
        ? colorScheme.onTertiaryContainer
        : colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isFiltered
                  ? colorScheme.tertiaryContainer
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: foreground),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
