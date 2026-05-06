## 5.12.0

### Breaking
- `trufi_core_fares` data model is rebuilt around arbitrary categories instead of fixed regular/student/senior slots (#848). `FareInfo` now requires a `title`, an `icon`, a `primary: FareCategory`, an optional `additional: List<FareCategory>` and an optional `notes`. The old `transportType`/`regularFare`/`studentFare`/`seniorFare` fields are removed — apps need to migrate their wiring to the new `FareCategory(label, price, icon?, color?, note?)` tuple. The previous schema couldn't represent tariffs that have more than three age tiers (e.g. Cochabamba's official Cercado tariff covers `general / primary student / secondary‑uni student / disability / senior`), and locked the chip labels into the package's localization (`faresStudent`, `faresSenior`).
- `FaresLocalizations` no longer ships the `faresRegular`, `faresStudent`, `faresSenior` strings. Category labels come from each app's own localization (or raw strings) via `FareCategory.label`. Apps that built their own fares screen on top of `FaresLocalizations` strings need to provide the labels themselves.

### Features
- `trufi_core_fares` exposes its previously-private layout primitives as public widgets so apps can compose a custom fares screen without rewriting the chrome: `FaresHero` (gradient hero card), `FareCard` (header + chips + notes for one `FareInfo`), `FareCategoryChip` (single category chip), `FaresNotesCard` (tip-style footer card). The opinionated `FaresTrufiScreen(config: …)` keeps working as before for apps that don't need a custom layout.

### Bug Fixes
- Fix outdated Cochabamba fares (#848). `trufi-app` now ships the official Cercado tariff issued by the Movilidad Urbana de Cochabamba (`Bs 3 / Bs 2 / Bs 1 / Bs 2.50 / Bs 2.50` for general / secondary‑university student / primary student / senior / disability) and a note clarifying the tariff applies only inside the Cercado and that operator-charged fares may differ.

---

## 5.11.0

### Breaking
- `TrufiPlannerProvider` now suppresses transfer itineraries when at least one direct option exists (#859). Previously, transfers and directs were merged in the same result list — apps showed `133 → X10` next to `X10` direct for the same trip, which is misleading because each ride is a separate fare and the transfer is rarely worth the cost. With strict-direct-vs-transfer split, transfers only appear when no direct exists. Apps that relied on always seeing both classes need to either accept the new behavior or call `findRoutes` with their own filter on top.
- `TrufiPlannerProvider.name` no longer differentiates local/remote ("Offline (GTFS)" / "Online (Public Transport)"). Both modes return `"Trufi Planner"`. Apps that compare against the old strings need to update; apps using `config.displayName` are unaffected.
- Removed the `Maximum walking distance` preferences UI from the Trufi Planner provider — the chip was wired to a server parameter the backend ignored, so toggling it had no effect. Internal classes `TrufiPlannerPreferencesState` and `TrufiPlannerPreferences` are deleted (they were not exported). The provider now ships a "Acerca de Trufi Planner" info card explaining the engine instead.
- Frontend itinerary sort in `routing_engine_request_plan_service.dart` is removed — each provider owns its ranking now. OTP providers already return sorted itineraries; `TrufiPlannerProvider` ranks via the backend (distance-based) plus walk-only injection at index 0.

### Features
- Walk-only itinerary auto-injected at the top of the result list when origin and destination are within 1.5 km in straight line. Renders as a single dashed leg from origin to destination, time = `distance / 1.2 m/s`. Spares the user from being shown a 3-block bus trip when walking is the obvious option.
- `TrufiPlannerProvider` settings sheet now shows an "Acerca de Trufi Planner" card that explains the engine and offline/online mode (different copy for `config.isLocal` vs remote). Replaces the non-functional walking-distance chips.
- Backend `gtfs_routing_service` ranks paths by total distance (`walkDistance + transitDistance`). Drops the time-based weighting that was skewed by schedule-driven transfer waits — e.g. a fast transfer no longer beats a direct just because its scheduled wait is 1 minute shorter.
- Pattern-level performance work in `gtfs_route_index`: precomputed `cumDist` (cumulative haversine distance per stop) and per-pattern bbox enable O(1) "is this pattern near point P" pruning before heavier per-stop work. Bench p99 ~9ms on 200 random Cochabamba queries.

### Bug Fixes
- Fix the absurd routes reported in #859 (e.g. `209 → 209` taking 7.4 km / 32 min for a 400 m straight-line trip). Root cause was the old `transfers*1000 + walkDistance*2 + transitDistance*1` score letting transit-only distance dominate after walking penalties cancelled out across competing paths. With distance-based scoring + strict-direct-vs-transfer split + the upstream feed densification ([trufi-association/trufi-app PR](https://github.com/trufi-association/trufi-app/pulls?q=is%3Apr+v2.12.0)), the same query now returns 5 sensible direct options.

---

## 5.10.0

### Features
- `TrufiLatLng.distanceTo(other)` returns the great-circle distance (meters) between two coordinates.

### Bug Fixes
- Fix routing deadlock when picking a POI as origin or destination right after clearing the other field (#839). The POI handlers (`_setPoiAsOrigin` / `_setPoiAsDestination` in `home_screen.dart`) were not awaiting the cubit's `setFromPlace` / `setToPlace` calls, so `_fetchPlanIfReady()` ran before the new place was emitted to state, saw `isPlacesDefined == false`, and skipped the fetch. The result on screen was: place gets set a moment later, but no plan is ever requested — the empty "Buscar una ruta" panel is stuck. Other entry points (search-result selection, long-press → "Set as destination") were already correctly awaiting and are unaffected.
- Rename the `TrufiPlannerProvider` default remote-mode display name from `Online (Planner)` to `Online (Public Transport)` (#839, second part). The previous label suggested a generic walking planner; the new one tells the user upfront that the engine returns public-transit itineraries. Apps that override `config.displayName` are unaffected.
- Fix inverted origin/destination markers on the route detail map for `directionId=1` patterns (#870). The transport detail screen used to reverse `route.stops` whenever `directionId == 1`, but the backend already delivers stops in trip order (first = origin, last = destination) for both directions, so the reversal swapped the green/red markers (and the bottom-sheet stop list) on the return-direction patterns. Affects `Otp28RoutingProvider` consumers (Cochabamba and Trujillo); `Otp15RoutingProvider` and the offline `TrufiPlannerProvider` were already correct because they don't surface `directionId`.
- Block route planning when origin and destination are within 100 m of each other (#821). Previously, identical points caused the routing engine to either return a 404 (OTP 1.5) or a nonsensical itinerary (OTP 2.8). The new banner message asks the user to walk instead. Provider-agnostic: applies to OTP 1.5/2.4/2.8 and the offline GTFS planner.
- Standardize transport list display across providers (#832). `Otp15RoutingProvider` was failing to match patterns to their parent route (incorrect parsing of pattern id `feedId:routeId:directionId:patternIndex`), so route badges were empty and route names fell back to the raw OTP `desc` field, which leaks identifiers like `(cochabamba:3663487388)`. The match is now correct and `agencyName` is parsed for both `Otp15RoutingProvider` and `TrufiPlannerProvider`'s offline (GTFS) mode, bringing both to parity with `Otp28RoutingProvider`.

---

## 5.9.0

### Breaking
- `SocialMediaLink.icon` is now `Widget` instead of `IconData`. Apps that pass an `IconData` must wrap it: `icon: Icons.facebook` → `icon: const Icon(Icons.facebook)`. The migration is mechanical and small (1 line per link).

### Features
- New `SocialMediaPreset` enum (exported from `trufi_core_ui`) with brand-correct icons for Facebook, Instagram, WhatsApp and Twitter/X. Use as `icon: SocialMediaPreset.instagram.icon`. Brand SVGs sourced from [Simple Icons](https://simpleicons.org) (CC0 1.0). Inherits color from the ambient `IconTheme`.
- `trufi_core_ui` declares `flutter_svg` as a direct dependency (was already transitive via `trufi_core_maps`).

---

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
