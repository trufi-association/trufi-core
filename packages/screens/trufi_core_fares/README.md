# trufi_core_fares

Display fare/pricing information for public transportation.

## Features

- Group prices by transport mode, tariff regime, or any other label
- Arbitrary price categories per group (general, student, senior, disability,
  employee, etc.) — labels are consumer-provided so each deployment owns
  its own taxonomy
- Per-group and per-screen notes
- Last updated date
- Optional external "More info" link
- Localization support (EN, ES, DE) for the screen chrome
- Material 3 design
- Public composable widgets (`FaresHero`, `FareCard`, `FareCategoryChip`,
  `FaresNotesCard`) for consumers that want a custom layout

## Quick Start

```dart
FaresTrufiScreen(
  config: FaresConfig(
    currency: 'Bs.',
    fares: const [
      FareInfo(
        title: 'Pasaje urbano (Cercado)',
        icon: Icons.directions_bus_rounded,
        primary: FareCategory(
          label: 'Usuarios en general',
          price: '3.00',
          icon: Icons.person_rounded,
        ),
        additional: [
          FareCategory(label: 'Estudiante sec./universitario', price: '2.00'),
          FareCategory(label: 'Estudiante de primaria',         price: '1.00'),
          FareCategory(label: 'Adulto mayor',                    price: '2.50'),
          FareCategory(label: 'Persona con discapacidad',        price: '2.50'),
        ],
      ),
    ],
  ),
)
```

## Models

### FaresConfig

```dart
FaresConfig(
  currency: String,                 // Required - e.g., 'Bs.', '$', '€'
  fares: List<FareInfo>,           // Required - groups to render
  externalFareUrl: String?,        // Optional - link to more info
  lastUpdated: DateTime?,          // Optional - when fares were verified
  additionalNotes: String?,        // Optional - screen-wide notes
)
```

### FareInfo

```dart
FareInfo(
  title: String,                   // Required - card header (e.g., 'Trufi')
  icon: IconData,                  // Required - icon next to the title
  primary: FareCategory,           // Required - headline price (badge)
  additional: List<FareCategory>,  // Optional - rendered as chips
  color: Color?,                   // Optional - accent color
  notes: String?,                  // Optional - card footer notes
)
```

### FareCategory

```dart
FareCategory(
  label: String,                   // Required - already-localized label
  price: String,                   // Required - formatted, no currency
  icon: IconData?,                 // Optional - category icon
  color: Color?,                   // Optional - chip accent color
  note: String?,                   // Optional - sub-note under the price
)
```

## Composable widgets

If you don't want the opinionated `FaresTrufiScreen`, the package exports the
building blocks the screen uses internally:

- `FaresHero` — gradient hero card
- `FareCard` — header + chips + notes for one `FareInfo`
- `FareCategoryChip` — a single `FareCategory` chip
- `FaresNotesCard` — tip-style notes card

```dart
Column(
  children: [
    const FaresHero(title: 'Tarifas', subtitle: '...'),
    for (final fare in fares) FareCard(fare: fare, currency: 'Bs.'),
  ],
)
```

## Integration

```dart
// In TrufiApp screens list
screens: [
  FaresTrufiScreen(
    config: FaresConfig(
      currency: 'Bs.',
      lastUpdated: DateTime(2026, 5, 6),
      additionalNotes: 'Children under 5 ride free.',
      fares: const [
        FareInfo(
          title: 'Trufi',
          icon: Icons.directions_bus,
          primary: FareCategory(label: 'Regular', price: '2.00'),
          additional: [
            FareCategory(label: 'Student', price: '1.50'),
            FareCategory(label: 'Senior',  price: '1.00'),
          ],
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
