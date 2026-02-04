import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/search_location.dart';
import 'search_location_service.dart';

/// Service for searching locations using the Photon API (OpenStreetMap based).
///
/// Photon is a free, open-source geocoding API powered by OpenStreetMap data.
/// https://photon.komoot.io/
class PhotonSearchService implements SearchLocationService {
  /// Base URL for the Photon API.
  final String baseUrl;

  /// Language for results (e.g., 'en', 'de', 'es').
  final String? language;

  /// Latitude for location bias (results closer to this point are prioritized).
  final double? biasLatitude;

  /// Longitude for location bias.
  final double? biasLongitude;

  /// Maximum number of results to return.
  final int limit;

  /// Optional bounding box to limit results [minLon, minLat, maxLon, maxLat].
  final List<double>? boundingBox;

  /// HTTP client for making requests.
  final http.Client _client;

  PhotonSearchService({
    required this.baseUrl,
    this.language,
    this.biasLatitude,
    this.biasLongitude,
    this.limit = 10,
    this.boundingBox,
    http.Client? client,
  }) : _client = client ?? http.Client();

  @override
  Future<List<SearchLocation>> search(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final queryParams = <String, String>{
      'q': query,
      'limit': limit.toString(),
    };

    if (language != null) {
      queryParams['lang'] = language!;
    }

    if (biasLatitude != null && biasLongitude != null) {
      queryParams['lat'] = biasLatitude.toString();
      queryParams['lon'] = biasLongitude.toString();
    }

    if (boundingBox != null && boundingBox!.length == 4) {
      queryParams['bbox'] =
          '${boundingBox![0]},${boundingBox![1]},${boundingBox![2]},${boundingBox![3]}';
    }

    final uri = Uri.parse('$baseUrl/api/').replace(queryParameters: queryParams);

    try {
      final response = await _client.get(uri);

      if (response.statusCode != 200) {
        throw SearchLocationException(
          'Photon search failed: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final features = json['features'] as List<dynamic>? ?? [];

      return features.map((feature) => _parseFeature(feature)).toList();
    } catch (e) {
      if (e is SearchLocationException) rethrow;
      throw SearchLocationException('Photon search failed: $e', originalError: e);
    }
  }

  @override
  Future<SearchLocation?> reverse(double latitude, double longitude) async {
    final queryParams = <String, String>{
      'lat': latitude.toString(),
      'lon': longitude.toString(),
    };

    if (language != null) {
      queryParams['lang'] = language!;
    }

    final uri =
        Uri.parse('$baseUrl/reverse').replace(queryParameters: queryParams);

    try {
      final response = await _client.get(uri);

      if (response.statusCode != 200) {
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final features = json['features'] as List<dynamic>? ?? [];

      if (features.isEmpty) return null;

      return _parseFeature(features.first);
    } catch (e) {
      return null;
    }
  }

  SearchLocation _parseFeature(Map<String, dynamic> feature) {
    final geometry = feature['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List<dynamic>;
    final properties = feature['properties'] as Map<String, dynamic>? ?? {};

    final lon = (coordinates[0] as num).toDouble();
    final lat = (coordinates[1] as num).toDouble();

    // Build display name from properties
    final name = properties['name'] as String?;
    final street = properties['street'] as String?;
    final houseNumber = properties['housenumber'] as String?;
    final city = properties['city'] as String?;
    final state = properties['state'] as String?;
    final country = properties['country'] as String?;
    final osmId = properties['osm_id'];

    // Create display name
    String displayName;
    if (name != null && name.isNotEmpty) {
      displayName = name;
    } else if (street != null) {
      displayName = houseNumber != null ? '$street $houseNumber' : street;
    } else {
      displayName = [city, state, country]
          .where((s) => s != null && s.isNotEmpty)
          .join(', ');
    }

    if (displayName.isEmpty) {
      displayName = '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';
    }

    // Create address
    final addressParts = <String>[];
    if (street != null) {
      addressParts.add(houseNumber != null ? '$street $houseNumber' : street);
    }
    if (city != null) addressParts.add(city);
    if (state != null) addressParts.add(state);
    if (country != null) addressParts.add(country);

    final address =
        addressParts.isNotEmpty ? addressParts.join(', ') : null;

    return SearchLocation(
      id: osmId != null ? 'osm_$osmId' : 'photon_${lat}_$lon',
      displayName: displayName,
      address: address,
      latitude: lat,
      longitude: lon,
    );
  }

  @override
  void dispose() {
    _client.close();
  }
}
