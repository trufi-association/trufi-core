import 'package:flutter/material.dart';

/// Tip card with a lightbulb icon, used at the bottom of the fares screen.
class FaresNotesCard extends StatelessWidget {
  final String notes;
  final String label;

  const FaresNotesCard({super.key, required this.notes, this.label = 'Tips'});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.tertiary.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.tertiary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              size: 20,
              color: colorScheme.tertiary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.tertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notes,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.4,
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
