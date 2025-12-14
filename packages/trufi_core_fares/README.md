# trufi_core_fares

Display fare/pricing information for public transportation.

## Features

- Show fares by transport type (bus, trufi, metro, etc.)
- Support for regular, student, and senior prices
- Notes per fare type
- Last updated date
- Optional external link for more info
- Localization support (EN, ES, DE)
- Material 3 design

## Quick Start

```dart
FaresTrufiScreen(
  config: FaresConfig(
    currency: 'Bs.',
    fares: [
      FareInfo(
        transportType: 'Trufi',
        icon: Icons.directions_bus,
        regularFare: '2.00',
        studentFare: '1.50',
        seniorFare: '1.00',
      ),
    ],
  ),
)
```

## Configuration

### FaresConfig

```dart
FaresConfig(
  currency: String,                 // Required - e.g., 'Bs.', '$', '€'
  fares: List<FareInfo>,           // Required - list of fare information
  externalFareUrl: String?,        // Optional - link to more info
  lastUpdated: DateTime?,          // Optional - when fares were updated
  additionalNotes: String?,        // Optional - general notes
)
```

### FareInfo

```dart
FareInfo(
  transportType: String,           // Required - e.g., 'Bus', 'Metro'
  icon: IconData,                  // Required - icon for this type
  regularFare: String,             // Required - regular price
  studentFare: String?,            // Optional - student price
  seniorFare: String?,             // Optional - senior price
  notes: String?,                  // Optional - notes for this fare
)
```

## Integration

```dart
// In TrufiApp screens list
screens: [
  FaresTrufiScreen(
    config: FaresConfig(
      currency: 'Bs.',
      lastUpdated: DateTime(2024, 1, 15),
      additionalNotes: 'Children under 5 ride free.',
      fares: [
        FareInfo(
          transportType: 'Trufi',
          icon: Icons.directions_bus,
          regularFare: '2.00',
          studentFare: '1.50',
          seniorFare: '1.00',
        ),
        FareInfo(
          transportType: 'Micro',
          icon: Icons.airport_shuttle,
          regularFare: '1.50',
        ),
      ],
    ),
  ),
]
```

## Menu

Default menu item:
- Icon: `Icons.payments_outlined`
- Order: 150
