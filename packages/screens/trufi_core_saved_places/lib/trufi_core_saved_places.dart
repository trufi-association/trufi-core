/// Saved places management for Trufi apps.
///
/// This package provides a complete solution for managing saved places:
///
/// - **SavedPlace**: Data model for saved locations with metadata
/// - **SavedPlacesCubit**: State management using flutter_bloc
/// - **SavedPlacesRepository**: Abstract interface for persistence
/// - **SavedPlacesRepositoryImpl**: Default implementation using StorageService
/// - **SavedPlacesScreen**: Ready-to-use screen widget
/// - **SavedPlacesTrufiScreen**: TrufiScreen integration for modular apps
///
/// ## Usage
///
/// ```dart
/// // Using the ready-made screen
/// SavedPlacesScreen(
///   repository: SavedPlacesRepositoryImpl(),
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
export 'src/models/saved_place_icons.dart';
export 'src/models/saved_place_label.dart';
export 'src/models/saved_route.dart';

// Services
export 'src/services/saved_place_address.dart';

// Repository
export 'src/repository/saved_places_repository.dart';
export 'src/repository/saved_places_repository_impl.dart';
export 'src/repository/saved_places_my_places_provider.dart';
export 'src/repository/saved_places_cubit_provider.dart';
export 'src/repository/saved_routes_repository.dart';
export 'src/repository/saved_routes_repository_impl.dart';

// Cubit (State Management)
export 'src/cubit/saved_places_cubit.dart';
export 'src/cubit/saved_routes_cubit.dart';

// Widgets
export 'src/widgets/saved_place_tile.dart';
export 'src/widgets/saved_places_list.dart';
export 'src/widgets/saved_places_screen.dart';
export 'src/widgets/edit_place_dialog.dart';
export 'src/widgets/saved_route_card.dart';
export 'src/widgets/saved_routes_list.dart';
export 'src/widgets/route_name_dialog.dart';

// TrufiScreen Integration
export 'src/saved_places_trufi_screen.dart';
export 'src/saved_routes_trufi_screen.dart';

// Localizations
export 'l10n/saved_places_localizations.dart';
