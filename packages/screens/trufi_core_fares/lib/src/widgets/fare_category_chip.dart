import 'package:flutter/material.dart';

import '../models/fare_models.dart';

/// Compact chip rendering a single [FareCategory] (label + price).
class FareCategoryChip extends StatelessWidget {
  /// The category to render.
  final FareCategory category;

  /// Currency prefix prepended to the price (e.g., `"Bs."`).
  final String currency;

  const FareCategoryChip({
    super.key,
    required this.category,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = category.color ?? colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                category.icon ?? Icons.person_rounded,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  category.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$currency ${category.price}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (category.note != null) ...[
            const SizedBox(height: 4),
            Text(
              category.note!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
