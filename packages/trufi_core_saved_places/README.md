# trufi_core_saved_places

Manage saved places (home, work, favorites, history) with persistence and UI.

## Features

- Home/Work as singletons (one each, replaceable)
- Custom places list
- Search history with auto-deduplication (max 50)
- Hive-based persistence
- Full UI: list, tiles, edit dialog
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
    repository: HiveSavedPlacesRepository(),
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

## Widgets

| Widget | Purpose |
|--------|---------|
| `SavedPlacesScreen` | Full screen with AppBar |
| `SavedPlacesContent` | Content only (for embedding) |
| `SavedPlacesList` | List organized by sections |
| `SavedPlaceTile` | Individual place card |
| `EditPlaceDialog.show()` | Create/edit modal |

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
