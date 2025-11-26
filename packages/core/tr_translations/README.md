# Translations
In this package we keep track of all translations regarding the Trufi app

## Basic Usage
```dart
MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) {
    return TrufiLocalizationsProvider(
      localizations: TrufiLocalizations(AppLocalizations.of(context)),
      child: child!,
    );
  },
)

// In your widgets:
final loc = TrufiLocalizationsProvider.of(context);
Text(loc.feedbackTitle);
```

## Overriding Translations
```dart
TrufiLocalizationsConfig(
  overrideFeedbackTitle: (defaultValue) => 'My Custom Title',
  overrideDistanceMeters: (distance, defaultValue) => '$distance m',
)
```