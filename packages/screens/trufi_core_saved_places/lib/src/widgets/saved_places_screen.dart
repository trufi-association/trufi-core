import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/saved_places_cubit.dart';
import '../models/saved_place.dart';
import '../repository/saved_places_repository.dart';
import '../../l10n/saved_places_localizations.dart';
import 'edit_place_dialog.dart';
import 'saved_places_list.dart';

/// Main screen for displaying and managing saved places.
///
/// Can be used in two ways:
/// 1. With [repository]: Creates its own [SavedPlacesCubit] internally
/// 2. Without [repository]: Uses existing [SavedPlacesCubit] from context
///
/// Example with external cubit (recommended for state sharing):
/// ```dart
/// MultiProvider(
///   providers: [
///     BlocProvider(
///       create: (_) => SavedPlacesCubit()..initialize(),
///     ),
///   ],
///   child: SavedPlacesScreen(
///     onPlaceSelected: (place) => print(place.name),
///   ),
/// )
/// ```
class SavedPlacesScreen extends StatelessWidget {
  /// Repository for saved places persistence.
  /// If null, expects [SavedPlacesCubit] to be provided in context.
  final SavedPlacesRepository? repository;

  final void Function(SavedPlace place)? onPlaceSelected;
  final Widget Function(BuildContext context)? drawerBuilder;
  final String? title;

  /// Callback to open a map picker for location selection.
  /// If provided, enables location picking from map.
  final OnChooseOnMap? onChooseOnMap;

  /// Default latitude for new places when no location is selected.
  final double defaultLatitude;

  /// Default longitude for new places when no location is selected.
  final double defaultLongitude;

  const SavedPlacesScreen({
    super.key,
    this.repository,
    this.onPlaceSelected,
    this.drawerBuilder,
    this.title,
    this.onChooseOnMap,
    this.defaultLatitude = 0.0,
    this.defaultLongitude = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final content = _SavedPlacesScreenContent(
      onPlaceSelected: onPlaceSelected,
      drawerBuilder: drawerBuilder,
      title: title,
      onChooseOnMap: onChooseOnMap,
      defaultLatitude: defaultLatitude,
      defaultLongitude: defaultLongitude,
    );

    // If repository is provided, create our own cubit
    // Otherwise, expect cubit to be in context
    if (repository != null) {
      return BlocProvider(
        create: (context) =>
            SavedPlacesCubit(repository: repository!)..initialize(),
        child: content,
      );
    }

    return content;
  }
}

class _SavedPlacesScreenContent extends StatelessWidget {
  final void Function(SavedPlace place)? onPlaceSelected;
  final Widget Function(BuildContext context)? drawerBuilder;
  final String? title;
  final OnChooseOnMap? onChooseOnMap;
  final double defaultLatitude;
  final double defaultLongitude;

  const _SavedPlacesScreenContent({
    this.onPlaceSelected,
    this.drawerBuilder,
    this.title,
    this.onChooseOnMap,
    this.defaultLatitude = 0.0,
    this.defaultLongitude = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final localization = SavedPlacesLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? localization.yourPlaces),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddPlaceDialog(context),
            tooltip: localization.addPlace,
          ),
        ],
      ),
      drawer: drawerBuilder?.call(context),
      body: SavedPlacesList(
        onPlaceTap: onPlaceSelected,
        onPlaceEdit: (place) => _showEditPlaceDialog(context, place),
        onPlaceDelete: (place) => _showDeleteConfirmation(context, place),
      ),
    );
  }

  void _showAddPlaceDialog(BuildContext context) async {
    final cubit = context.read<SavedPlacesCubit>();

    final place = await EditPlaceDialog.show(
      context,
      onChooseOnMap: onChooseOnMap,
      defaultLatitude: defaultLatitude,
      defaultLongitude: defaultLongitude,
    );

    if (place != null) {
      cubit.savePlace(place);
    }
  }

  void _showEditPlaceDialog(BuildContext context, SavedPlace place) async {
    final cubit = context.read<SavedPlacesCubit>();

    final updatedPlace = await EditPlaceDialog.show(
      context,
      place: place,
      onChooseOnMap: onChooseOnMap,
      defaultLatitude: defaultLatitude,
      defaultLongitude: defaultLongitude,
    );

    if (updatedPlace != null) {
      cubit.updatePlace(updatedPlace);
    }
  }

  void _showDeleteConfirmation(BuildContext context, SavedPlace place) {
    final localization = SavedPlacesLocalizations.of(context);
    final cubit = context.read<SavedPlacesCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localization.removePlace),
        content: Text(localization.removePlaceConfirmation(place.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(localization.cancel),
          ),
          TextButton(
            onPressed: () {
              cubit.deletePlace(place);
              Navigator.of(dialogContext).pop();
            },
            child: Text(
              localization.remove,
              style: TextStyle(
                color: Theme.of(dialogContext).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Content widget that can be used without Scaffold for embedding.
class SavedPlacesContent extends StatelessWidget {
  final void Function(SavedPlace place)? onPlaceSelected;
  final void Function(SavedPlace place)? onPlaceEdit;
  final void Function(SavedPlace place)? onPlaceDelete;
  final bool showHistory;
  final int maxHistoryItems;

  const SavedPlacesContent({
    super.key,
    this.onPlaceSelected,
    this.onPlaceEdit,
    this.onPlaceDelete,
    this.showHistory = true,
    this.maxHistoryItems = 10,
  });

  @override
  Widget build(BuildContext context) {
    return SavedPlacesList(
      onPlaceTap: onPlaceSelected,
      onPlaceEdit: onPlaceEdit,
      onPlaceDelete: onPlaceDelete,
      showHistory: showHistory,
      maxHistoryItems: maxHistoryItems,
    );
  }
}
