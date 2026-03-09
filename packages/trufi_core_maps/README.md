# trufi_core_maps

A Flutter package for declarative map rendering with support for multiple map backends (MapLibre GL vector maps, offline maps, and raster tile maps).

The core idea is a **declarative data flow**: you pass layers, markers, and lines as data objects — the package handles all synchronization with the underlying map engine.

---

## Contents

- [Quick Start](#quick-start)
- [Core Concepts](#core-concepts)
- [Map Engines](#map-engines)
- [Data Types](#data-types)
- [Controller](#controller)
- [Widgets](#widgets)
- [Custom Engine](#custom-engine)
- [Offline Maps](#offline-maps)

---

## Quick Start

```dart
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => MapEngineManager(
        engines: defaultMapEngines,
        defaultCenter: const LatLng(-17.3895, -66.1568),
      ),
      child: const MyApp(),
    ),
  );
}

class MyMapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final engine = MapEngineManager.watch(context).currentEngine;

    return engine.buildMap(
      initialCamera: const TrufiCameraPosition(
        target: LatLng(-17.3895, -66.1568),
        zoom: 13,
      ),
      layers: [
        TrufiLayer(
          id: 'my-layer',
          markers: [
            TrufiMarker(
              id: 'bus-1',
              position: const LatLng(-17.39, -66.15),
              widget: const Icon(Icons.directions_bus, color: Colors.blue),
            ),
          ],
        ),
      ],
    );
  }
}
```

---

## Core Concepts

### Declarative layers

All map state is passed as immutable data objects. There are no imperative `addMarker()` / `removeMarker()` calls. Instead, rebuild your `TrufiLayer` list and pass it to the engine — the map syncs automatically.

```
parent widget
  └─ engine.buildMap(layers: [...])
       └─ TrufiMap / FlutterMapWidget
            └─ syncs native map on didUpdateWidget
```

### Controlled vs uncontrolled camera

- **Uncontrolled** (default): pass only `initialCamera`. The user can pan/zoom freely.
- **Controlled**: pass both `initialCamera` and `camera`. The map always tracks the `camera` value you provide — useful when the parent manages the camera state.

```dart
// Uncontrolled
engine.buildMap(initialCamera: startPos);

// Controlled
engine.buildMap(
  initialCamera: startPos,
  camera: _currentCamera,  // parent drives the camera
  onCameraChanged: (cam) => setState(() => _currentCamera = cam),
);
```

---

## Map Engines

The `ITrufiMapEngine` interface is the entry point. Call `engine.buildMap(...)` to get the map widget.

### Built-in engines

#### `MapLibreEngine` — vector maps (recommended)

```dart
const MapLibreEngine(
  styleString: 'https://tiles.openfreemap.org/styles/liberty',
  displayName: 'Liberty',
)
```

Renders GPU-accelerated vector tiles. Works on Android, iOS, and Web.
Any MapLibre-compatible style URL is accepted.

#### `defaultMapEngines` — ready-made preset

```dart
// Includes Liberty (light) and Dark styles
engines: defaultMapEngines,
```

#### `OfflineMapLibreEngine` — fully offline

Works without internet. Requires bundled `.mbtiles`, style JSON, sprites, and fonts as Flutter assets. See [Offline Maps](#offline-maps).

### Using `MapEngineManager`

`MapEngineManager` is a `ChangeNotifier` that holds the list of engines and tracks which one is active. It persists the user's selection across sessions via `SharedPreferences`.

```dart
// Setup (once, at the top of your widget tree)
ChangeNotifierProvider(
  create: (_) => MapEngineManager(
    engines: [
      const MapLibreEngine(
        styleString: 'https://tiles.openfreemap.org/styles/liberty',
      ),
      const MapLibreEngine(
        engineId: 'dark',
        styleString: 'https://tiles.openfreemap.org/styles/dark',
        displayName: 'Dark',
      ),
    ],
    defaultCenter: const LatLng(-17.39, -66.15),
  ),
  child: MyApp(),
)

// Read (no rebuild)
MapEngineManager.read(context).setEngine(myEngine);

// Watch (rebuilds on change)
final engine = MapEngineManager.watch(context).currentEngine;

// Initialize all engines (call during app startup for offline engines)
await mapEngineManager.initializeEngines();
```

---

## Data Types

### `TrufiCameraPosition`

Represents the map viewport.

| Field | Type | Description |
|---|---|---|
| `target` | `LatLng` | Center coordinate |
| `zoom` | `double` | Zoom level (Leaflet scale, 0–28) |
| `bearing` | `double` | Rotation in degrees |
| `viewportSize` | `Size?` | Viewport dimensions in logical pixels |
| `visibleRegion` | `LatLngBounds?` | Visible bounds (populated by `onCameraChanged`) |

### `TrufiLayer`

A named collection of markers and lines rendered together.

```dart
TrufiLayer(
  id: 'routes',           // unique identifier
  layerLevel: 5,          // z-order (higher = on top)
  visible: true,
  markers: [...],
  lines: [...],
)
```

Layers are sorted by `layerLevel` before rendering. To hide a layer, set `visible: false` — its data is preserved but not drawn.

### `TrufiMarker`

A marker rendered natively by the map engine (converted to PNG for GPU rendering — efficient for hundreds or thousands of markers).

```dart
TrufiMarker(
  id: 'vehicle-42',
  position: LatLng(-17.39, -66.15),
  widget: VehicleIcon(color: Colors.blue),   // any Flutter widget
  size: const Size(32, 32),
  rotation: 45.0,                            // degrees
  alignment: Alignment.bottomCenter,         // anchor point
  allowOverlap: false,                       // hide when overlapping
  imageCacheKey: 'vehicle_blue',             // stable key → reuses cached PNG
)
```

> **Performance tip:** Set `imageCacheKey` to a stable string based on visual properties (color, icon type) rather than position or id. Markers that look identical will share the same cached PNG image, avoiding repeated widget-to-PNG conversions.

### `TrufiLine`

A polyline drawn on the map.

```dart
TrufiLine(
  id: 'route-1',
  position: [LatLng(-17.39, -66.15), LatLng(-17.40, -66.16)],
  color: Colors.red,
  lineWidth: 3.0,
  activeDots: false,   // true = dashed line
)
```

### `WidgetMarker`

A real Flutter widget rendered as an overlay on top of the map. Unlike `TrufiMarker`, this preserves full Flutter interactivity (tap handlers, animations, etc.). Use sparingly — intended for a small number of special markers.

```dart
WidgetMarker(
  id: 'selected-stop',
  position: LatLng(-17.39, -66.15),
  child: MyCustomWidget(),
  alignment: Alignment.bottomCenter,
  size: const Size(60, 60),
)
```

### `LatLngBounds`

```dart
LatLngBounds(
  LatLng(southLat, westLng),   // southWest
  LatLng(northLat, eastLng),   // northEast
)
```

---

## Controller

`TrufiMapController` provides imperative camera control and marker hit-testing. Pass it to `buildMap` and call its methods from anywhere.

```dart
final _controller = TrufiMapController();

// In build:
engine.buildMap(controller: _controller, ...)

// Elsewhere:
_controller.moveCamera(TrufiCameraPosition(target: myLatLng, zoom: 14));

_controller.fitBounds(
  LatLngBounds(sw, ne),
  padding: const EdgeInsets.all(40),
);

// Pick markers near a tap
final picked = _controller.pickMarkersAt(tapPosition, hitboxPx: 32);
final nearest = _controller.pickNearestMarkerAt(tapPosition);
```

---

## Widgets

### `MapTypeButton`

A floating button that opens a full-screen map type selector sheet.

```dart
MapTypeButton.fromEngines(
  engines: mapEngineManager.engines,
  currentEngineIndex: mapEngineManager.currentIndex,
  onEngineChanged: (engine) => mapEngineManager.setEngine(engine),
  settingsAppBarTitle: 'Map Settings',
  settingsSectionTitle: 'Map Style',
  settingsApplyButtonText: 'Apply',
)
```

### `ChooseOnMapScreen`

A full-screen "pick a location on the map" flow. Returns the selected `LatLng`.

```dart
final result = await Navigator.push<MapLocationResult>(
  context,
  MaterialPageRoute(
    builder: (_) => ChooseOnMapScreen(
      configuration: ChooseOnMapConfiguration(
        title: 'Choose Destination',
        confirmButtonText: 'Confirm',
        showCoordinates: true,
        initialLatitude: -17.39,
        initialLongitude: -66.15,
        initialZoom: 14,
      ),
    ),
  ),
);

if (result != null) {
  print('Selected: ${result.latitude}, ${result.longitude}');
}
```

### `FitCameraUtil`

A pure utility for computing camera positions that fit a set of points.

```dart
final fitUtil = FitCameraUtil(padding: const EdgeInsets.all(40));

// Compute camera that fits all route points
final camera = fitUtil.cameraForPoints(routePoints, currentCamera);

// Check whether points are currently visible
if (fitUtil.isOutOfFocus(currentCamera, routePoints)) {
  controller.moveCamera(camera);
}
```

---

## Custom Engine

Implement `ITrufiMapEngine` to add any map backend:

```dart
class MyCustomEngine implements ITrufiMapEngine {
  @override
  String get id => 'my_engine';

  @override
  String get name => 'My Engine';

  @override
  String get description => 'Custom map backend';

  @override
  Future<void> initialize() async {
    // one-time setup
  }

  @override
  Widget buildMap({
    TrufiMapController? controller,
    required TrufiCameraPosition initialCamera,
    TrufiCameraPosition? camera,
    ValueChanged<TrufiCameraPosition>? onCameraChanged,
    void Function(LatLng)? onMapClick,
    void Function(LatLng)? onMapLongClick,
    List<TrufiLayer> layers = const [],
    List<WidgetMarker> widgetMarkers = const [],
  }) {
    return MyCustomMapWidget(
      controller: controller,
      initialCamera: initialCamera,
      camera: camera,
      onCameraChanged: onCameraChanged,
      onMapClick: onMapClick,
      layers: layers,
      widgetMarkers: widgetMarkers,
    );
  }
}
```

Your map widget state should implement `TrufiMapDelegate` and call `controller?.attach(this)` / `controller?.detach()` in `initState` / `dispose`. See the `FlutterMapEngine` in the `example/` folder for a complete reference implementation.

---

## Offline Maps

Use `OfflineMapLibreEngine` to bundle map tiles as assets for fully offline usage.

### 1. Prepare assets

You need:
- An `.mbtiles` file (vector tiles)
- A MapLibre style JSON file
- Sprite sheets (`sprite.json`, `sprite.png`, `sprite@2x.json`, `sprite@2x.png`)
- Font `.pbf` files for each text-font used in the style

### 2. Declare assets in `pubspec.yaml`

```yaml
flutter:
  assets:
    - assets/maps/tiles.mbtiles
    - assets/maps/style.json
    - assets/maps/sprites/
    - assets/maps/fonts/NotoSans-Regular/
```

### 3. Configure the engine

```dart
OfflineMapLibreEngine(
  config: OfflineMapConfig(
    mbtilesAsset: 'assets/maps/tiles.mbtiles',
    styleAsset: 'assets/maps/style.json',
    spritesAssetDir: 'assets/maps/sprites/',
    fontsAssetDir: 'assets/maps/fonts/',
    fontMapping: {
      'NotoSans-Regular': 'Noto Sans Regular',
    },
    fontRanges: ['0-255', '256-511'],  // unicode ranges present in your fonts
  ),
  displayName: 'Offline',
)
```

### 4. Initialize at startup

```dart
await mapEngineManager.initializeEngines();
```

On first run, assets are extracted to the app cache directory. Subsequent runs reuse the cached files.
