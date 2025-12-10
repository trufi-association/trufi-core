# Localization Standards

## Structure

```
packages/trufi_core_<name>/lib/l10n/
├── <prefix>_en.arb              # Template
├── <prefix>_es.arb
├── <prefix>_de.arb
├── <prefix>_localizations.dart  # Generated
├── <prefix>_localizations_en.dart
├── <prefix>_localizations_es.dart
└── <prefix>_localizations_de.dart
```

Prefix: package name without `trufi_core_` (e.g., `about`, `transport_list`)

## ARB Format

```json
{
  "@@locale": "en",
  "keyName": "Value",
  "@keyName": {
    "description": "Description of the key"
  },
  "keyWithPlaceholder": "{count} items",
  "@keyWithPlaceholder": {
    "description": "Description",
    "placeholders": {
      "count": { "type": "int", "example": "5" }
    }
  }
}
```

## pubspec.yaml

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.2
```

## Generate (via melos)

Localizations are generated using melos. The generated Dart files are committed to the repository.

## Checklist

- [ ] `lib/l10n/` with ARB files (en, es, de) including `@descriptions`
- [ ] Dependencies (`flutter_localizations`, `intl`) in pubspec.yaml
- [ ] Generated Dart files committed
- [ ] Exported in barrel file
