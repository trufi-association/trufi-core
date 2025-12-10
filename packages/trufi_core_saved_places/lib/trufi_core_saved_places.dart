/// Saved places management for Trufi apps.
///
/// This package provides a complete solution for managing saved places:
///
/// - **SavedPlace**: Data model for saved locations with metadata
/// - **SavedPlacesCubit**: State management using flutter_bloc
/// - **SavedPlacesRepository**: Abstract interface for persistence
/// - **HiveSavedPlacesRepository**: Hive-based local storage implementation
/// - **SavedPlacesScreen**: Ready-to-use screen widget
/// - **SavedPlacesTrufiScreen**: TrufiScreen integration for modular apps
///
/// ## Usage
///
/// ```dart
/// // Using the ready-made screen
/// SavedPlacesScreen(
///   repository: HiveSavedPlacesRepository(),
///   onPlaceSelected: (place) {
///     // Navigate or use the selected place
///   },
/// )
///
/// // Or using the TrufiScreen for modular apps
/// final savedPlacesScreen = SavedPlacesTrufiScreen(
///   config: SavedPlacesConfig(
///     onPlaceSelected: (place) => navigateToRoute(place),
///   ),
/// );
/// ```
library;

// Models
export 'src/models/saved_place.dart';

// Repository
export 'src/repository/saved_places_repository.dart';
export 'src/repository/hive_saved_places_repository.dart';

// Cubit (State Management)
export 'src/cubit/saved_places_cubit.dart';

// Widgets
export 'src/widgets/saved_place_tile.dart';
export 'src/widgets/saved_places_list.dart';
export 'src/widgets/saved_places_screen.dart';
export 'src/widgets/edit_place_dialog.dart';

// TrufiScreen Integration
export 'src/saved_places_trufi_screen.dart';

// Localizations
export 'l10n/saved_places_localizations.dart';
