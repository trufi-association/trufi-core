# Package Standards

## Structure

```
packages/trufi_core_<name>/
├── lib/
│   ├── trufi_core_<name>.dart     # Barrel file (exports)
│   ├── l10n/                       # Localizations
│   │   ├── <prefix>_en.arb
│   │   ├── <prefix>_es.arb
│   │   ├── <prefix>_de.arb
│   │   ├── <prefix>_localizations.dart
│   │   ├── <prefix>_localizations_en.dart
│   │   ├── <prefix>_localizations_es.dart
│   │   └── <prefix>_localizations_de.dart
│   └── src/                        # Internal implementation
│       └── <name>_trufi_screen.dart
├── example/                        # Example app
│   ├── lib/
│   │   └── main.dart
│   └── pubspec.yaml
├── pubspec.yaml
└── README.md
```

## pubspec.yaml

```yaml
name: trufi_core_<name>
description: "Description of the package"
version: 0.0.1
homepage:
publish_to: none
resolution: workspace           # Required for monorepo

environment:
  sdk: ^3.10.0
  flutter: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.2
  trufi_core_interfaces:
    path: ../trufi_core_interfaces
  # Other dependencies...

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

## Example App pubspec.yaml

```yaml
name: trufi_core_<name>_example
description: "Example app for trufi_core_<name> package"
publish_to: none
resolution: workspace           # Required for monorepo
version: 0.0.1

environment:
  sdk: ^3.10.0

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  trufi_core_<name>:
    path: ../
```

## Barrel File (lib/trufi_core_<name>.dart)

```dart
export 'src/<name>_trufi_screen.dart';
export 'l10n/<prefix>_localizations.dart';
```

## Workspace Integration

Add to root `pubspec.yaml`:

```yaml
workspace:
  - packages/trufi_core_<name>
  - packages/trufi_core_<name>/example
```

## README.md Template

```markdown
# trufi_core_<name>

Brief description of the package.

## Features

- Feature 1
- Feature 2

## Quick Start

\`\`\`dart
<Name>TrufiScreen(
  config: <Name>Config(...),
)
\`\`\`

## Configuration

### <Name>Config

\`\`\`dart
<Name>Config(
  param1: Type,     // Required - description
  param2: Type?,    // Optional - description
)
\`\`\`

## Integration

\`\`\`dart
screens: [
  <Name>TrufiScreen(config: <Name>Config(...)),
]
\`\`\`

## Menu

- Icon: `Icons.<icon>`
- Order: <number>
```

## Checklist

- [ ] Package structure follows convention
- [ ] `resolution: workspace` in both pubspec.yaml files
- [ ] Barrel file exports public API
- [ ] Localizations (en, es, de) with ARB files
- [ ] Example app that demonstrates usage
- [ ] README.md with quick start and configuration
- [ ] Added to workspace in root pubspec.yaml
- [ ] Run `melos bootstrap` after adding
