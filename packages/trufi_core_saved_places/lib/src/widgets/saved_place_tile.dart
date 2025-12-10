import 'package:flutter/material.dart';

import '../models/saved_place.dart';
import '../../l10n/saved_places_localizations.dart';

/// A tile widget for displaying a saved place.
class SavedPlaceTile extends StatelessWidget {
  final SavedPlace place;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onFavoriteToggle;
  final bool showFavoriteButton;
  final bool isFavorite;

  const SavedPlaceTile({
    super.key,
    required this.place,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onFavoriteToggle,
    this.showFavoriteButton = false,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localization = SavedPlacesLocalizations.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildIcon(context),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDisplayName(localization),
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (place.address != null && place.address!.isNotEmpty)
                      Text(
                        place.address!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (showFavoriteButton) ...[
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : colorScheme.onSurfaceVariant,
                  ),
                  onPressed: onFavoriteToggle,
                ),
              ],
              if (onEdit != null || onDelete != null)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit?.call();
                    } else if (value == 'delete') {
                      onDelete?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    if (onEdit != null)
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit),
                            const SizedBox(width: 8),
                            Text(localization?.editPlace ?? 'Edit'),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: colorScheme.error),
                            const SizedBox(width: 8),
                            Text(
                              localization?.removePlace ?? 'Remove',
                              style: TextStyle(color: colorScheme.error),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    IconData iconData;
    Color backgroundColor;

    switch (place.type) {
      case SavedPlaceType.home:
        iconData = Icons.home;
        backgroundColor = Colors.blue;
        break;
      case SavedPlaceType.work:
        iconData = Icons.work;
        backgroundColor = Colors.orange;
        break;
      case SavedPlaceType.other:
        iconData = _getIconFromName(place.iconName);
        backgroundColor = Colors.purple;
        break;
      case SavedPlaceType.history:
        iconData = Icons.history;
        backgroundColor = colorScheme.surfaceContainerHighest;
        break;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconData,
        color: backgroundColor,
        size: 24,
      ),
    );
  }

  IconData _getIconFromName(String? iconName) {
    switch (iconName) {
      case 'star':
        return Icons.star;
      case 'school':
        return Icons.school;
      case 'shopping':
        return Icons.shopping_cart;
      case 'restaurant':
        return Icons.restaurant;
      case 'gym':
        return Icons.fitness_center;
      case 'hospital':
        return Icons.local_hospital;
      case 'park':
        return Icons.park;
      case 'airport':
        return Icons.flight;
      case 'train':
        return Icons.train;
      case 'bus':
        return Icons.directions_bus;
      default:
        return Icons.place;
    }
  }

  String _getDisplayName(SavedPlacesLocalizations? localization) {
    if (place.type == SavedPlaceType.home && !place.name.contains('_')) {
      return localization?.home ?? 'Home';
    }
    if (place.type == SavedPlaceType.work && !place.name.contains('_')) {
      return localization?.work ?? 'Work';
    }
    return place.name;
  }
}
