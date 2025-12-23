# Trufi Core Example App

Example application demonstrating the integration of Trufi Core packages.

## Features

This example app showcases:
- **Home Screen** with route planning
- **Saved Places** management
- **Transport List** with real-time data
- **Fares** information
- **Feedback** system
- **Settings** management
- **About** screen
- **POI Layers** (Points of Interest) integration

## POI Layers Integration

This example app includes POI layers configuration in [main.dart](lib/main.dart):

```dart
AppConfiguration(
  // ... other configuration
  providers: [
    // ... other providers
    BlocProvider(
      create: (_) => POILayersCubit(
        config: const POILayerConfig(
          assetsBasePath: 'assets/pois',
        ),
        defaultEnabledCategories: {
          POICategory.tourism,
          POICategory.food,
          POICategory.transport,
        },
      ),
    ),
  ],
  // Providers that need async initialization
  initializableProviders: [
    (context) => context.read<POILayersCubit>(),
  ],
)
```

The POI data is **automatically loaded during app startup** by `runTrufiApp`. The app shows a loading screen while providers are being initialized. If initialization fails, an error screen with retry button is shown.

**Note:** While POI data loads successfully, the **HomeScreen doesn't render POI markers on the map** yet. The cubit provides the data, but you need to integrate POI rendering layers to see the markers displayed.

### POI Data Assets

The POI data is stored in GeoJSON format in the `assets/pois/` directory. The example includes sample POI data for Cochabamba, Bolivia with the following categories:

- **Tourism** - Museums, monuments, viewpoints
- **Food** - Restaurants, cafes, fast food
- **Transport** - Bus stops, taxi stands, parking
- **Education** - Schools, universities, libraries
- **Healthcare** - Hospitals, clinics, pharmacies
- **Shopping** - Supermarkets, stores, malls
- **Recreation** - Parks, sports facilities, entertainment
- **Finance** - Banks, ATMs, exchange offices
- **Government** - Municipal offices, post offices
- **Emergency** - Police, fire stations
- **Religion** - Churches, temples

Each category has its own GeoJSON file (e.g., `tourism.geojson`, `food.geojson`).

### Viewing POI Layers in Action

To see POI layers fully working with map integration:

1. Check the [POI Layers example](../../packages/trufi_core_poi_layers/example) - This is a complete working implementation that shows POIs on the map
2. See the [HomeScreen README](../../packages/screens/trufi_core_home_screen/README.md#optional-poi-layers-integration) for future integration instructions

The difference is:
- **This example app**: Has POI data and configuration, but HomeScreen doesn't render POIs on the map yet
- **POI Layers example**: Full implementation with POI markers visible on the map

## Running the Example

```bash
cd apps/example
flutter pub get
flutter run
```

## Configuration

The app is configured to use:
- **OTP Endpoint**: `https://otp-240.trufi-core.trufi.dev`
- **Default Location**: Cochabamba, Bolivia (-17.3988354, -66.1626903)
- **Map Engines**: MapLibre GL and Flutter Map
- **Deep Link Scheme**: `trufiapp://`
- **POI Layers**: Tourism, Food, and Transport categories enabled by default
- **POI Data**: Sample GeoJSON data for Cochabamba included in `assets/pois/`

## Dependencies

See [pubspec.yaml](pubspec.yaml) for the complete list of dependencies.
