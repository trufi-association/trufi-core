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

## Adding a new language

trufi-core is N-language: the set of languages is decided **per city app**, not
by core. Core packages ship en/es/de; a city adds its own languages (including
ones Flutter doesn't know, like Quechua `qu` or Aymara `ay`) without touching
core. The city's `TrufiLocaleConfig` is the single authority on which locales
the app offers.

### In a city app

1. **Declare the locale** in the app's `TrufiLocaleConfig`
   (`supportedLocales` + display names for the language picker).
2. **Translate the app-level ARBs** the app owns. Core-package strings
   resolve through each package's own delegate; if the language is not one
   core ships, those strings fall back per delegate resolution — translate
   upstream (a core PR adding the ARB) when the city needs them.
3. **Framework delegates**: for locales Flutter itself doesn't support,
   register `fallbackFrameworkLocalizationsDelegates()` (from
   `trufi_core_ui`) after the `GlobalMaterialLocalizations` family, so
   Material/Cupertino widgets keep working instead of asserting at startup.

### In a core package (adding a language core ships)

1. Copy `<prefix>_en.arb` → `<prefix>_<lang>.arb`, translate every key,
   keep the `@@locale` header.
2. Regenerate (`flutter gen-l10n` in the package) and **commit the
   generated files** — CI diffs them and fails on drift.
3. Repeat per package: each package has its own ARB set and delegate;
   there is no global table.

### The traps that already cost time (do not relearn these)

- **`intl` is a separate layer from Flutter l10n.** `NumberFormat`
  throws `ArgumentError` for locales without number symbols (`qu`, `ay`,
  `gn`): never call it with a raw app locale — use
  `safeNumberFormat(...)` from `trufi_core_utils`, which falls back to
  the default symbols instead of red-screening.
- **Time formatting** goes through
  `MaterialLocalizations.formatTimeOfDay` (see
  `trufi_core_utils/time_format.dart`), which honors the device's 24h
  setting and never throws for unknown locales. Don't use
  `DateFormat.jm()` with an app locale.
- **External services don't speak every locale.** Public Photon rejects
  unsupported `lang` values with **HTTP 400** (silently killing search) —
  `PhotonSearchService.supportedLanguages` whitelists what may be
  forwarded; anything else is sent without `lang`. OTP's GraphQL `locale`
  takes a two-letter ISO 639-1 code: forward `languageCode`, never
  `toLanguageTag()`.
- **Fallback UI that renders before delegates exist** (init screen)
  resolves the ambient locale first and only then falls back to English —
  keep that property when touching early-boot widgets.
