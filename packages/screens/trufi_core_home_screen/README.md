# Trufi Core Home Screen

Home screen with route planning for Trufi apps.

## Features

- Route planning with origin and destination search
- Itinerary display with multiple route options
- Map integration for route visualization
- Local storage for recent searches
- Route sharing with deep link support

## Usage

```dart
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';

// Using TrufiScreen for modular apps
final homeScreen = HomeScreenTrufiScreen(
  config: HomeScreenConfig(
    otpEndpoint: 'https://your-otp-server.com',
    appName: 'My App',           // Optional: shown in shared text
    deepLinkScheme: 'myapp',     // Optional: enables deep links
  ),
);
```

## Route Sharing & Deep Links

The home screen includes a share button that allows users to share routes with others. When `deepLinkScheme` is configured, shared routes include a deep link URL that opens the app directly with the route pre-loaded.

### Shared Content Example

When a user shares a route, the following text is generated:

```
🚌 My App - Ruta compartida

📍 Origen: Plaza Principal
📍 Destino: Aeropuerto

📅 Fecha: 18/12/2024
🕐 Salida: 14:30 → Llegada: 15:15
⏱️ Duración: 45 min

🚍 Ruta: 🚶 5min → 🚌 L1 → 🚶 3min

📲 Abrir en la app:
myapp://route?fromLat=-17.39&fromLng=-66.16&fromName=Plaza%20Principal&toLat=-17.41&toLng=-66.17&toName=Aeropuerto&time=1734530400000&itinerary=0
```

### Deep Link URL Format

```
{scheme}://route?fromLat={lat}&fromLng={lng}&fromName={name}&toLat={lat}&toLng={lng}&toName={name}&time={milliseconds}&itinerary={index}
```

| Parameter | Description |
|-----------|-------------|
| `fromLat` | Origin latitude |
| `fromLng` | Origin longitude |
| `fromName` | Origin name (URL encoded) |
| `toLat` | Destination latitude |
| `toLng` | Destination longitude |
| `toName` | Destination name (URL encoded) |
| `time` | Departure time in milliseconds since epoch |
| `itinerary` | Selected itinerary index (optional) |

### Platform Configuration

To enable deep links, you need to configure both the app and the native platforms.

#### 1. App Configuration

In your `main.dart`, configure the deep link scheme in both `AppConfiguration` and `HomeScreenConfig`:

```dart
runTrufiApp(
  AppConfiguration(
    appName: 'My App',
    deepLinkScheme: 'myapp',  // Enables deep link handling
    // ...
    screens: [
      HomeScreenTrufiScreen(
        config: HomeScreenConfig(
          otpEndpoint: 'https://your-otp-server.com',
          appName: 'My App',
          deepLinkScheme: 'myapp',  // Enables deep link in shared URLs
        ),
      ),
    ],
  ),
);
```

#### 2. Android Configuration

Add an intent filter to your `android/app/src/main/AndroidManifest.xml` inside the `<activity>` tag:

```xml
<activity
    android:name=".MainActivity"
    android:launchMode="singleTop"
    ...>

    <!-- Existing intent filters -->

    <!-- Deep link for route sharing -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="myapp" android:host="route" />
    </intent-filter>
</activity>
```

> **Important:** Replace `myapp` with your app's scheme (must match `deepLinkScheme` in your config).

#### 3. iOS Configuration

Add URL schemes to your `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <!-- Existing URL types -->

    <!-- Deep link for route sharing -->
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>myapp</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>myapp</string>
        </array>
    </dict>
</array>
```

> **Important:** Replace `myapp` with your app's scheme (must match `deepLinkScheme` in your config).

### Testing Deep Links

You can test deep links using the following methods:

**Android (via ADB):**
```bash
adb shell am start -a android.intent.action.VIEW -d "myapp://route?fromLat=-17.39&fromLng=-66.16&fromName=Test&toLat=-17.41&toLng=-66.17&toName=Dest&time=1734530400000"
```

**iOS (via Simulator):**
```bash
xcrun simctl openurl booted "myapp://route?fromLat=-17.39&fromLng=-66.16&fromName=Test&toLat=-17.41&toLng=-66.17&toName=Dest&time=1734530400000"
```

## Optional: POI Layers Integration

The home screen supports optional integration with POI (Points of Interest) layers. This feature is **completely optional** and only needs to be configured if your app uses the `trufi_core_poi_layers` package.

### How to Add POI Layers

1. **Add dependency** to your app's `pubspec.yaml`:
```yaml
dependencies:
  trufi_core_poi_layers: ^1.0.0
```

2. **Wrap HomeScreen with POILayersCubit**:
```dart
import 'package:trufi_core_poi_layers/trufi_core_poi_layers.dart';

BlocProvider(
  create: (context) => POILayersCubit(
    config: POILayerConfig(assetsBasePath: 'assets/pois'),
    defaultEnabledCategories: {POICategory.tourism, POICategory.food},
  )..initialize(),
  child: HomeScreenTrufiScreen(
    config: HomeScreenConfig(...),
  ),
)
```

3. **Customize the MapTypeButton** (optional):

The home screen provides a method `_buildMapTypeButton()` that you can override to include POI layers settings:

```dart
// In your custom HomeScreen subclass or wrapper
@override
Widget _buildMapTypeButton(MapEngineManager mapEngineManager) {
  return BlocBuilder<POILayersCubit, POILayersState>(
    builder: (context, state) {
      return MapTypeButton.fromEngines(
        engines: mapEngineManager.engines,
        currentEngineIndex: mapEngineManager.currentIndex,
        onEngineChanged: (engine) => mapEngineManager.setEngine(engine),
        // Integrated POI layers settings
        additionalSettings: POILayersSettingsSection(
          enabledCategories: state.enabledCategories,
          enabledSubcategories: state.enabledSubcategories,
          availableSubcategories: {
            for (final cat in POICategory.values)
              cat: context.read<POILayersCubit>().getSubcategories(cat),
          },
          onCategoryToggled: (category, enabled) {
            context.read<POILayersCubit>().toggleCategory(category, enabled);
          },
          onSubcategoryToggled: (category, subcategory, enabled) {
            context.read<POILayersCubit>().toggleSubcategory(
              category, subcategory, enabled,
            );
          },
        ),
      );
    },
  );
}
```

This will add POI layers configuration to the map type settings modal, allowing users to toggle POI categories alongside map type selection.

## Dependencies

- `trufi_core_interfaces` - Core interfaces and models
- `trufi_core_maps` - Map functionality
- `trufi_core_routing` - Routing service
- `share_plus` - Native share functionality
