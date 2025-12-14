import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/saved_place.dart';
import '../../l10n/saved_places_localizations.dart';

/// A tile widget for displaying a saved place with Material 3 design.
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

    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _buildIcon(context),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDisplayName(localization),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (place.address != null && place.address!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        place.address!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (showFavoriteButton) ...[
                const SizedBox(width: 4),
                _FavoriteButton(
                  isFavorite: isFavorite,
                  onPressed: onFavoriteToggle,
                ),
              ],
              if (onEdit != null || onDelete != null) ...[
                const SizedBox(width: 4),
                _MoreOptionsButton(
                  onEdit: onEdit,
                  onDelete: onDelete,
                  localization: localization,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    IconData iconData;
    Color iconColor;

    switch (place.type) {
      case SavedPlaceType.home:
        iconData = Icons.home_rounded;
        iconColor = Colors.blue;
        break;
      case SavedPlaceType.work:
        iconData = Icons.work_rounded;
        iconColor = Colors.orange;
        break;
      case SavedPlaceType.other:
        iconData = _getIconFromName(place.iconName);
        iconColor = Colors.purple;
        break;
      case SavedPlaceType.history:
        iconData = Icons.history_rounded;
        iconColor = colorScheme.onSurfaceVariant;
        break;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }

  IconData _getIconFromName(String? iconName) {
    switch (iconName) {
      case 'star':
        return Icons.star_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'shopping':
        return Icons.shopping_cart_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'gym':
        return Icons.fitness_center_rounded;
      case 'hospital':
        return Icons.local_hospital_rounded;
      case 'park':
        return Icons.park_rounded;
      case 'airport':
        return Icons.flight_rounded;
      case 'train':
        return Icons.train_rounded;
      case 'bus':
        return Icons.directions_bus_rounded;
      default:
        return Icons.place_rounded;
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

/// Favorite toggle button with animation
class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback? onPressed;

  const _FavoriteButton({
    required this.isFavorite,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed?.call();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: child,
            ),
            child: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(isFavorite),
              color: isFavorite ? Colors.red : colorScheme.onSurfaceVariant,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

/// More options popup menu button
class _MoreOptionsButton extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final SavedPlacesLocalizations? localization;

  const _MoreOptionsButton({
    this.onEdit,
    this.onDelete,
    this.localization,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: PopupMenuButton<String>(
        icon: Icon(
          Icons.more_vert_rounded,
          color: colorScheme.onSurfaceVariant,
          size: 22,
        ),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
        surfaceTintColor: colorScheme.surfaceTint,
        onSelected: (value) {
          HapticFeedback.lightImpact();
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    localization?.editPlace ?? 'Edit',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          if (onEdit != null && onDelete != null)
            const PopupMenuDivider(height: 8),
          if (onDelete != null)
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.delete_rounded,
                      size: 18,
                      color: colorScheme.error,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    localization?.removePlace ?? 'Remove',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w500,
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
