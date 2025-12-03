import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

/// Unit tests for OTP 2.8 response parser.
void main() {
  group('Otp28ResponseParser', () {
    late Map<String, dynamic> fixtureJson;

    setUpAll(() {
      final file = File('test/fixtures/otp_2_8_response.json');
      fixtureJson = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    });

    test('parsePlan returns valid Plan from fixture', () {
      final plan = Otp28ResponseParser.parsePlan(fixtureJson);

      expect(plan, isNotNull);
      expect(plan.from, isNotNull);
      expect(plan.to, isNotNull);
      expect(plan.itineraries, isNotNull);
      expect(plan.itineraries, isNotEmpty);
    });

    test('parsePlan extracts correct from/to locations', () {
      final plan = Otp28ResponseParser.parsePlan(fixtureJson);

      expect(plan.from!.name, equals('Origin'));
      expect(plan.from!.latitude, equals(-17.3452624));
      expect(plan.from!.longitude, equals(-66.1975204));

      expect(plan.to!.name, equals('Destination'));
      expect(plan.to!.latitude, equals(-17.4647819));
      expect(plan.to!.longitude, equals(-66.1494349));
    });

    test('parsePlan parses itinerary with correct duration', () {
      final plan = Otp28ResponseParser.parsePlan(fixtureJson);
      final itinerary = plan.itineraries!.first;

      expect(itinerary.duration.inSeconds, equals(3600));
      expect(itinerary.walkTime.inSeconds, equals(600));
      expect(itinerary.walkDistance, equals(500.0));
    });

    test('parsePlan parses OTP 2.8 specific emissions data', () {
      final plan = Otp28ResponseParser.parsePlan(fixtureJson);
      final itinerary = plan.itineraries!.first;

      expect(itinerary.emissionsPerPerson, isNotNull);
      expect(itinerary.emissionsPerPerson, equals(125.5));
    });

    test('parsePlan parses arrivedAtDestinationWithRentedBicycle', () {
      final plan = Otp28ResponseParser.parsePlan(fixtureJson);
      final itinerary = plan.itineraries!.first;

      expect(itinerary.arrivedAtDestinationWithRentedBicycle, isFalse);
    });

    test('parsePlan parses itinerary start/end times correctly', () {
      final plan = Otp28ResponseParser.parsePlan(fixtureJson);
      final itinerary = plan.itineraries!.first;

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
      final plan = Otp28ResponseParser.parsePlan(fixtureJson);
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

    test('parsePlan parses realtimeState for legs', () {
      final plan = Otp28ResponseParser.parsePlan(fixtureJson);
      final itinerary = plan.itineraries!.first;

      // Walk leg should be SCHEDULED
      expect(itinerary.legs[0].realtimeState, equals(RealtimeState.scheduled));

      // Bus leg should be UPDATED
      expect(itinerary.legs[1].realtimeState, equals(RealtimeState.updated));
    });

    test('parsePlan parses nested route info with type', () {
      final plan = Otp28ResponseParser.parsePlan(fixtureJson);
      final busLeg = plan.itineraries!.first.legs[1];

      expect(busLeg.route, isNotNull);
      expect(busLeg.route!.gtfsId, equals('1:route_123'));
      expect(busLeg.route!.shortName, equals('123'));
      expect(busLeg.route!.longName, equals('Centro - Sur'));
      expect(busLeg.route!.color, equals('FF0000'));
      expect(busLeg.route!.textColor, equals('FFFFFF'));
      expect(busLeg.route!.type, equals(3)); // OTP 2.8 includes type
      expect(busLeg.route!.mode, equals(TransportMode.bus));
    });

    test('parsePlan parses extended agency info', () {
      final plan = Otp28ResponseParser.parsePlan(fixtureJson);
      final busLeg = plan.itineraries!.first.legs[1];

      expect(busLeg.agency, isNotNull);
      expect(busLeg.agency!.gtfsId, equals('1:trufi'));
      expect(busLeg.agency!.name, equals('Trufi Association'));
      expect(busLeg.agency!.url, equals('https://trufi.app'));
      expect(busLeg.agency!.timezone, equals('America/La_Paz'));
      expect(busLeg.agency!.phone, equals('+591 4 1234567'));
    });

    test('parsePlan parses places with extended stop info', () {
      final plan = Otp28ResponseParser.parsePlan(fixtureJson);
      final busLeg = plan.itineraries!.first.legs[1];

      expect(busLeg.fromPlace, isNotNull);
      expect(busLeg.fromPlace!.name, equals('Bus Stop A'));
      expect(busLeg.fromPlace!.stopId, equals('1:stop_a'));
      expect(busLeg.fromPlace!.stopCode, equals('A001'));
      expect(busLeg.fromPlace!.vertexType, equals(VertexType.transit));

      expect(busLeg.toPlace, isNotNull);
      expect(busLeg.toPlace!.name, equals('Bus Stop B'));
      expect(busLeg.toPlace!.stopId, equals('1:stop_b'));
      expect(busLeg.toPlace!.stopCode, equals('B001'));
    });

    test('parsePlan parses walking steps', () {
      final plan = Otp28ResponseParser.parsePlan(fixtureJson);
      final walkLeg = plan.itineraries!.first.legs[0];

      expect(walkLeg.steps, isNotNull);
      expect(walkLeg.steps!.length, equals(2));

      final step1 = walkLeg.steps![0];
      expect(step1.distance, equals(250.0));
      expect(step1.relativeDirection, equals('DEPART'));
      expect(step1.absoluteDirection, equals('NORTH'));
      expect(step1.streetName, equals('Avenida Principal'));
      expect(step1.stayOn, isFalse);
      expect(step1.area, isFalse);

      final step2 = walkLeg.steps![1];
      expect(step2.relativeDirection, equals('RIGHT'));
      expect(step2.absoluteDirection, equals('EAST'));
      expect(step2.streetName, equals('Calle Secundaria'));
    });

    test('parsePlan parses intermediate places with extended info', () {
      final plan = Otp28ResponseParser.parsePlan(fixtureJson);
      final busLeg = plan.itineraries!.first.legs[1];

      expect(busLeg.intermediatePlaces, isNotNull);
      expect(busLeg.intermediatePlaces!.length, equals(1));

      final intermediatePlace = busLeg.intermediatePlaces!.first;
      expect(intermediatePlace.name, equals('Intermediate Stop 1'));
      expect(intermediatePlace.stopId, equals('1:stop_int_1'));
      expect(intermediatePlace.stopCode, equals('INT1'));
    });

    test('parsePlan decodes polyline geometry', () {
      final plan = Otp28ResponseParser.parsePlan(fixtureJson);
      final busLeg = plan.itineraries!.first.legs[1];

      expect(busLeg.encodedPoints, isNotNull);
      expect(busLeg.decodedPoints, isNotEmpty);
    });

    test('parsePlan returns empty Plan when plan data is null', () {
      final emptyJson = <String, dynamic>{};
      final plan = Otp28ResponseParser.parsePlan(emptyJson);

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

      final plan = Otp28ResponseParser.parsePlan(minimalJson);

      expect(plan, isNotNull);
      expect(plan.itineraries, isNotEmpty);
      expect(plan.itineraries!.first.legs, isNotEmpty);
      expect(plan.itineraries!.first.emissionsPerPerson, isNull);
    });

    test('parsePlan handles missing emissions data', () {
      final jsonWithoutEmissions = {
        'plan': {
          'from': {'name': 'A', 'lat': -17.0, 'lon': -66.0},
          'to': {'name': 'B', 'lat': -17.1, 'lon': -66.1},
          'itineraries': [
            {
              'duration': 100,
              'startTime': 1733241600000,
              'endTime': 1733241700000,
              // No emissionsPerPerson
              'legs': [],
            },
          ],
        },
      };

      final plan = Otp28ResponseParser.parsePlan(jsonWithoutEmissions);

      expect(plan.itineraries!.first.emissionsPerPerson, isNull);
    });
  });
}
