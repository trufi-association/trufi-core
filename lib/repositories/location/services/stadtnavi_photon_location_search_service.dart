import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';
import 'package:trufi_core/repositories/location/interfaces/i_location_search_service.dart';
import 'package:trufi_core/repositories/location/models/location_search_model.dart';
import 'package:trufi_core/utils/packge_info_platform.dart';

class StadtnaviPhotonLocationSearchService implements ILocationSearchService {
  final String photonUrl;
  final Map<String, dynamic>? queryParameters;

  const StadtnaviPhotonLocationSearchService({
    required this.photonUrl,
    this.queryParameters = const {},
  });

  @override
  Future<List<TrufiLocation>> fetchLocations(
    String query, {
    int limit = 15,
    String? correlationId,
    String? lang = "en",
  }) async {
    final extraQueryParameters = queryParameters ?? {};
    final Uri request = Uri.parse("$photonUrl/search").replace(
      queryParameters: {
        "text": query,
        "boundary.rect.min_lat": "48.34164",
        "boundary.rect.max_lat": "48.97661",
        "boundary.rect.min_lon": "9.95635",
        "boundary.rect.max_lon": "8.530883",
        "focus.point.lat": "48.5957",
        "focus.point.lon": "8.8675",
        "lang": lang,
        "sources": "oa,osm,gtfshb",
        "layers": "station,venue,address,street",
        ...extraQueryParameters,
      },
    );
    final response = await _fetchRequest(request);
    if (response.statusCode != 200) {
      throw "Not found locations";
    } else {
      // location results
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      final trufiLocationList =
          List<Map<String, dynamic>>.from(json["features"])
              .map((e) => LocationSearchResponse.fromJson(e))
              .map((x) => x.toTrufiLocation())
              .toList();

      return trufiLocationList;
    }
  }

  @override
  Future<TrufiLocation> reverseGeodecoding(
    LatLng location, {
    String? lang = "en",
  }) async {
    final response = await _fetchRequest(
      Uri.parse(
        "$photonUrl/reverse?point.lat=${location.latitude}&point.lon=${location.longitude}&boundary.circle.radius=0.1&lang=$lang&size=1&layers=address&zones=1",
      ),
    );
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    final features = body["features"] as List;
    final feature = features.first;
    final properties = feature["properties"];
    final String street = properties["street"]?.toString() ?? "";
    final String houseNumbre = properties["housenumber"]?.toString() ?? "";
    final String postalcode = properties["postalcode"]?.toString() ?? "";
    final String locality = properties["locality"]?.toString() ?? "";
    String streetHouse = "";
    if (street != '') {
      if (houseNumbre != '') {
        streetHouse = "$street $houseNumbre,";
      } else {
        streetHouse = "$street,";
      }
    }

    return LocationSearchResponse(
      name: properties?["name"]?.toString().trim() ?? 'Not name',
      street: "$streetHouse $postalcode $locality".trim(),
      latLng: location,
    ).toTrufiLocation();
  }

  Future<http.Response> _fetchRequest(Uri request) async {
    final userAgent = await PackageInfoPlatform.getUserAgent();
    return await http.get(request, headers: {"User-Agent": userAgent});
  }
}
