import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

/// Unit tests for OTP 1.5 response parser.
void main() {
  group('Otp15ResponseParser', () {
    late Map<String, dynamic> fixtureJson;

    setUpAll(() {
      final file = File('test/fixtures/otp_1_5_response.json');
      fixtureJson = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    });

    test('parsePlan returns valid Plan from fixture', () {
      final plan = Otp15ResponseParser.parsePlan(fixtureJson);

      expect(plan, isNotNull);
      expect(plan.from, isNotNull);
      expect(plan.to, isNotNull);
      expect(plan.itineraries, isNotNull);
      expect(plan.itineraries, isNotEmpty);
    });

    test('parsePlan extracts correct from/to locations', () {
      final plan = Otp15ResponseParser.parsePlan(fixtureJson);

      expect(plan.from!.name, equals('Origin'));
      expect(plan.from!.latitude, equals(-17.3452624));
      expect(plan.from!.longitude, equals(-66.1975204));

      expect(plan.to!.name, equals('Destination'));
      expect(plan.to!.latitude, equals(-17.4647819));
      expect(plan.to!.longitude, equals(-66.1494349));
    });

    test('parsePlan parses itinerary with correct duration', () {
      final plan = Otp15ResponseParser.parsePlan(fixtureJson);
      final itinerary = plan.itineraries!.first;

      expect(itinerary.duration.inSeconds, equals(3600));
      expect(itinerary.walkTime.inSeconds, equals(600));
      expect(itinerary.walkDistance, equals(500.0));
    });

    test('parsePlan parses itinerary start/end times correctly', () {
      final plan = Otp15ResponseParser.parsePlan(fixtureJson);
      final itinerary = plan.itineraries!.first;

      // Timestamps: 1733241600000 and 1733245200000
      expect(
        itinerary.startTime,
        equals(DateTime.fromMillisecondsSinceEpoch(1733241600000)),
      );
      expect(
        itinerary.endTime,
        equals(DateTime.fromMillisecondsSinceEpoch(1733245200000)),
      );
    });

    test('parsePlan parses legs correctly', () {
      final plan = Otp15ResponseParser.parsePlan(fixtureJson);
      final itinerary = plan.itineraries!.first;

      expect(itinerary.legs.length, equals(3));

      // First leg - WALK
      final walkLeg1 = itinerary.legs[0];
      expect(walkLeg1.mode, equals('WALK'));
      expect(walkLeg1.transitLeg, isFalse);
      expect(walkLeg1.distance, equals(500.0));
      expect(walkLeg1.duration.inSeconds, equals(600));

      // Second leg - BUS (transit)
      final busLeg = itinerary.legs[1];
      expect(busLeg.mode, equals('BUS'));
      expect(busLeg.transitLeg, isTrue);
      expect(busLeg.distance, equals(8000.0));
      expect(busLeg.headsign, equals('Terminal Sur'));

      // Third leg - WALK
      final walkLeg2 = itinerary.legs[2];
      expect(walkLeg2.mode, equals('WALK'));
      expect(walkLeg2.transitLeg, isFalse);
    });

    test('parsePlan parses route info from transit leg', () {
      final plan = Otp15ResponseParser.parsePlan(fixtureJson);
      final busLeg = plan.itineraries!.first.legs[1];

      expect(busLeg.route, isNotNull);
      expect(busLeg.route!.gtfsId, equals('1:route_123'));
      expect(busLeg.route!.shortName, equals('123'));
      expect(busLeg.route!.longName, equals('Centro - Sur'));
      expect(busLeg.route!.color, equals('FF0000'));
      expect(busLeg.route!.textColor, equals('FFFFFF'));
    });

    test('parsePlan parses agency info from transit leg', () {
      final plan = Otp15ResponseParser.parsePlan(fixtureJson);
      final busLeg = plan.itineraries!.first.legs[1];

      expect(busLeg.agency, isNotNull);
      expect(busLeg.agency!.gtfsId, equals('1:trufi'));
      expect(busLeg.agency!.name, equals('Trufi Association'));
      expect(busLeg.agency!.url, equals('https://trufi.app'));
    });

    test('parsePlan parses places (from/to) in legs', () {
      final plan = Otp15ResponseParser.parsePlan(fixtureJson);
      final busLeg = plan.itineraries!.first.legs[1];

      expect(busLeg.fromPlace, isNotNull);
      expect(busLeg.fromPlace!.name, equals('Bus Stop A'));
      expect(busLeg.fromPlace!.stopId, equals('1:stop_a'));
      expect(busLeg.fromPlace!.lat, equals(-17.3666004));
      expect(busLeg.fromPlace!.lon, equals(-66.199784));

      expect(busLeg.toPlace, isNotNull);
      expect(busLeg.toPlace!.name, equals('Bus Stop B'));
      expect(busLeg.toPlace!.stopId, equals('1:stop_b'));
    });

    test('parsePlan parses intermediate stops', () {
      final plan = Otp15ResponseParser.parsePlan(fixtureJson);
      final busLeg = plan.itineraries!.first.legs[1];

      expect(busLeg.intermediatePlaces, isNotNull);
      expect(busLeg.intermediatePlaces!.length, equals(1));

      final intermediateStop = busLeg.intermediatePlaces!.first;
      expect(intermediateStop.name, equals('Intermediate Stop 1'));
      expect(intermediateStop.stopId, equals('1:stop_int_1'));
      expect(intermediateStop.lat, equals(-17.40));
      expect(intermediateStop.lon, equals(-66.18));
    });

    test('parsePlan decodes polyline geometry', () {
      final plan = Otp15ResponseParser.parsePlan(fixtureJson);
      final busLeg = plan.itineraries!.first.legs[1];

      expect(busLeg.encodedPoints, isNotNull);
      expect(busLeg.decodedPoints, isNotEmpty);
    });

    test('parsePlan returns empty Plan when plan data is null', () {
      final emptyJson = <String, dynamic>{};
      final plan = Otp15ResponseParser.parsePlan(emptyJson);

      expect(plan.from, isNull);
      expect(plan.to, isNull);
      expect(plan.itineraries, isNull);
    });

    test('parsePlan handles missing optional fields gracefully', () {
      final minimalJson = {
        'plan': {
          'from': {'name': 'A', 'lat': -17.0, 'lon': -66.0},
          'to': {'name': 'B', 'lat': -17.1, 'lon': -66.1},
          'itineraries': [
            {
              'duration': 100,
              'startTime': 1733241600000,
              'endTime': 1733241700000,
              'legs': [
                {
                  'mode': 'WALK',
                  'startTime': 1733241600000,
                  'endTime': 1733241700000,
                  'from': {'name': 'A', 'lat': -17.0, 'lon': -66.0},
                  'to': {'name': 'B', 'lat': -17.1, 'lon': -66.1},
                },
              ],
            },
          ],
        },
      };

      final plan = Otp15ResponseParser.parsePlan(minimalJson);

      expect(plan, isNotNull);
      expect(plan.itineraries, isNotEmpty);
      expect(plan.itineraries!.first.legs, isNotEmpty);
    });
  });
}
