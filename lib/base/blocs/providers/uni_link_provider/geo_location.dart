import 'dart:convert';

import 'package:trufi_core/base/models/trufi_place.dart';

import 'exception_parse.dart';

class GeoLocation {
  static const String schema = 'geo';
  static const String type = 'GeoLocation';
  static const String _trufiLocation = "trufiLocation";
  final TrufiLocation trufiLocation;

  const GeoLocation({
    required this.trufiLocation,
  });

  factory GeoLocation.fromURI(Uri uri) {
    // Parse uri: _Uri (geo:-17.4195926558668,-66.14687393265119?q=Av.+Suecia%2C+Cochabamba%2C+Cochabamba(Hospital+Harry+Williams))
    final coordinatesData = uri.path.split(',');
    if (coordinatesData.length < 2) {
      throw UnilinkParseException(
        'GeoLocation Parsing Failed',
        'The provided geolocation link could not be parsed.',
      );
    }

    final latitude = double.tryParse(coordinatesData[0]);
    final longitude = double.tryParse(coordinatesData[1]);

    if (latitude == null || longitude == null) {
      throw UnilinkParseException(
        'GeoLocation Parsing Failed',
        'The provided geolocation link could not be parsed.',
      );
    }

    String? description, address;
    final queryParameters = uri.queryParameters;
    if (queryParameters.containsKey('q')) {
      final queryData = queryParameters['q']!.split('(');
      if (queryData.length > 1) {
        description = queryData[1].replaceAll(')', '');
        address = queryData[0];
      }
    }

    return GeoLocation(
      trufiLocation: TrufiLocation(
        description: description ?? '',
        latitude: latitude,
        longitude: longitude,
        address: address,
      ),
    );
  }

  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    return GeoLocation(
      trufiLocation: TrufiLocation.fromJson(
          jsonDecode(json[_trufiLocation]) as Map<String, dynamic>),
    );
  }

  Map<String, String> toJson() {
    return <String, String>{
      type: GeoLocation.type,
      _trufiLocation: jsonEncode(trufiLocation.toJson()),
    };
  }
}
