# trufi_core_saved_places

Manage saved places (home, work, favorites, history) with persistence and UI.

## Features

- Home/Work as singletons (one each, replaceable)
- Custom places list
- Search history with auto-deduplication (max 50)
- Hive-based persistence
- Full UI: list, tiles, edit dialog
- Saved origin–destination routes with an itinerary snapshot (#1005)
- Localization (EN, ES, DE)

## Quick Start

### 1. Initialize

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SavedPlacesTrufiScreen.init();
  runApp(MyApp());
}
```

### 2. Use with TrufiApp (recommended)

```dart
final screen = SavedPlacesTrufiScreen(
  config: SavedPlacesConfig(
    onPlaceSelected: (place) => print(place.name),
  ),
);

MultiProvider(
  providers: [
    ...screen.providers,  // Includes SavedPlacesCubit
  ],
  child: MaterialApp(
    home: Builder(builder: screen.builder),
    localizationsDelegates: screen.localizationsDelegates,
    supportedLocales: screen.supportedLocales,
  ),
)
```

### 3. Standalone usage

```dart
BlocProvider(
  create: (_) => SavedPlacesCubit(
    repository: SharedPreferencesSavedPlacesRepository(),
  )..initialize(),
  child: SavedPlacesScreen(
    onPlaceSelected: (place) => Navigator.pop(context, place),
  ),
)
```

## Integration with search_locations

Two adapters to provide saved places to `LocationSearchScreen`:

```dart
// Option A: From Cubit (reactive)
final provider = SavedPlacesCubitProvider(context.read<SavedPlacesCubit>());

// Option B: From Repository (direct)
final provider = SavedPlacesMyPlacesProvider(repository);

// Use in search
LocationSearchScreen(
  myPlacesProvider: provider,
)
```

## API

### SavedPlacesCubit

```dart
// Home/Work (singletons)
cubit.setHome(place);
cubit.setWork(place);
cubit.removeHome();
cubit.removeWork();

// Custom places
cubit.addOtherPlace(place);
cubit.removeOtherPlace(id);

// History
cubit.addToHistory(place);
cubit.clearHistory();

// Generic
cubit.savePlace(place);
cubit.updatePlace(place);
cubit.deletePlace(place);
```

### SavedPlacesState

```dart
state.home          // SavedPlace?
state.work          // SavedPlace?
state.otherPlaces   // List<SavedPlace>
state.history       // List<SavedPlace>
state.allPlaces     // home + work + otherPlaces
```

### SavedPlace

```dart
SavedPlace(
  id: 'unique-id',
  name: 'Home',
  address: 'Address 123',
  latitude: -17.39,
  longitude: -66.15,
  type: SavedPlaceType.home,  // home, work, other, history
  iconName: 'star',           // For custom places
  createdAt: DateTime.now(),
)

// Conversions
place.toTrufiLocation()
place.toMyPlace()
SavedPlace.fromTrufiLocation(location, type: SavedPlaceType.other)
```

## Saved routes

"Your Routes" keeps complete origin–destination trips so a recurring journey
is one tap away. Register the screen next to the places one:

```dart
TrufiAppConfig(
  screens: [
    HomeScreenTrufiScreen(...),
    SavedPlacesTrufiScreen(),
    SavedRoutesTrufiScreen(), // path '/saved-routes', drawer order 55
  ],
)
```

Once the screen is registered, the route results of `trufi_core_home_screen`
show a bookmark button (results header, side panel and itinerary detail)
that saves the current trip under a name pre-filled with
"origin → destination", together with a snapshot of the selected itinerary
(transit badges, distance, duration). Without the screen the button does not
render, so existing apps see no change.

Tapping a saved route sets a pending `SharedRoute` on the app's
`SharedRouteNotifier` and navigates to `/`; the home screen consumes it
exactly like a deep link (origin, destination, fresh plan). To do something
else instead, pass a callback — the caller value wins over the default:

```dart
SavedRoutesTrufiScreen(
  config: SavedRoutesConfig(
    onRouteSelected: (route) => myPlanner.plan(route.origin, route.destination),
    repository: MySavedRoutesRepository(), // optional, defaults to SharedPreferences
  ),
)
```

### SavedRoutesCubit

```dart
cubit.saveRoute(route);        // false when the same trip is already saved
cubit.renameRoute(id, name);
cubit.swapRoute(id);           // false when the reversed trip already exists
cubit.deleteRoute(id);
cubit.markUsed(id);            // stamps lastUsedAt, keeps the order
cubit.findDuplicate(origin: p, destination: q); // SavedRoute? within 50 m

state.routes      // List<SavedRoute>, insertion order
state.isLoading   // bool
state.error       // String?
```

Two routes are the same trip when both endpoints lie within
`SavedRoutesCubit.duplicateRadiusMeters` (50 m) of each other, in the same
direction; names never take part. "Home → Work" and "Work → Home" are two
different routes — "Swap direction" creates the second one.

### SavedRoute

```dart
final route = SavedRoute.create(
  name: 'Home → Work',
  origin: SavedRoutePoint.fromTrufiLocation(from),
  destination: SavedRoutePoint.fromTrufiLocation(to),
  snapshot: savedRouteSnapshotFromItinerary(itinerary), // from trufi_core_home_screen, optional
);

route.swapped();           // inverted copy, snapshot dropped
route.origin.toTrufiLocation();
```

Routes persist as one JSON list under the `trufi_saved_routes` key of the
`StorageService` (`SharedPreferencesStorage` by default); implement
`SavedRoutesRepository` for another backend.

## Widgets

| Widget | Purpose |
|--------|---------|
| `SavedPlacesScreen` | Full screen with AppBar |
| `SavedPlacesContent` | Content only (for embedding) |
| `SavedPlacesList` | List organized by sections |
| `SavedPlaceTile` | Individual place card |
| `EditPlaceDialog.show()` | Create/edit modal |
| `SavedRoutesList` | Saved routes with loading / error / empty states |
| `SavedRouteCard` | Individual route card (chips, transit badges, summary, menu) |
| `RouteNameDialog.show()` | Name prompt shared by "save route" and "rename route" |

## Static vs Dynamic Places

You can provide places from any source:

```dart
// Static (hardcoded)
LocationSearchScreen(
  myPlaces: [
    SearchLocation(id: 'home', displayName: 'Home', ...),
  ],
)

// Dynamic (from SavedPlaces)
LocationSearchScreen(
  myPlacesProvider: SavedPlacesCubitProvider(cubit),
)
```

The UI doesn't care where places come from - use what fits your app.
