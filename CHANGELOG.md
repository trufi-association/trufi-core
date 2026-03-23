## 5.6.0

### Features
- UI improvements (#866)
- Maps migration: restructured maps architecture (#862)

---

## 5.5.0

### Maintenance
- Update pubspec.lock files to fix CI l10n check
- Add release workflow for automated GitHub releases on tags

---

## 5.4.0

### Features
- Add topWidget parameter to DefaultInitScreen
- Add l10n support to routing preferences and navigation UI (en/es/de)
- Add showBicycleOption to OTP 2.8 provider for per-app transport mode control
- Add web-based route sharing and allow https deep links
- Add stepTextBuilder parameter to DefaultInitScreen for localization
- Add logo, drawerFooterExtra, and bottomWidget support for app branding
- Add boarding/alighting stop markers on itinerary map
- Make About screen sections configurable via List<Widget>
- Add configurable appTagline to replace hardcoded drawer tagline
- Pass appName from config to drawer instead of hardcoding 'Trufi App'
- Add estimated travel times disclaimer banner to itinerary list
- Add agency grouping, headsign, and directionId to transport list
- Make language options dynamic based on supportedLocales from LocaleManager
- Add showWheelchairOption to Otp28RoutingProvider to allow hiding wheelchair setting

### Bug Fixes
- Fix maps rendering issues
- Improve transit markers, fix color contrast, and default walk distance to 800m
- Localize hardcoded strings in transport list empty state
- Fix FlutterMapEngine example missing localizedName/Description overrides
- Simplify feedback screen: remove non-functional chevrons and URL params
- Improve 'No routes found' error with localized descriptive messages
- Deduplicate patterns by shortName + directionId
- Fix text contrast on route badges with light background colors
- Fix hardcoded English 'routes found' string to use l10n
- Fix stops panel: expand to 85%, pin header, dynamic min height (#834)
- Fix delete confirmation showing closure reference instead of message (#854)
- Fix new saved place pre-filling location instead of prompting user to select (#855)
- Fix l10n: correct accents, translate English strings, remove Bolivian references (#852, #853)

### Maintenance
- Remove unused maplibre dependency from maps package and example app
- Refactor maps architecture: simplify TrufiLayer API and centralize rendering in TrufiMap
- Add localized name/description support to map engines
- Update pubspec.lock files across packages

---

## 5.3.0

### Features
- Refactor routing preferences integration tests and update repository (#814)

---

## 5.2.0

### Features
- Integrate planner functionality (#813)

---

## 5.1.2

### Bug Fixes
- Fix OTP routing issues (#811)

---

## 5.1.1

### Features
- Enhance configuration documentation and integrate OTP routing in HomeScreen and TransportList (#810)

---

## 5.1.0

### Features
- Improve performance (#809)

---

## 5.0.0

### ✨ Features

#### New Translation Workflow ([#628](https://github.com/trufi-association/trufi-core/issues/628))
- Complete refactor of the localization system across all screens
- Added POI layers translations to HomeScreen ([#807](https://github.com/trufi-association/trufi-core/pull/807))
- New translation workflow for: About, Feedback, Fares, Saved Places, Transport List, Settings, and Home screens
- Added scripts for language generation, build and translations
- Added nullable getter to each l10n file
- Added translation check to the pipeline

#### Map & POI Layers
- Implement Map POI layers ([#805](https://github.com/trufi-association/trufi-core/pull/805))
- Enhance fit camera layer functionality and improve route visibility handling ([#802](https://github.com/trufi-association/trufi-core/pull/802))

#### Persistent Storage
- Implement persistent storage for map engine, locale, and theme ([#803](https://github.com/trufi-association/trufi-core/pull/803))
- Implement SharedPreferencesStorage for persistent data management ([#801](https://github.com/trufi-association/trufi-core/pull/801))

#### Core Architecture
- Add core UI package and main app structure for Trufi ([#800](https://github.com/trufi-association/trufi-core/pull/800))
- Add trufi interfaces package with models/entities and interfaces
- Added module system with service locator (get_it)
- Added storage module for customizable database support
- Implement trufi_core_maps ([#782](https://github.com/trufi-association/trufi-core/pull/782))
- Implement trufi_core_routing ([#786](https://github.com/trufi-association/trufi-core/pull/786))

#### UI Components
- Refactor transport list and detail sheet UI for modern design ([#799](https://github.com/trufi-association/trufi-core/pull/799))
- Add transport list feature with localization and route details ([#797](https://github.com/trufi-association/trufi-core/pull/797))
- Add saved places management package with UI ([#798](https://github.com/trufi-association/trufi-core/pull/798))
- Add settings localization and settings screen ([#795](https://github.com/trufi-association/trufi-core/pull/795))
- Add UI extensions for trufi_core_routing ([#790](https://github.com/trufi-association/trufi-core/pull/790))

#### Deep Links
- Replace uni_links with app_links ([#773](https://github.com/trufi-association/trufi-core/pull/773))
- Enable deeplinks in example app

#### Build System
- Added melos and restructured project ([#777](https://github.com/trufi-association/trufi-core/pull/777))
- Single analysis_options configuration for all packages

### 🐛 Bug Fixes

- Initialize Hive with specified path in initHiveForFlutter ([#781](https://github.com/trufi-association/trufi-core/pull/781))
- Fixed Gradle configuration for Android builds ([#771](https://github.com/trufi-association/trufi-core/pull/771))
- Fixed version mismatch of intl
- Added missing iOS permissions for location access
- Fixed concurrency issue in l10n scripts

### 🔧 Maintenance

- Upgraded Flutter and Java versions
- Updated SDK and Flutter version constraints across packages
- Removed generated files from version control
- Added analyzer to melos and fixed linting issues
- Updated license information for all packages
- Updated readme files for new packages

---

## 4.1.0
🎉 Migrated sdk to Flutter 3.24.3
🎉 Example project was deleted.

## 4.0.0

### Flutter Version = 3.3.3

### Breaking Changes
- **Cubit Name Change**: The name of the `MapRouteCubit` has been updated to `RoutePlannerCubit`. If you were using the `MapRouteCubit` in your codebase, please update your references to use the new name `RoutePlannerCubit`.

- **Cubit Name Change**: The name of the `MapRouteCubit` has been updated to `RoutePlannerCubit`. If you were using the `MapRouteCubit` in your codebase, please update your references to use the new name `RoutePlannerCubit`.

## 2.0.0  
🎉 Support for Flutter 2.8.1
🎉 A new way of Custom Translations
🎉 Usage of the gen-l10n way for translations

## 0.0.1

* TODO: Describe initial release.
