# trufi_core_routing

Route planning for Trufi apps: OpenTripPlanner clients (1.5 REST, 2.4 and
2.8 GraphQL), the bundled-GTFS Trufi planner, GTFS-Realtime vehicle
positions and pluggable "next vehicle" ETA providers. Pure routing, no map
widgets — pair it with `trufi_core_maps` for rendering.

## Features

- `Otp15RoutingProvider`, `Otp24RoutingProvider`, `Otp28RoutingProvider`
  and `TrufiPlannerProvider` (local GTFS or remote planner API) behind one
  `IRoutingProvider` interface.
- `RoutingEngineManager` to register several engines and let the user (or
  an auto-fallback) pick one.
- Itinerary grouping and filtering (`groupItineraries`,
  `filterMaxTransitLegs`).
- `OtpVehiclePositionsProvider`: live GTFS-RT vehicle positions polled from
  OTP 2.x (`RealtimeVehiclesProvider` from `trufi_core_interfaces`).
- Vehicle ETA providers (`VehicleEtaProvider`): `RealtimeVehiclesEtaProvider`
  derives "next vehicle" estimates from live positions; external telemetry
  services implement the same interface.

## Quick Start

```dart
final routing = RoutingEngineManager(
  engines: [
    TrufiPlannerProvider(
      config: const TrufiPlannerConfig.local(
        gtfsAsset: 'assets/routing/city.gtfs.zip',
      ),
    ),
    Otp28RoutingProvider(endpoint: 'https://otp.example.com'),
  ],
);
```

Register it as a `ChangeNotifierProvider` in `AppConfiguration.providers`;
`trufi_core_home_screen` reads it from the context.

## Realtime vehicles

`Otp28RoutingProvider(liveVehiclesEnabled: true)` exposes a lazily-created
`OtpVehiclePositionsProvider` through `realtimeVehiclesProvider`. The home
screen subscribes to it and shows the "Live buses" toggle automatically.

```dart
final otp28 = Otp28RoutingProvider(
  endpoint: 'https://otp.example.com',
  liveVehiclesEnabled: true,
  liveVehiclesPollInterval: const Duration(seconds: 10),
);

// Continuous polling (what the "Live buses" layer does):
await otp28.realtimeVehiclesProvider!.start();

// One query, no timer (what the ETA badges do):
final fleet = await otp28.realtimeVehiclesProvider!.fetchOnce();
```

`fetchOnce()` updates `latest`, emits on `positionsStream` and throws
`OtpVehiclePositionsException` on GraphQL errors; network errors propagate.

## Vehicle ETA providers

A `VehicleEtaProvider` (defined in `trufi_core_interfaces`) answers one
`VehicleEtaRequest` — the rider's origin plus the routes of a plan — with a
`VehicleEtaSnapshot` of `VehicleEta`s (one per reporting route). On-demand
snapshot only: no streams, no background polling. Hand one to
`HomeScreenConfig.vehicleEtaProvider` to get "Arrives in ~N min" badges on
the itinerary cards (see the `trufi_core_home_screen` README).

### RealtimeVehiclesEtaProvider

Derives ETAs from a `RealtimeVehiclesProvider` snapshot: for each requested
route, the nearest reporting vehicle's straight-line distance to the origin
over its reported speed (when plausible) or over an average speed.

```dart
final otp28 = Otp28RoutingProvider(
  endpoint: 'https://otp.example.com',
  liveVehiclesEnabled: true,
);

final etaProvider = RealtimeVehiclesEtaProvider(
  vehicles: otp28.realtimeVehiclesProvider!,
  // Fresh query per plan/refresh even while the live layer is off:
  snapshotLoader: otp28.realtimeVehiclesProvider!.fetchOnce,
);
```

| Parameter | Default | Meaning |
|---|---|---|
| `vehicles` | required | Source of positions; `latest` is used when no `snapshotLoader` is given |
| `snapshotLoader` | `null` | One-shot loader (e.g. `fetchOnce`) run on every request |
| `averageSpeedKmh` | `15` | Speed assumed when a vehicle reports none or an implausible one (< 3.6 or > 108 km/h) |
| `maxDistanceMeters` | `10000` | Vehicles farther away are ignored |
| `maxVehicleAge` | `5 min` | Reports older than this are ignored |
| `now` | `DateTime.now` | Injectable clock (tests) |

Route ids are matched feed-agnostically (`1:1132` from OTP matches `1132`
from a bundled-GTFS plan). Direction and route geometry are ignored in this
MVP, so a vehicle driving away still yields an ETA.

### Your own provider

Implement `VehicleEtaProvider.fetchEtas` for any other backend (SIRI, a city
API, ...). Return an empty snapshot when nothing is reporting and throw
`VehicleEtaException` when the source cannot answer.
