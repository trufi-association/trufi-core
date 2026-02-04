import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/search_location.dart';
import 'search_location_service.dart';

/// Service for searching locations using the Nominatim API (OpenStreetMap).
///
/// Nominatim is the official OpenStreetMap geocoding service.
/// https://nominatim.org/
///
/// Note: The public Nominatim API has usage limits. For production use,
/// consider hosting your own instance or using a commercial provider.
class NominatimSearchService implements SearchLocationService {
  /// Base URL for the Nominatim API.
  final String baseUrl;

  /// User-Agent header (required by Nominatim usage policy).
  final String userAgent;

  /// Language for results (e.g., 'en', 'de', 'es').
  final String? language;

  /// Maximum number of results to return.
  final int limit;

  /// Country codes to limit results (e.g., ['bo', 'pe']).
  final List<String>? countryCodes;

  /// Bounding box to limit results [minLon, minLat, maxLon, maxLat].
  final List<double>? boundingBox;

  /// Latitude for location bias (viewbox center).
  final double? biasLatitude;

  /// Longitude for location bias (viewbox center).
  final double? biasLongitude;

  /// Radius in degrees for the viewbox around bias point.
  final double biasRadius;

  /// HTTP client for making requests.
  final http.Client _client;

  NominatimSearchService({
    required this.baseUrl,
    required this.userAgent,
    this.language,
    this.limit = 10,
    this.countryCodes,
    this.boundingBox,
    this.biasLatitude,
    this.biasLongitude,
    this.biasRadius = 0.5,
    http.Client? client,
  }) : _client = client ?? http.Client();

  @override
  Future<List<SearchLocation>> search(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final queryParams = <String, String>{
      'q': query,
      'format': 'json',
      'addressdetails': '1',
      'limit': limit.toString(),
    };

    if (language != null) {
      queryParams['accept-language'] = language!;
    }

    if (countryCodes != null && countryCodes!.isNotEmpty) {
      queryParams['countrycodes'] = countryCodes!.join(',');
    }

    // Use explicit bounding box or create one from bias point
    if (boundingBox != null && boundingBox!.length == 4) {
      queryParams['viewbox'] =
          '${boundingBox![0]},${boundingBox![3]},${boundingBox![2]},${boundingBox![1]}';
      queryParams['bounded'] = '1';
    } else if (biasLatitude != null && biasLongitude != null) {
      final minLon = biasLongitude! - biasRadius;
      final maxLon = biasLongitude! + biasRadius;
      final minLat = biasLatitude! - biasRadius;
      final maxLat = biasLatitude! + biasRadius;
      queryParams['viewbox'] = '$minLon,$maxLat,$maxLon,$minLat';
      queryParams['bounded'] = '0'; // Prefer but don't restrict
    }

    final uri =
        Uri.parse('$baseUrl/search').replace(queryParameters: queryParams);

    try {
      final response = await _client.get(
        uri,
        headers: {'User-Agent': userAgent},
      );

      if (response.statusCode != 200) {
        throw SearchLocationException(
          'Nominatim search failed: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      final json = jsonDecode(response.body) as List<dynamic>;

      return json.map((item) => _parseResult(item)).toList();
    } catch (e) {
      if (e is SearchLocationException) rethrow;
      throw SearchLocationException('Nominatim search failed: $e', originalError: e);
    }
  }

  @override
  Future<SearchLocation?> reverse(double latitude, double longitude) async {
    final queryParams = <String, String>{
      'lat': latitude.toString(),
      'lon': longitude.toString(),
      'format': 'json',
      'addressdetails': '1',
    };

    if (language != null) {
      queryParams['accept-language'] = language!;
    }

    final uri =
        Uri.parse('$baseUrl/reverse').replace(queryParameters: queryParams);

    try {
      final response = await _client.get(
        uri,
        headers: {'User-Agent': userAgent},
      );

      if (response.statusCode != 200) {
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (json.containsKey('error')) {
        return null;
      }

      return _parseResult(json);
    } catch (e) {
      return null;
    }
  }

  SearchLocation _parseResult(Map<String, dynamic> result) {
    final lat = double.parse(result['lat'] as String);
    final lon = double.parse(result['lon'] as String);
    final displayName = result['display_name'] as String? ?? '';
    final osmId = result['osm_id'];
    final osmType = result['osm_type'] as String?;

    // Parse address components
    final address = result['address'] as Map<String, dynamic>?;
    String? name;
    String? formattedAddress;

    if (address != null) {
      // Try to get a good name
      name = address['name'] as String? ??
          address['amenity'] as String? ??
          address['shop'] as String? ??
          address['tourism'] as String? ??
          address['building'] as String? ??
          address['road'] as String?;

      // Build formatted address
      final parts = <String>[];

      final road = address['road'] as String?;
      final houseNumber = address['house_number'] as String?;
      if (road != null) {
        parts.add(houseNumber != null ? '$road $houseNumber' : road);
      }

      final suburb = address['suburb'] as String? ?? address['neighbourhood'] as String?;
      if (suburb != null) parts.add(suburb);

      final city = address['city'] as String? ??
          address['town'] as String? ??
          address['village'] as String?;
      if (city != null) parts.add(city);

      final state = address['state'] as String?;
      if (state != null) parts.add(state);

      final country = address['country'] as String?;
      if (country != null) parts.add(country);

      formattedAddress = parts.isNotEmpty ? parts.join(', ') : null;
    }

    // Use name or first part of display_name
    final finalName = name ?? displayName.split(',').first.trim();

    return SearchLocation(
      id: osmId != null && osmType != null
          ? '${osmType}_$osmId'
          : 'nominatim_${lat}_$lon',
      displayName: finalName,
      address: formattedAddress ?? displayName,
      latitude: lat,
      longitude: lon,
    );
  }

  @override
  void dispose() {
    _client.close();
  }
}
