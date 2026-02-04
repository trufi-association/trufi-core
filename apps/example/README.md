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

All configuration is at the top of [lib/main.dart](lib/main.dart). Modify these values for your deployment:

### Required Parameters

| Parameter | Description |
|-----------|-------------|
| `_otpConfiguration` | OTP server endpoint and version for route planning |
| `_photonUrl` | Geocoding service URL for location search |
| `_defaultCenter` | Initial map coordinates (latitude, longitude) |

### OTP Version

**IMPORTANT:** The `OtpVersion` must match your OTP server exactly:

| Version | API Type | Notes |
|---------|----------|-------|
| `OtpVersion.v1_5` | REST | Legacy servers |
| `OtpVersion.v2_4` | GraphQL | Most common |
| `OtpVersion.v2_8` | GraphQL | Latest, with emissions support |

Using the wrong version will cause routing errors.

### App Identity

| Parameter | Description |
|-----------|-------------|
| `_appName` | Display name in UI and shared routes |
| `_deepLinkScheme` | URL scheme for deep links (e.g., `trufiapp://route/...`) |
| `_cityName` | City name for About screen |
| `_countryName` | Country name for About screen |
| `_emailContact` | Support email |

### URLs

| Parameter | Description |
|-----------|-------------|
| `_feedbackUrl` | User feedback form URL |
| `_facebookUrl` | Facebook page URL |
| `_xTwitterUrl` | X (Twitter) profile URL |
| `_instagramUrl` | Instagram profile URL |

### Geocoding Services

Two geocoding services are available:

**PhotonSearchService** (default):
```dart
PhotonSearchService(
  baseUrl: 'https://photon.komoot.io',  // Required
  biasLatitude: -17.39,                  // Optional: prioritize nearby results
  biasLongitude: -66.16,
)
```

**NominatimSearchService** (alternative):
```dart
NominatimSearchService(
  baseUrl: 'https://nominatim.openstreetmap.org',  // Required
  userAgent: 'MyApp/1.0',                          // Required
  countryCodes: ['bo'],                            // Optional: filter by country
)
```

### Current Values

- **OTP Endpoint**: `https://otp.trufi.app` (v2.8)
- **Photon**: `https://photon.trufi.app`
- **Map Tiles**: `https://maps.trufi.app` (OSM Bright, OSM Liberty, Dark Matter, Fiord Color)
- **Default Location**: Cochabamba, Bolivia (-17.3988354, -66.1626903)
- **Deep Link Scheme**: `trufiapp://`
- **POI Layers**: Tourism, Food, and Transport categories enabled by default

## Dependencies

See [pubspec.yaml](pubspec.yaml) for the complete list of dependencies.
