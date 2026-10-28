import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core/base/models/enums/transport_mode.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/transit_route/transit_route.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/simple_opening_hours.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/transport_frecuency.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/transport_opening_hours.dart';

/// `routes.txt` of the Jilotepec feed (rutometro `GTFS/out/jilotepec`,
/// feed_version 2025-11-14): route_id → route_long_name.
Map<String, String> jilotepecRoutes() {
  final lines = File('test/fixtures/jilotepec_routes.txt').readAsLinesSync();
  expect(lines.first,
      'route_id,agency_id,route_short_name,route_long_name,route_color,route_type');
  return {
    for (final line in lines.skip(1).where((l) => l.trim().isNotEmpty))
      line.split(',')[0]: line.split(',')[3],
  };
}

void main() {
  // 2026-10-26 is a Monday.
  final monday = DateTime(2026, 10, 26);
  final week = List.generate(7, (i) => monday.add(Duration(days: i)));

  test('departure-based routes resolve through transportScheduleOf', () {
    expect(transportFrecuency, isNotEmpty);
    for (final entry in transportFrecuency.entries) {
      expect(transportOpeningHours.containsKey(entry.key), isFalse,
          reason: '${entry.key} is in both maps');
      expect(transportScheduleOf(entry.key), entry.value);
    }
    // Terminal → Chapa de Mota (ANASA): an all-day window, as before.
    expect(transportScheduleOf('19528579'), 'Mo-Su 07:40-20:10');
    expect(transportScheduleOf('0'), isNull);
    expect(transportScheduleOf(null), isNull);
  });

  test('a Jilotepec pattern code resolves a departure-based schedule', () {
    // OTP pattern codes: <feedId>:<routeId>:<direction>:<index>.
    const route = TransitRoute(
      id: 'amlsb3RlcGVjOjE5NTI1NjY3OjA6MDE=',
      name: 'Mercado → Doxhicho',
      code: 'jilotepec:19525667:0:01',
    );
    final openingHours = route.getOpeningHours;
    expect(openingHours, isNotNull);
    expect(openingHours!.departuresOn(monday), ['17:30']);
    expect(openingHours.rangesOn(monday), isEmpty);

    const unknown = TransitRoute(id: 'x', name: 'x', code: 'jilotepec:1:0:01');
    expect(unknown.getOpeningHours, isNull);
    const malformed = TransitRoute(id: 'x', name: 'x', code: 'nocolons');
    expect(malformed.getOpeningHours, isNull);
  });

  test('an itinerary leg resolves a departure-based schedule by routeId', () {
    Leg leg(String? routeId) => Leg(
          points: '',
          transportMode: TransportMode.bus,
          route: null,
          routeColor: null,
          routeTextColor: null,
          shortName: 'Mano Amiga',
          routeLongName: 'Mercado → Doxhicho',
          routeId: routeId,
          distance: 0,
          duration: Duration.zero,
          toPlace: const Place(lat: 0, lon: 0),
          fromPlace: const Place(lat: 0, lon: 0),
          agencyName: null,
          startTime: monday,
          endTime: monday,
          intermediatePlaces: null,
          transitLeg: true,
        );
    final openingHours = leg('jilotepec:19525667').getOpeningHours;
    expect(openingHours, isNotNull);
    expect(openingHours!.departuresOn(monday), ['17:30']);
    expect(leg('jilotepec:19528579').getOpeningHours!.rangesOn(monday),
        ['07:40-20:10']);
    expect(leg(null).getOpeningHours, isNull);
    expect(leg('jilotepec:1').getOpeningHours, isNull);
  });

  test('every route of the Jilotepec feed has a schedule with service', () {
    final routes = jilotepecRoutes();
    expect(routes, hasLength(76));
    final silent = <String>[];
    for (final entry in routes.entries) {
      final schedule = transportScheduleOf(entry.key);
      if (schedule == null) {
        silent.add('${entry.key} ${entry.value}: no entry');
        continue;
      }
      final openingHours = SimpleOpeningHours(schedule);
      final hasService = week.any((day) =>
          openingHours.rangesOn(day).isNotEmpty ||
          openingHours.departuresOn(day).isNotEmpty);
      if (!hasService) {
        silent.add('${entry.key} ${entry.value}: "$schedule" yields nothing');
      }
    }
    expect(silent, isEmpty, reason: silent.join('\n'));
  });

  test('the special Jilotepec lines carry their departures or short windows',
      () {
    List<String> departures(String id) =>
        SimpleOpeningHours(transportScheduleOf(id)!).departuresOn(monday);
    List<String> ranges(String id) =>
        SimpleOpeningHours(transportScheduleOf(id)!).rangesOn(monday);
    expect(departures('19525667'), ['17:30']); // Mercado → Doxhicho
    expect(departures('19531729'),
        ['07:25']); // Enfrente Terminal → San Juan Tuxtepec
    expect(departures('19531730'),
        ['10:00']); // San Juan Tuxtepec → Enfrente Terminal
    expect(departures('19531743'), ['08:25']); // Aurrera → Bella Vista
    expect(ranges('19528584'),
        ['04:00-05:45']); // Chapa de Mota → Terminal (ANASA)
    expect(ranges('19528664'), ['05:20-08:00']); // Emiliano Zapata → Terminal
    expect(ranges('19531744'), ['06:40-07:20']); // Bella Vista → Aurrera
  });
}
