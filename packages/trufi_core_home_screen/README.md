# Trufi Core Home Screen

Home screen with route planning for Trufi apps.

## Features

- Route planning with origin and destination search
- Itinerary display with multiple route options
- Map integration for route visualization
- Local storage for recent searches
- Deep link support

## Usage

```dart
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';

// Using TrufiScreen for modular apps
final homeScreen = HomeScreenTrufiScreen(
  config: HomeScreenConfig(
    otpEndpoint: 'https://your-otp-server.com',
    defaultLatitude: -17.3988354,
    defaultLongitude: -66.1626903,
  ),
);
```

## Dependencies

- `trufi_core_interfaces` - Core interfaces and models
- `trufi_core_maps` - Map functionality
- `trufi_core_routing` - Routing service
