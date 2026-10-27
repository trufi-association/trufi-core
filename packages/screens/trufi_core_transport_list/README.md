# trufi_core_transport_list

Routes list, route detail, the operator QR sheet, and the nearby lines screen.

## Host-app requirements

### Operator QR codes

Pass `shareBaseUrl` to `TransportListTrufiScreen` with the app's **https**
base (e.g. `https://planner.trufi.app`). The QR encodes
`<base>/routes?operator=<agency>`.

A QR is read by a camera app, which resolves http(s) and nothing else — a
custom scheme such as `trufiapp://` produces a code that opens nothing, so
without a usable https base the QR affordances stay hidden by design. (A
custom-scheme link shared through other channels also only opens the app if
the host manifest declares a matching intent filter, e.g.
`android:host="routes"`.)

For the scanned link to open the **app** (rather than the website) the host
app must register it as an App Link / Universal Link: an intent filter for
that host with `android:autoVerify="true"`, plus a matching
`assetlinks.json` (Android) and `apple-app-site-association` (iOS) served
from the domain. On Android the verification uses the **signing key the
store re-signs with**, so App Links only resolve on store-installed builds
— a locally built APK opens the browser instead. Without any of this the
link still works: it falls back to the web app.

### Copying the QR image

"Copy QR" hands a rendered PNG to the clipboard through the `pasteboard`
plugin, which needs a `FileProvider` in the **host app's** manifest —
without it copying fails at runtime with a `PlatformException`, surfaced in
the dialog as "Couldn't copy the QR":

```xml
<provider
    android:name="androidx.core.content.FileProvider"
    android:authorities="${applicationId}.provider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/provider_paths" />
</provider>
```

with `android/app/src/main/res/xml/provider_paths.xml`:

```xml
<paths xmlns:android="http://schemas.android.com/apk/res/android">
    <cache-path name="cache" path="." />
</paths>
```

`cache-path` is the root that matters — the plugin writes the PNG to the
app's internal cache. (The plugin's own README documents only
`external-path`, which leaves copying failing with *"Failed to find
configured root that contains /data/data/&lt;pkg&gt;/cache/…"*.)

## Route detail without stops

Cities with no stops mapped get a feed whose stops are synthetic — the GTFS
builder invents one every 100 m along each shape — and the route detail
would present them as real: a "Stops" timeline of street names, a stop count
in the hundreds and a dotted line on the map (trufi-sanaa#18). Pass
`showStops: false` to keep them out:

```dart
TransportListTrufiScreen(showStops: false),
NearbyLinesTrufiScreen(showStops: false),
```

The detail then shows the line on the map with its two end pins (taken from
the shape itself), the route identity, operating hours, distance and mode.
On phones the draggable stops sheet becomes a fixed summary card, so the map
keeps the whole screen; the wide side panel just drops its stops section.
The origin/destination labels come from a `route_long_name` of the form
`A → B` and never from the first/last stop. `TransportDetailScreen` takes
the same `showStops` when embedded directly.

## Nearby lines screen

`NearbyLinesTrufiScreen` (`/nearby`, drawer order 2) lists the lines passing
within **100 / 300 / 500 m** of the rider's position or of a pin placed on the
map, with the three radii drawn as rings, a label at the closest stop or point
of every line, and the full route highlighted when a row is tapped. The whole
query runs on the device against the planner's already-loaded GTFS — no
network call anywhere (#1006).

```dart
screens: [
  HomeScreenTrufiScreen(...),
  TransportListTrufiScreen(),
  NearbyLinesTrufiScreen(),
],
```

### Requirements

- A `MapEngineManager` in the app providers (the map and the default center).
- A **local** `TrufiPlannerProvider` among the `RoutingEngineManager` engines:

  ```dart
  TrufiPlannerProvider(
    config: const TrufiPlannerConfig.local(gtfsAsset: 'assets/routing/city.gtfs.zip'),
  )
  ```

  The screen picks the first local planner it finds, whichever engine is
  currently selected, and preloads it when needed. Without one (remote-only
  planner, e.g. the example on web) it shows "Nearby lines need the offline
  GTFS planner" instead of failing. Any other feed can be plugged through
  `dataSourceBuilder` by implementing `NearbyLinesDataSource`.

### How a line is matched

Stops within 500 m come from the planner's spatial index; route geometries
are tested with a bounding-box prefilter and a point-to-polyline distance.
A row reads **"At X m · Stop …"** when the nearest stop is the way to board,
and **"Passes by at X m · To …"** when the route runs more than 50 m closer
than any of its stops (`NearbyLinesService.stopPreferenceMeters`). Routes the
planner treats as one logical line (same `route_short_name`, outbound and
inbound) are one row. The 100/300 m chips only filter the 500 m result, so
switching them never re-queries.

### Location and the pin

On every visit the screen asks for the device position (one permission
request when merely denied; no dialogs). Permanently denied, services off or
no fix within 10 s fall back to `MapEngineManager.defaultCenter` with a hint:
long-press the map to move the pin anywhere, "Use my location" re-anchors.

### Lines along a street

The same screen answers "which lines run along this street?"
(trufi-sanaa#20). The feed relates routes to geometries, not to streets, so
the answer is built from what the offline search index knows about a street:
its corners. `NearbyLinesTrufiScreen.showAlongStreet(context, street)` pushes
`/nearby` with a `NearbyStreetAnchor` (name + corner points) as the route's
`extra`; the cubit runs the nearby query from every corner and keeps each
line once, at its nearest corner (`NearbyLinesResult.union`). The rows are
ordered by how many corners each line passes within 100 m of, most first:
on a street every line that crosses it is 0 m from the corner it crosses
at, so the order — not the distance — is what tells the lines running along
the street from the ones merely crossing it (a crossing line is still
listed: the rider can board it at that corner). The header reads "Along
<street> · <municipality>" (the `subtitle`, when the index carries one —
Cochabamba has one "Avenida Circunvalación" per municipality; a long press
shows the whole text), the map shows a dot per corner instead of the rings
and the pin, the chips filter by the distance to the nearest corner. A
long-press or "Use my location" leaves the street again.

The search screen offers the row when the host app wires it:

```dart
HomeScreenTrufiScreen(
  onLinesAlongStreet: (context, street, corners) =>
      NearbyLinesTrufiScreen.showAlongStreet(
        context,
        NearbyStreetAnchor(
          name: street.displayName,
          subtitle: street.address,
          corners: [for (final c in corners) LatLng(c.latitude, c.longitude)],
        ),
      ),
)
```

It needs an `OfflineSearchDataService` with a `search.json` that carries
`streetJunctions` (the `osm-search-data-export` json-compact output): a city
whose offline search has no streets (POI-only) never shows the row.

### Route detail

The chevron of a row opens `TransportDetailScreen` with details built from
the local feed (`nearbyLineToRouteDetails`), so it works whichever routing
engine is current. Apps whose routes list is served by
`GtfsTransportDataProvider` can route through their own list instead:

```dart
NearbyLinesTrufiScreen(
  onLineDetails: (context, line) =>
      TransportDetailScreen.show(context, routeCode: line.tripId!),
)
```

### Limits

- The rings are outlines; no map engine renders a translucent buffer yet
  (`TrufiMarker.metersRadius` is not consumed and line colors carry no alpha).
- One row per logical line: the headsign shown is the closest pattern's.
- At most 40 line labels are drawn on the map; the list is complete.
