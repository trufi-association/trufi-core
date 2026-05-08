import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart';

import 'models/transport_route.dart';
import 'transport_list_data_provider.dart';

/// Data provider that reads transport routes directly from a local GTFS zip asset.
///
/// Unlike [OtpTransportDataProvider], this provider shows every trip as a
/// separate entry, so no routes are merged or deduplicated by the server.
class GtfsTransportDataProvider extends TransportListDataProvider {
  final String _assetPath;

  GtfsData? _gtfsData;

  /// Mapping from trip ID to its ordered stop IDs (built on first load).
  Map<String, List<String>>? _tripStops;

  GtfsTransportDataProvider({required String assetPath})
      : _assetPath = assetPath;

  @override
  Future<void> load() async {
    if (state.routes.isNotEmpty) return;

    state = state.copyWith(isLoading: true);
    notifySafe();

    try {
      final bytes = await rootBundle.load(_assetPath);
      _gtfsData = GtfsParser.parseFromBytes(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      );

      final routes = _buildRoutes(_gtfsData!);

      state = state.copyWith(
        routes: routes,
        filteredRoutes: routes,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('GtfsTransportDataProvider: Error loading GTFS: $e');
      state = state.copyWith(isLoading: false);
    }
    notifySafe();
  }

  @override
  Future<void> refresh() async {
    _gtfsData = null;
    _tripStops = null;
    state = const TransportListState(isLoading: true);
    notifySafe();
    await load();
  }

  @override
  Future<TransportRouteDetails?> getRouteDetails(String code) async {
    final data = _gtfsData;
    if (data == null) return null;

    state = state.copyWith(isLoadingDetails: true);
    notifySafe();

    try {
      final trip = data.trips[code];
      if (trip == null) {
        state = state.copyWith(isLoadingDetails: false);
        notifySafe();
        return null;
      }

      final route = data.routes[trip.routeId];
      final agency = route?.agencyId != null
          ? data.agencies
                  .where((a) => a.id == route!.agencyId)
                  .firstOrNull
          : null;

      // Build stop list for this trip
      final stopIds = _getStopsForTrip(data, trip.id);
      final stops = stopIds
          .map((id) => data.stops[id])
          .where((s) => s != null)
          .map(
            (s) => TransportStop(
              id: s!.id,
              name: s.name,
              latitude: s.lat,
              longitude: s.lon,
            ),
          )
          .toList();

      // Get geometry from shape
      List<({double latitude, double longitude})>? geometry;
      if (trip.shapeId != null && data.shapes.containsKey(trip.shapeId)) {
        final shape = data.shapes[trip.shapeId]!;
        geometry = shape.points
            .map((p) => (latitude: p.lat, longitude: p.lon))
            .toList();
      }

      state = state.copyWith(isLoadingDetails: false);
      notifySafe();

      return TransportRouteDetails(
        id: trip.id,
        code: trip.id,
        name: trip.headsign ?? route?.longName ?? '',
        shortName: route?.shortName,
        longName: route?.longName,
        backgroundColor: _parseColor(route?.colorHex),
        textColor: _parseColor(route?.textColorHex),
        modeIcon: _getModeIcon(route?.type),
        agencyName: agency?.name,
        headsign: trip.headsign,
        directionId: trip.directionId?.value,
        geometry: geometry,
        stops: stops,
        modeName: route?.type.displayName,
      );
    } catch (e) {
      debugPrint('GtfsTransportDataProvider: Error loading details: $e');
      state = state.copyWith(isLoadingDetails: false);
      notifySafe();
      return null;
    }
  }

  // ============ Private helpers ============

  List<TransportRoute> _buildRoutes(GtfsData data) {
    final routes = <TransportRoute>[];

    // Build agency lookup
    final agencyMap = <String, GtfsAgency>{};
    for (final a in data.agencies) {
      agencyMap[a.id] = a;
    }

    // Sort trips by route shortName (numeric first) then by direction
    final sortedTrips = data.trips.values.toList()
      ..sort((a, b) {
        final routeA = data.routes[a.routeId];
        final routeB = data.routes[b.routeId];
        final shortA = routeA?.shortName ?? '';
        final shortB = routeB?.shortName ?? '';
        final numA = int.tryParse(shortA);
        final numB = int.tryParse(shortB);

        if (numA != null && numB != null) {
          final cmp = numA.compareTo(numB);
          if (cmp != 0) return cmp;
        } else if (numA == null && numB == null) {
          final cmp = shortA.compareTo(shortB);
          if (cmp != 0) return cmp;
        } else if (numA != null) {
          return -1;
        } else {
          return 1;
        }

        // Same shortName, sort by direction
        final dirA = a.directionId?.value ?? 0;
        final dirB = b.directionId?.value ?? 0;
        return dirA.compareTo(dirB);
      });

    for (final trip in sortedTrips) {
      final route = data.routes[trip.routeId];
      final agency = route?.agencyId != null ? agencyMap[route!.agencyId] : null;

      routes.add(TransportRoute(
        id: trip.id,
        code: trip.id,
        name: trip.headsign ?? route?.longName ?? '',
        shortName: route?.shortName,
        longName: route?.longName,
        backgroundColor: _parseColor(route?.colorHex),
        textColor: _parseColor(route?.textColorHex),
        modeIcon: _getModeIcon(route?.type),
        agencyName: agency?.name,
        headsign: trip.headsign,
        description: route?.description,
        directionId: trip.directionId?.value,
        serviceHours: _serviceHoursForTrip(data, trip),
      ));
    }

    return routes;
  }

  /// Build a [ServiceHours] for [trip] by combining its `calendar`
  /// (which days the service runs) with its `frequencies` (or
  /// `stop_times` as fallback) for the daily start/end window.
  ///
  /// Returns null if the feed has neither calendar nor any usable
  /// time bounds — the UI then suppresses the operating-hours card.
  ServiceHours? _serviceHoursForTrip(GtfsData data, GtfsTrip trip) {
    final calendar = data.calendars[trip.serviceId];
    if (calendar == null) return null;
    final days = <int>{
      if (calendar.monday) DateTime.monday,
      if (calendar.tuesday) DateTime.tuesday,
      if (calendar.wednesday) DateTime.wednesday,
      if (calendar.thursday) DateTime.thursday,
      if (calendar.friday) DateTime.friday,
      if (calendar.saturday) DateTime.saturday,
      if (calendar.sunday) DateTime.sunday,
    };
    if (days.isEmpty) return null;

    Duration? minStart;
    Duration? maxEnd;
    for (final f in data.frequencies) {
      if (f.tripId != trip.id) continue;
      if (minStart == null || f.startTime < minStart) minStart = f.startTime;
      if (maxEnd == null || f.endTime > maxEnd) maxEnd = f.endTime;
    }
    if (minStart == null || maxEnd == null) return null;

    return ServiceHours(
      daysOfWeek: days,
      startTime: TimeOfDay(
        hour: minStart.inHours % 24,
        minute: minStart.inMinutes % 60,
      ),
      endTime: TimeOfDay(
        hour: maxEnd.inHours % 24,
        minute: maxEnd.inMinutes % 60,
      ),
    );
  }

  List<String> _getStopsForTrip(GtfsData data, String tripId) {
    _tripStops ??= _buildTripStopsMap(data);
    return _tripStops![tripId] ?? [];
  }

  Map<String, List<String>> _buildTripStopsMap(GtfsData data) {
    final map = <String, List<GtfsStopTime>>{};
    for (final st in data.stopTimes) {
      map.putIfAbsent(st.tripId, () => []).add(st);
    }
    final result = <String, List<String>>{};
    for (final entry in map.entries) {
      entry.value.sort((a, b) => a.stopSequence.compareTo(b.stopSequence));
      result[entry.key] = entry.value.map((st) => st.stopId).toList();
    }
    return result;
  }

  Color? _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return null;
    try {
      final hex = colorHex.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return null;
    }
  }

  Widget? _getModeIcon(GtfsRouteType? type) {
    if (type == null) return null;
    IconData iconData;
    switch (type) {
      case GtfsRouteType.bus:
        iconData = Icons.directions_bus;
      case GtfsRouteType.tram:
        iconData = Icons.tram;
      case GtfsRouteType.subway:
        iconData = Icons.subway;
      case GtfsRouteType.rail:
        iconData = Icons.train;
      case GtfsRouteType.ferry:
        iconData = Icons.directions_ferry;
      case GtfsRouteType.cableTram:
      case GtfsRouteType.aerialLift:
        iconData = Icons.airline_seat_recline_extra;
      case GtfsRouteType.funicular:
        iconData = Icons.terrain;
      default:
        iconData = Icons.directions_transit;
    }
    return Icon(iconData, size: 16);
  }
}
