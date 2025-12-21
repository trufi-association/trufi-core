import 'package:flutter/material.dart';

import '../data/models/poi.dart';
import '../l10n/poi_layers_localizations.dart';

/// Panel showing POI details when tapped
class POIDetailPanel extends StatelessWidget {
  final POI poi;
  final VoidCallback? onSetAsDestination;
  final VoidCallback? onClose;

  const POIDetailPanel({
    super.key,
    required this.poi,
    this.onSetAsDestination,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = POILayersLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header with icon and name
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: poi.category.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  poi.type.icon,
                  color: poi.category.color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      poi.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      l10n.poiType(poi.type.name),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onClose != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Details
          if (poi.address != null) ...[
            _InfoRow(
              icon: Icons.location_on_outlined,
              text: poi.address!,
            ),
            const SizedBox(height: 8),
          ],
          if (poi.openingHours != null) ...[
            _InfoRow(
              icon: Icons.access_time_outlined,
              text: poi.openingHours!,
            ),
            const SizedBox(height: 8),
          ],
          if (poi.phone != null) ...[
            _InfoRow(
              icon: Icons.phone_outlined,
              text: poi.phone!,
            ),
            const SizedBox(height: 8),
          ],

          const SizedBox(height: 8),

          // Action button
          if (onSetAsDestination != null)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onSetAsDestination,
                icon: const Icon(Icons.directions),
                label: Text(l10n.goHere),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
