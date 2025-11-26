import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';
import 'package:trufi_core/repositories/location/interfaces/i_location_search_service.dart';
import 'package:trufi_core/repositories/location/models/location_search_model.dart';
import 'package:trufi_core/utils/packge_info_platform.dart';

class PhotonLocationSearchService implements ILocationSearchService {
  final String photonUrl;
  final Map<String, dynamic>? queryParameters;

  const PhotonLocationSearchService({
    required this.photonUrl,
    this.queryParameters = const {},
  });

  @override
  Future<List<TrufiLocation>> fetchLocations(
    String query, {
    int limit = 15,
    String? lang = "en",
  }) async {
    final extraQueryParameters = queryParameters ?? {};
    final Uri request = Uri.parse("$photonUrl/api").replace(
      queryParameters: {
        "q": query,
        "limit": limit.toString(),
        "lang": lang,
        ...extraQueryParameters,
      },
    );
    
    try {
      final response = await _fetchRequest(request);
      if (response.statusCode != 200) {
        throw Exception("Photon API error: ${response.statusCode}");
      }

      final json = jsonDecode(utf8.decode(response.bodyBytes));
      final features = json["features"] as List?;
      
      if (features == null || features.isEmpty) {
        return [];
      }

      final trufiLocationList = features
          .map((e) => LocationSearchResponse.fromJson(e as Map<String, dynamic>))
          .map((x) => x.toTrufiLocation())
          .toList();

      return trufiLocationList;
    } catch (e) {
      // Log error and return empty list instead of throwing
      debugPrint("Error fetching locations from Photon: $e");
      return [];
    }
  }

  @override
  Future<TrufiLocation> reverseGeodecoding(LatLng location) async {
    try {
      final response = await _fetchRequest(
        Uri.parse(
          "$photonUrl/reverse?lon=${location.longitude}&lat=${location.latitude}",
        ),
      );
      
      if (response.statusCode != 200) {
        throw Exception("Photon reverse geocoding error: ${response.statusCode}");
      }

      final body = jsonDecode(utf8.decode(response.bodyBytes));
      
      if (body["type"] == "FeatureCollection") {
        final features = body["features"] as List?;
        if (features != null && features.isNotEmpty) {
          final feature = features.first;
          final properties = feature["properties"] as Map<String, dynamic>;
          final geometry = feature["geometry"];
          final coords = geometry["coordinates"] as List;
          
          // Build a more complete address from available properties
          final street = properties["street"]?.toString() ?? "";
          final housenumber = properties["housenumber"]?.toString() ?? "";
          final locality = properties["locality"]?.toString() ?? "";
          final county = properties["county"]?.toString() ?? "";
          
          final addressParts = <String>[
            if (street.isNotEmpty) 
              housenumber.isNotEmpty ? "$street $housenumber" : street,
            if (locality.isNotEmpty) locality,
            if (county.isNotEmpty) county,
          ];
          
          return LocationSearchResponse(
            name: properties["name"]?.toString() ?? "Unknown location",
            street: addressParts.join(", "),
            latLng: LatLng(coords[1], coords[0]),
            type: properties["type"]?.toString(),
          ).toTrufiLocation();
        }
      }
      
      // Return a basic location if no data found
      return TrufiLocation(
        description: "Selected location",
        position: location,
        address: "Lat: ${location.latitude.toStringAsFixed(6)}, Lon: ${location.longitude.toStringAsFixed(6)}",
      );
    } catch (e) {
      debugPrint("Error in reverse geocoding: $e");
      // Return a basic location on error
      return TrufiLocation(
        description: "Selected location",
        position: location,
        address: "Lat: ${location.latitude.toStringAsFixed(6)}, Lon: ${location.longitude.toStringAsFixed(6)}",
      );
    }
  }

  Future<http.Response> _fetchRequest(Uri request) async {
    final userAgent = await PackageInfoPlatform.getUserAgent();
    return await http.get(request, headers: {"User-Agent": userAgent});
  }
}
