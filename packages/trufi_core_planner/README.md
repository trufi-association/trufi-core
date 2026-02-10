# trufi_core_planner

Core GTFS parsing and routing algorithms for Trufi applications.

This is a **pure Dart** package (no Flutter dependencies) that provides:

- 📦 **GTFS Models**: Stop, Route, Trip, StopTime
- 🔍 **GTFS Parser**: Parse GTFS ZIP files
- 🗺️ **Spatial Index**: Fast nearest-stop queries using KD-Tree
- 🛣️ **Route Index**: Fast route lookups and connections
- 🚌 **Routing Service**: Find transit routes between locations

## Features

- Pure Dart implementation (works in Flutter, server, CLI)
- No Flutter or asset dependencies
- Efficient KD-Tree spatial indexing
- Direct route finding (no transfers yet)
- Scoring algorithm for route quality

## Usage

```dart
import 'package:trufi_core_planner/trufi_core_planner.dart';
import 'package:latlong2/latlong.dart';

// Parse GTFS data
final data = await GtfsParser.parseFromFile('gtfs.zip');

// Build indices
final spatialIndex = GtfsSpatialIndex(data.stops);
final routeIndex = GtfsRouteIndex(data);

// Create routing service
final routing = GtfsRoutingService(
  data: data,
  spatialIndex: spatialIndex,
  routeIndex: routeIndex,
);

// Find routes
final paths = routing.findRoutes(
  origin: LatLng(-17.3935, -66.1570),
  destination: LatLng(-17.4000, -66.1600),
  maxWalkDistance: 500,
  maxResults: 5,
);

// Print results
for (final path in paths) {
  print('Walk: ${path.totalWalkDistance}m, Stops: ${path.totalStops}');
}
```

## Used By

- **trufi_core_routing**: Adds Flutter integration (assets, isolates)
- **trufi-server-planner**: HTTP API server for routing

## License

MIT
