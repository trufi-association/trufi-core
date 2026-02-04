import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../l10n/poi_layers_localizations.dart';
import '../models/poi.dart';

/// Panel showing POI details when tapped
class POIDetailPanel extends StatelessWidget {
  final POI poi;
  final VoidCallback? onSetAsOrigin;
  final VoidCallback? onSetAsDestination;
  final VoidCallback? onClose;

  const POIDetailPanel({
    super.key,
    required this.poi,
    this.onSetAsOrigin,
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
              _buildIcon(theme),
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
                      _getTypeDisplayName(context),
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

          // Action buttons
          if (onSetAsOrigin != null || onSetAsDestination != null)
            Row(
              children: [
                if (onSetAsOrigin != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onSetAsOrigin,
                      icon: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                      label: Text(l10n.setAsOrigin),
                    ),
                  ),
                if (onSetAsOrigin != null && onSetAsDestination != null)
                  const SizedBox(width: 8),
                if (onSetAsDestination != null)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onSetAsDestination,
                      icon: const Icon(Icons.place, size: 18),
                      label: Text(l10n.goHere),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildIcon(ThemeData theme) {
    final color = poi.color;

    // Try POI's own icon from properties
    final poiSvgString = poi.properties['icon'] as String?;
    if (poiSvgString != null && poiSvgString.isNotEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(6),
        child: SvgPicture.string(
          poiSvgString,
          width: 28,
          height: 28,
        ),
      );
    }

    // Try subcategory icon from metadata
    final subConfig = poi.subcategoryConfig;
    if (subConfig?.iconSvg != null && subConfig!.iconSvg!.isNotEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(6),
        child: SvgPicture.string(
          subConfig.iconSvg!,
          width: 28,
          height: 28,
        ),
      );
    }

    // Try category icon from metadata
    if (poi.category.iconSvg != null && poi.category.iconSvg!.isNotEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(6),
        child: SvgPicture.string(
          poi.category.iconSvg!,
          width: 28,
          height: 28,
        ),
      );
    }

    // Fallback to Material icon
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        poi.category.fallbackIcon,
        color: color,
        size: 22,
      ),
    );
  }

  String _getTypeDisplayName(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;

    // Try subcategory displayName from metadata
    final subConfig = poi.subcategoryConfig;
    if (subConfig != null) {
      return subConfig.getLocalizedDisplayName(langCode);
    }

    // Try subcategory string formatted
    if (poi.subcategory != null) {
      return poi.subcategory!
          .split('_')
          .map((word) =>
              word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
          .join(' ');
    }

    // Fallback to category displayName
    return poi.category.getLocalizedDisplayName(langCode);
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
