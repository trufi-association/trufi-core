# Trufi Core v5 Architecture Plan

> Reference: [Issue #777](https://github.com/trufi-association/trufi-core/issues/777)

## Core Architecture

### Monorepo & Workspace
- [x] Flutter workspace configured (`pubspec.yaml`)
- [x] Melos scripts (analyze, format, test, clean)

### Routing
- [x] Go Router implementation

### State Management
- [ ] Bloc/Cubit migration (currently uses Provider)

### Dependency Injection
- [ ] Get_It implementation (currently uses manual singletons)

## Packages

### trufi_core_maps
- [x] 3-Layer Architecture (Presentation/Domain/Data)
- [x] Multiple map providers (FlutterMap, MapLibre)
- [x] Map controller abstraction
- [x] Tile system and caching

### trufi_core_routing
- [x] 3-Layer Architecture (Presentation/Domain/Data)
- [x] Domain entities (Plan, Itinerary, ItineraryLeg, etc.)
- [x] Repository interface (PlanRepository)
- [x] OTP 2.7 GraphQL implementation (advanced + simple queries)
- [x] Polyline decoder utility
- [x] Full migration from old routing_service code
- [x] PlanEntityAdapter for UI entity conversion
- [x] Removed legacy OTP Stadtnavi code (unused)

### trufi_core_location (planned)
- [ ] Location services abstraction
- [ ] Geocoding/reverse geocoding
- [ ] Search functionality

### trufi_core_feedback (planned)
- [ ] User feedback system
- [ ] Issue reporting

### trufi_core_settings (planned)
- [ ] User preferences
- [ ] App configuration

## Progress: 4/12 items complete
