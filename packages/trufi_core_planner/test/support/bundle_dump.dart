import 'package:trufi_core_planner/trufi_core_planner.dart';

/// Canonical text of everything a [PlannerIndexBundle] holds: every field of
/// the parsed [GtfsData] and of the three indices, in enumeration order.
///
/// Calendar instants are written as `year-month-day` plus the UTC flag: the
/// parser builds them with `DateTime(y, m, d)` in local time, so the instant
/// depends on the machine's timezone while the day does not. Everything
/// else is exact (`double.toString()` round-trips).
///
/// Used by the `format version guard` test — its digest is pinned, so any
/// change in what the parser or an index produces from the same GTFS fails
/// the suite until `PlannerIndexCodec.formatVersion` is bumped — and by the
/// review tools to compare a built bundle with a restored one.
String describeBundle(PlannerIndexBundle b) {
  final sb = StringBuffer();
  final d = b.data;
  String day(DateTime t) =>
      '${t.year}-${t.month}-${t.day}${t.isUtc ? 'Z' : ''}';
  String dur(Duration? x) => x == null ? '-' : '${x.inMicroseconds}';

  sb.writeln(
    'knobs ${b.routeIndex.transferRadiusMeters} '
    '${b.routeIndex.sameNameRouteLimit}',
  );
  for (final a in d.agencies) {
    sb.writeln(
      'A ${a.id}|${a.name}|${a.url}|${a.timezone}|${a.lang}|'
      '${a.phone}|${a.fareUrl}|${a.email}',
    );
  }
  for (final s in d.stops.values) {
    sb.writeln(
      'S ${s.id}|${s.code}|${s.name}|${s.description}|${s.lat}|'
      '${s.lon}|${s.zoneId}|${s.url}|${s.locationType}|${s.parentStation}|'
      '${s.timezone}|${s.wheelchairBoarding}|${s.platformCode}',
    );
  }
  for (final r in d.routes.values) {
    sb.writeln(
      'R ${r.id}|${r.agencyId}|${r.shortName}|${r.longName}|'
      '${r.description}|${r.type}|${r.url}|${r.colorHex}|${r.textColorHex}|'
      '${r.sortOrder}',
    );
  }
  for (final t in d.trips.values) {
    sb.writeln(
      'T ${t.id}|${t.routeId}|${t.serviceId}|${t.headsign}|'
      '${t.shortName}|${t.directionId}|${t.blockId}|${t.shapeId}|'
      '${t.wheelchairAccessible}|${t.bikesAllowed}',
    );
  }
  for (final st in d.stopTimes) {
    sb.writeln(
      'ST ${st.tripId}|${dur(st.arrivalTime)}|${dur(st.departureTime)}|'
      '${st.stopId}|${st.stopSequence}|${st.stopHeadsign}|${st.pickupType}|'
      '${st.dropOffType}|${st.shapeDistTraveled}|${st.timepoint}',
    );
  }
  for (final c in d.calendars.values) {
    sb.writeln(
      'CAL ${c.serviceId}|${c.monday}${c.tuesday}${c.wednesday}'
      '${c.thursday}${c.friday}${c.saturday}${c.sunday}|${day(c.startDate)}|'
      '${day(c.endDate)}',
    );
  }
  for (final cd in d.calendarDates) {
    sb.writeln('CD ${cd.serviceId}|${day(cd.date)}|${cd.exceptionType}');
  }
  for (final f in d.frequencies) {
    sb.writeln(
      'F ${f.tripId}|${dur(f.startTime)}|${dur(f.endTime)}|'
      '${f.headwaySecs}|${f.exactTimes}',
    );
  }
  for (final sh in d.shapes.values) {
    sb.writeln('SH ${sh.id} ${sh.points.length}');
    for (final p in sh.points) {
      sb.writeln(
        '  ${p.shapeId}|${p.lat}|${p.lon}|${p.sequence}|'
        '${p.distTraveled}',
      );
    }
  }

  final index = b.routeIndex;
  for (var i = 0; i < index.patternCount; i++) {
    final p = index.patternById(i);
    sb.writeln(
      'P ${p.id}|${p.routeId}|${p.headsign}|${p.shapeId}|'
      '${p.stopIds.join(',')}|${p.cumDist.join(',')}|'
      '${p.minLat},${p.minLon},${p.maxLat},${p.maxLon}',
    );
    final c = index.getConnectionsFor(i);
    for (var k = 0; k < c.length; k++) {
      sb.writeln(
        '  C ${c.otherPatternIdAt(k)} ${c.myStopIdxAt(k)} '
        '${c.otherStopIdxAt(k)} ${c.walkMetersAt(k)}',
      );
    }
  }
  for (final r in d.routes.values) {
    sb.writeln(
      'L ${r.id}|${index.lineKeyForRoute(r.id)}|'
      '${index.getPatternsForRoute(r.id).map((p) => p.id).join(',')}',
    );
  }
  for (final s in d.stops.values) {
    sb.writeln(
      'AT ${s.id}|'
      '${index.getPatternsAtStop(s.id).map((p) => p.id).join(',')}|'
      '${index.getRoutesAtStop(s.id).join(',')}',
    );
  }

  sb.writeln('KD ${b.spatialIndex.preorder.map((s) => s.id).join(',')}');

  for (final e in b.scheduleIndex.stopTimesByStop.entries) {
    sb.writeln(
      'SCH ${e.key}|${e.value.map((st) => '${st.tripId}/'
          '${st.stopSequence}/${dur(st.arrivalTime)}/'
          '${dur(st.departureTime)}').join(',')}',
    );
  }
  return sb.toString();
}
