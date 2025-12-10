# TrufiScreen Standards

## Structure

```
packages/trufi_core_<name>/
├── lib/
│   ├── <name>_trufi_screen.dart    # Main TrufiScreen implementation
│   ├── l10n/                        # Localizations (see l10n-standards.md)
│   └── src/                         # Internal implementation
└── pubspec.yaml
```

## TrufiScreen Interface

```dart
abstract class TrufiScreen {
  String get id;                    // Unique identifier (e.g., 'about')
  String get path;                  // Route path (e.g., '/about')
  Widget Function(BuildContext) get builder;
  List<LocalizationsDelegate> get localizationsDelegates;
  List<Locale> get supportedLocales => [];
  List<SingleChildWidget> get providers => [];
  ScreenMenuItem? get menuItem => null;
  String getLocalizedTitle(BuildContext context);
}
```

## Implementation Pattern

```dart
// 1. Config class for screen parameters
class MyScreenConfig {
  final String requiredParam;
  final String? optionalParam;

  const MyScreenConfig({
    required this.requiredParam,
    this.optionalParam,
  });
}

// 2. TrufiScreen implementation
class MyTrufiScreen extends TrufiScreen {
  final MyScreenConfig config;

  MyTrufiScreen({required this.config});

  @override
  String get id => 'my_screen';

  @override
  String get path => '/my-screen';

  @override
  Widget Function(BuildContext) get builder =>
      (_) => _MyScreenContent(config: config);

  @override
  List<LocalizationsDelegate> get localizationsDelegates => [
    MyLocalizations.delegate,
  ];

  @override
  List<Locale> get supportedLocales => MyLocalizations.supportedLocales;

  @override
  List<SingleChildWidget> get providers => [
    // ChangeNotifierProvider, BlocProvider, etc.
  ];

  @override
  ScreenMenuItem? get menuItem => const ScreenMenuItem(
    icon: Icons.my_icon,
    order: 10,  // Lower = higher in menu
  );

  @override
  String getLocalizedTitle(BuildContext context) {
    return MyLocalizations.of(context)?.menuTitle ?? 'Fallback';
  }
}

// 3. Content widget (internal)
class _MyScreenContent extends StatelessWidget {
  final MyScreenConfig config;
  const _MyScreenContent({required this.config});
  // ...
}
```

## Menu Item

```dart
ScreenMenuItem(
  icon: Icons.info_outline,
  order: 900,               // Position in menu (lower = higher)
  showDividerBefore: true,  // Optional divider
)
```

## Providers

Use when the screen needs shared state:

```dart
@override
List<SingleChildWidget> get providers => [
  ChangeNotifierProvider(create: (_) => MyManager()),
  BlocProvider(create: (_) => MyCubit()),
];
```

Access in widgets:
```dart
final manager = context.watch<MyManager>();
final cubit = context.read<MyCubit>();
```

## Usage in App

```dart
TrufiAppConfig(
  screens: [
    AboutTrufiScreen(config: AboutScreenConfig(...)),
    TransportListTrufiScreen(config: TransportListOtpConfig(...)),
  ],
)
```

## Checklist

- [ ] Config class with required parameters
- [ ] TrufiScreen with unique `id` and `path`
- [ ] Localizations delegate exported
- [ ] `getLocalizedTitle` with fallback
- [ ] `menuItem` if shown in drawer/menu
- [ ] Providers if needed for state management
