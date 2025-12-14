# trufi_core_feedback

Feedback screen that opens an external URL with app context (language, location, version).

## Features

- Opens external feedback URL
- Passes context: language, GPS location, app version
- Localization support (EN, ES, DE)
- Material 3 design

## Quick Start

```dart
FeedbackTrufiScreen(
  config: FeedbackConfig(
    feedbackUrl: 'https://example.com/feedback',
    getCurrentLocation: () async => (-17.39, -66.15), // Optional
  ),
)
```

## Configuration

```dart
FeedbackConfig(
  feedbackUrl: String,              // Required - URL to open
  getCurrentLocation: Future<(double, double)?> Function()?,  // Optional
)
```

The URL will receive query parameters:
- `lang` - Current locale (en, es, de)
- `geo` - GPS coordinates (if available)
- `app` - App version

## Integration

```dart
// In TrufiApp screens list
screens: [
  FeedbackTrufiScreen(
    config: FeedbackConfig(
      feedbackUrl: 'https://trufi-association.org/feedback/',
    ),
  ),
]
```

## Menu

Default menu item:
- Icon: `Icons.feedback_outlined`
- Order: 800
