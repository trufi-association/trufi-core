/// Independent search location bar widgets for origin/destination selection.
///
/// This package provides reusable widgets for location search in routing apps:
///
/// - **SearchLocationBar**: Complete bar with origin/destination fields,
///   swap and reset buttons, adaptive to portrait/landscape
/// - **SearchLocationField**: Individual location input field
/// - **SearchLocation**: Data model for a searchable location
/// - **SearchLocationState**: State model holding origin and destination
/// - **SearchLocationBarConfiguration**: Styling and text configuration
///
/// ## Usage
///
/// ```dart
/// SearchLocationBar(
///   state: SearchLocationState(
///     origin: myOrigin,
///     destination: myDestination,
///   ),
///   configuration: SearchLocationBarConfiguration(
///     originHintText: 'Select origin',
///     destinationHintText: 'Select destination',
///   ),
///   onSearch: ({required bool isOrigin}) async {
///     // Show your search UI and return selected location
///     return await showMySearchDialog(isOrigin: isOrigin);
///   },
///   onOriginSelected: (location) => updateOrigin(location),
///   onDestinationSelected: (location) => updateDestination(location),
///   onSwap: () => swapLocations(),
///   onReset: () => clearLocations(),
///   onMenuPressed: () => openDrawer(),
/// )
/// ```
library;

// Models
export 'src/models/search_location.dart';
export 'src/models/search_location_state.dart';
export 'src/models/search_location_bar_configuration.dart';

// Widgets
export 'src/widgets/search_location_bar.dart';
export 'src/widgets/search_location_field.dart';
export 'src/widgets/search_location_buttons.dart';
export 'src/widgets/choose_on_map_screen.dart';
export 'src/widgets/location_search_screen.dart';

// Services
export 'src/services/search_location_service.dart';
export 'src/services/photon_search_service.dart';
export 'src/services/nominatim_search_service.dart';

// Saved Places - Repository
export 'src/saved_places/repository/search_locations_local_repository.dart';
export 'src/saved_places/repository/search_location_repository.dart';
export 'src/saved_places/repository/hive_local_repository.dart';

// Saved Places - Cubit
export 'src/saved_places/cubit/search_locations_cubit.dart';

// Saved Places - Translations
export 'src/saved_places/translations/saved_places_localizations.dart';
