import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';

import '../l10n/saved_places_localizations.dart';
import 'cubit/saved_places_cubit.dart';
import 'models/saved_place.dart';
import 'repository/saved_places_repository.dart';
import 'repository/saved_places_repository_impl.dart';
import 'widgets/edit_place_dialog.dart';
import 'widgets/saved_places_list.dart';

/// Configuration for the Saved Places screen
class SavedPlacesConfig {
  /// Repository for saved places persistence
  final SavedPlacesRepository? repository;

  /// Callback when a place is selected
  final void Function(SavedPlace place)? onPlaceSelected;

  const SavedPlacesConfig({
    this.repository,
    this.onPlaceSelected,
  });
}

/// Saved Places screen module for TrufiApp integration
class SavedPlacesTrufiScreen extends TrufiScreen {
  final SavedPlacesConfig config;
  late final SavedPlacesRepository _repository;

  /// Static initialization for the module.
  /// Call this once at app startup before using any SavedPlaces functionality.
  static Future<void> init() async {
    // No initialization needed for SharedPreferences
  }

  SavedPlacesTrufiScreen({SavedPlacesConfig? config})
      : config = config ?? const SavedPlacesConfig() {
    _repository = this.config.repository ?? SavedPlacesRepositoryImpl();
  }

  @override
  String get id => 'saved_places';

  @override
  String get path => '/places';

  @override
  Widget Function(BuildContext context) get builder =>
      (_) => _SavedPlacesScreenWidget(config: config);

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
        order: 50,
      );

  @override
  bool get hasOwnAppBar => true;

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

  const _SavedPlacesScreenWidget({
    required this.config,
  });

  Future<({double latitude, double longitude})?> _openMapPicker(
    BuildContext context, {
    double? initialLatitude,
    double? initialLongitude,
  }) async {
    final mapEngineManager = MapEngineManager.read(context);
    final defaultCenter = mapEngineManager.defaultCenter;

    final result = await Navigator.of(context).push<MapLocationResult>(
      MaterialPageRoute(
        builder: (context) => ChooseOnMapScreen(
          configuration: ChooseOnMapConfiguration(
            title: SavedPlacesLocalizations.of(context)?.chooseOnMap ?? 'Choose on Map',
            initialLatitude: initialLatitude ?? defaultCenter.latitude,
            initialLongitude: initialLongitude ?? defaultCenter.longitude,
            initialZoom: 15,
            confirmButtonText: SavedPlacesLocalizations.of(context)?.save ?? 'Confirm Location',
          ),
        ),
      ),
    );

    if (result == null) return null;
    return (latitude: result.latitude, longitude: result.longitude);
  }

  void _showAddPlaceDialog(BuildContext context) async {
    final cubit = context.read<SavedPlacesCubit>();
    final mapEngineManager = MapEngineManager.read(context);
    final defaultCenter = mapEngineManager.defaultCenter;

    final place = await EditPlaceDialog.show(
      context,
      onChooseOnMap: ({initialLatitude, initialLongitude}) => _openMapPicker(
        context,
        initialLatitude: initialLatitude,
        initialLongitude: initialLongitude,
      ),
      defaultLatitude: defaultCenter.latitude,
      defaultLongitude: defaultCenter.longitude,
    );

    if (place != null) {
      cubit.savePlace(place);
    }
  }

  void _showEditPlaceDialog(BuildContext context, SavedPlace place) async {
    final cubit = context.read<SavedPlacesCubit>();
    final mapEngineManager = MapEngineManager.read(context);
    final defaultCenter = mapEngineManager.defaultCenter;

    final updatedPlace = await EditPlaceDialog.show(
      context,
      place: place,
      onChooseOnMap: ({initialLatitude, initialLongitude}) => _openMapPicker(
        context,
        initialLatitude: initialLatitude,
        initialLongitude: initialLongitude,
      ),
      defaultLatitude: defaultCenter.latitude,
      defaultLongitude: defaultCenter.longitude,
    );

    if (updatedPlace != null) {
      cubit.updatePlace(updatedPlace);
    }
  }

  void _showDeleteConfirmation(BuildContext context, SavedPlace place) {
    final localization = SavedPlacesLocalizations.of(context);
    final cubit = context.read<SavedPlacesCubit>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (dialogContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 32,
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                localization?.removePlace ?? 'Remove Place',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${localization?.removePlaceConfirmation ?? "Are you sure you want to remove"} "${place.name}"?',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(localization?.cancel ?? 'Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        cubit.deletePlace(place);
                        Navigator.of(dialogContext).pop();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(localization?.remove ?? 'Remove'),
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

  /// Try to open the drawer from the nearest ancestor Scaffold
  void _tryOpenDrawer(BuildContext context) {
    HapticFeedback.lightImpact();
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold?.hasDrawer ?? false) {
      scaffold!.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = SavedPlacesLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Modern header
            _SavedPlacesHeader(
              title: localization?.yourPlaces ?? 'Your Places',
              onMenuPressed: () => _tryOpenDrawer(context),
              onAddPressed: () {
                HapticFeedback.lightImpact();
                _showAddPlaceDialog(context);
              },
            ),
            // Places list
            Expanded(
              child: SavedPlacesList(
                onPlaceTap: config.onPlaceSelected,
                onPlaceEdit: (place) => _showEditPlaceDialog(context, place),
                onPlaceDelete: (place) => _showDeleteConfirmation(context, place),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modern header for saved places screen
class _SavedPlacesHeader extends StatelessWidget {
  final String title;
  final VoidCallback onMenuPressed;
  final VoidCallback onAddPressed;

  const _SavedPlacesHeader({
    required this.title,
    required this.onMenuPressed,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          // Menu button
          Material(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onMenuPressed,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: Icon(
                  Icons.menu_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Title
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          // Add button
          Material(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onAddPressed,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: Icon(
                  Icons.add_rounded,
                  color: colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
