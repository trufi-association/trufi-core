import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong/latlong.dart';
import 'package:trufi_core/repository/wfs_weather_data_repository.dart';

void main() {
  group("WFSWeatherDataRepository", () {
    WFSWeatherDataRepository subject;

    test("should throw HttpException if the Client response with error", () async {
      final mockClient = MockClient((request) async {
        return http.Response("Error", 400);
      });

      subject = WFSWeatherDataRepository(client: mockClient);
      final now = DateTime(2021, 05, 08);

      expect(
        () async => subject.getCurrentWeatherAtLocation(
          now,
          LatLng(48.59523, 8.86648),
        ),
        throwsA(predicate((e) =>
            e is HttpException &&
            e.message ==
                "Could not get the current Weather at your location 400")),
      );
    });
  });
}
