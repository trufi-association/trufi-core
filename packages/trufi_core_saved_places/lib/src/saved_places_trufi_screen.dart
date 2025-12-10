import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

import '../l10n/saved_places_localizations.dart';
import 'cubit/saved_places_cubit.dart';
import 'models/saved_place.dart';
import 'repository/hive_saved_places_repository.dart';
import 'repository/saved_places_repository.dart';
import 'widgets/saved_places_list.dart';

/// Configuration for the Saved Places screen
class SavedPlacesConfig {
  /// Repository for saved places persistence
  final SavedPlacesRepository? repository;

  /// Callback when a place is selected
  final void Function(SavedPlace place)? onPlaceSelected;

  /// Callback when a place needs to be edited (e.g., show map picker)
  final void Function(BuildContext context, SavedPlace place)? onEditPlace;

  const SavedPlacesConfig({
    this.repository,
    this.onPlaceSelected,
    this.onEditPlace,
  });
}

/// Saved Places screen module for TrufiApp integration
class SavedPlacesTrufiScreen extends TrufiScreen {
  final SavedPlacesConfig config;
  late final SavedPlacesRepository _repository;

  SavedPlacesTrufiScreen({SavedPlacesConfig? config})
      : config = config ?? const SavedPlacesConfig() {
    _repository = this.config.repository ?? HiveSavedPlacesRepository();
  }

  @override
  String get id => 'saved_places';

  @override
  String get path => '/places';

  @override
  Widget Function(BuildContext context) get builder =>
      (_) => _SavedPlacesScreenWidget(
            config: config,
            repository: _repository,
          );

  @override
  List<LocalizationsDelegate> get localizationsDelegates => [
        ...SavedPlacesLocalizations.localizationsDelegates,
      ];

  @override
  List<Locale> get supportedLocales => SavedPlacesLocalizations.supportedLocales;

  @override
  List<SingleChildWidget> get providers => [
        BlocProvider<SavedPlacesCubit>(
          create: (_) => SavedPlacesCubit(repository: _repository)..initialize(),
        ),
      ];

  @override
  ScreenMenuItem? get menuItem => const ScreenMenuItem(
        icon: Icons.bookmark,
        order: 2,
      );

  @override
  String getLocalizedTitle(BuildContext context) {
    return SavedPlacesLocalizations.of(context)?.menuSavedPlaces ?? 'Your Places';
  }

  @override
  Future<void> initialize() async {
    await _repository.initialize();
  }

  @override
  Future<void> dispose() async {
    await _repository.dispose();
  }
}

class _SavedPlacesScreenWidget extends StatelessWidget {
  final SavedPlacesConfig config;
  final SavedPlacesRepository repository;

  const _SavedPlacesScreenWidget({
    required this.config,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    final localization = SavedPlacesLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localization?.yourPlaces ?? 'Your Places'),
      ),
      body: SavedPlacesList(
        onPlaceTap: config.onPlaceSelected,
        onPlaceEdit: config.onEditPlace != null
            ? (place) => config.onEditPlace!(context, place)
            : null,
        onPlaceDelete: (place) => _showDeleteConfirmation(context, place),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, SavedPlace place) {
    final localization = SavedPlacesLocalizations.of(context);
    final cubit = context.read<SavedPlacesCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localization?.removePlace ?? 'Remove Place'),
        content: Text(
          '${localization?.removePlaceConfirmation ?? "Are you sure you want to remove"} "${place.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(localization?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              cubit.deletePlace(place);
              Navigator.of(dialogContext).pop();
            },
            child: Text(
              localization?.remove ?? 'Remove',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
