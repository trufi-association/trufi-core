# POI Layers Example

This example demonstrates the usage of the `trufi_core_poi_layers` package.

## Features Demonstrated

- Loading POI data from GeoJSON files
- Displaying POIs on a map using different map engines (FlutterMap and MapLibre)
- Toggling different POI categories (transport, food, shopping, etc.)
- Interactive POI markers with tap handling
- POI detail panels showing information
- Custom POI markers with category-specific icons and colors
- Dynamic layer management

## Getting Started

1. Install dependencies:
```bash
flutter pub get
```

2. Run the example:
```bash
flutter run
```

## POI Categories

The example includes the following POI categories:

- 🚌 **Transport**: Bus stops, train stations, parking
- 🍽️ **Food**: Restaurants, cafes, fast food
- 🛍️ **Shopping**: Supermarkets, shops, malls
- 🏥 **Healthcare**: Hospitals, pharmacies, clinics
- 🎓 **Education**: Schools, universities, libraries
- 🏦 **Finance**: Banks, ATMs
- 📷 **Tourism**: Museums, monuments, viewpoints
- 🏞️ **Recreation**: Parks, sports facilities
- 🏛️ **Government**: City halls, post offices
- ⛪ **Religion**: Churches, temples
- 🚨 **Emergency**: Police, fire stations
- 🏨 **Accommodation**: Hotels, hostels

## Usage

### Toggle Layers
Tap the layers icon in the app bar to show/hide different POI categories.

### View POI Details
Tap any POI marker on the map to see its details.

### Change Map Style
Tap the map icon in the app bar to switch between OpenStreetMap and MapLibre styles.

### Center Map
Use the floating action button to center the map on Cochabamba, Bolivia.

## Data Format

POI data is stored in GeoJSON format in `../../pois/`. Each category has its own file:

```json
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "id": "123",
      "geometry": {
        "type": "Point",
        "coordinates": [-66.1568, -17.3895]
      },
      "properties": {
        "name": "Example POI",
        "type": "restaurant",
        "category": "food"
      }
    }
  ]
}
```

## Customization

You can customize the POI layers by modifying the `POILayerConfig`:

```dart
POILayerConfig(
  assetsBasePath: 'pois',
  enabledCategories: [POICategory.food, POICategory.transport],
  onPOITap: (poi) {
    // Handle POI tap
  },
)
```
