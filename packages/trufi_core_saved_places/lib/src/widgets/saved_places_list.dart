import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/saved_places_cubit.dart';
import '../models/saved_place.dart';
import '../../l10n/saved_places_localizations.dart';
import 'saved_place_tile.dart';

/// A list widget that displays saved places organized by sections.
class SavedPlacesList extends StatelessWidget {
  final void Function(SavedPlace place)? onPlaceTap;
  final void Function(SavedPlace place)? onPlaceEdit;
  final void Function(SavedPlace place)? onPlaceDelete;
  final bool showHistory;
  final int maxHistoryItems;

  const SavedPlacesList({
    super.key,
    this.onPlaceTap,
    this.onPlaceEdit,
    this.onPlaceDelete,
    this.showHistory = true,
    this.maxHistoryItems = 10,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SavedPlacesCubit, SavedPlacesState>(
      builder: (context, state) {
        if (state.status == SavedPlacesStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == SavedPlacesStatus.error) {
          return Center(
            child: Text(state.errorMessage ?? 'Error loading places'),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildDefaultPlacesSection(context, state),
            if (state.otherPlaces.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildOtherPlacesSection(context, state),
            ],
            if (showHistory && state.history.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildHistorySection(context, state),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDefaultPlacesSection(
    BuildContext context,
    SavedPlacesState state,
  ) {
    final localization = SavedPlacesLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          localization?.defaultPlaces ?? 'Default Places',
          Icons.bookmark,
        ),
        const SizedBox(height: 8),
        _buildDefaultPlaceTile(
          context,
          state.home,
          SavedPlaceType.home,
          localization?.home ?? 'Home',
          localization?.setHome ?? 'Set home address',
          Icons.home,
          Colors.blue,
        ),
        const SizedBox(height: 8),
        _buildDefaultPlaceTile(
          context,
          state.work,
          SavedPlaceType.work,
          localization?.work ?? 'Work',
          localization?.setWork ?? 'Set work address',
          Icons.work,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildDefaultPlaceTile(
    BuildContext context,
    SavedPlace? place,
    SavedPlaceType type,
    String title,
    String setLabel,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    if (place != null) {
      return SavedPlaceTile(
        place: place,
        onTap: () => onPlaceTap?.call(place),
        onEdit: onPlaceEdit != null ? () => onPlaceEdit?.call(place) : null,
        onDelete: onPlaceDelete != null ? () => onPlaceDelete?.call(place) : null,
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => onPlaceEdit?.call(SavedPlace(
          id: '${type.name}_placeholder',
          name: title,
          latitude: 0,
          longitude: 0,
          type: type,
          createdAt: DateTime.now(),
        )),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    Text(
                      setLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.add_circle_outline,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtherPlacesSection(
    BuildContext context,
    SavedPlacesState state,
  ) {
    final localization = SavedPlacesLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          localization?.customPlaces ?? 'Other Places',
          Icons.place,
        ),
        const SizedBox(height: 8),
        ...state.otherPlaces.map(
          (place) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SavedPlaceTile(
              place: place,
              onTap: () => onPlaceTap?.call(place),
              onEdit: onPlaceEdit != null ? () => onPlaceEdit?.call(place) : null,
              onDelete: onPlaceDelete != null
                  ? () => onPlaceDelete?.call(place)
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection(
    BuildContext context,
    SavedPlacesState state,
  ) {
    final localization = SavedPlacesLocalizations.of(context);
    final cubit = context.read<SavedPlacesCubit>();
    final historyItems = state.recentHistory.take(maxHistoryItems).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader(
              context,
              localization?.recentPlaces ?? 'Recent',
              Icons.history,
            ),
            TextButton(
              onPressed: () => cubit.clearHistory(),
              child: Text(localization?.clearHistory ?? 'Clear'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...historyItems.map(
          (place) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SavedPlaceTile(
              place: place,
              onTap: () => onPlaceTap?.call(place),
              onDelete: () => cubit.removeFromHistory(place.id),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
