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
`VehicleEtaRequest` — the rider's origin, the routes of a plan and, per
route, the boarding stop the planner picked — with a `VehicleEtaSnapshot`
of `VehicleEta`s (one per reporting route, measured to that route's
boarding stop; to the origin for routes without one). On-demand
snapshot only: no streams, no background polling. Hand one to
`HomeScreenConfig.vehicleEtaProvider` to get "Arrives in ~N min" badges on
the itinerary cards (see the `trufi_core_home_screen` README).

### RealtimeVehiclesEtaProvider

Derives ETAs from a `RealtimeVehiclesProvider` snapshot: for each requested
route, the reporting vehicle with the soonest arrival (not the nearest one:
reported speeds count), by its straight-line distance to the route's
boarding stop (`VehicleEtaRequest.pointFor`; the rider's origin when the
request carries no boarding point) over its reported speed (when plausible)
or over an average speed.

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
from a bundled-GTFS plan). Vehicles that cannot reach the boarding stop on
this trip are skipped (#1016), on two signals applied in turn:

1. **GTFS `direction_id`**, when both the plan's leg and the vehicle carry
   it: a bus on the opposite pattern is out however close it is. A match is
   not a pass — the heading is still checked, so a same-pattern bus that
   already went by does not win on distance. OTP reports no `direction_id`
   for a loop whose direction is irrelevant; such vehicles rely on the
   heading.
2. **Reported heading**, for a moving vehicle (speed ≥ 1 m/s, or no speed at
   all — the heading is a compass reading, independent of it): more than 90°
   off the straight-line bearing to the stop means it is driving away, and
   it is dropped. Within 30 m of the stop the bearing is GPS noise and the
   test is skipped.

A vehicle known to be stopped, or without a heading, is kept whatever it
points at, and route geometry is still ignored (straight-line distance): a
feed with neither signal gets the previous behaviour, the soonest vehicle
wherever it goes. When every reporting vehicle of a route is filtered out
the route is absent from the snapshot and the badge reads "Live ETA
unavailable".

### Your own provider

Implement `VehicleEtaProvider.fetchEtas` for any other backend (SIRI, a city
API, ...). Return an empty snapshot when nothing is reporting and throw
`VehicleEtaException` when the source cannot answer.
