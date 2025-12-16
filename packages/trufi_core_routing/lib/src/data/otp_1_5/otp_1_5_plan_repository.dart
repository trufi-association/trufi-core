import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/plan.dart';
import '../../domain/entities/routing_location.dart';
import '../../domain/entities/routing_preferences.dart';
import '../../domain/repositories/plan_repository.dart';
import 'otp_1_5_response_parser.dart';

/// Implementation of [PlanRepository] using OpenTripPlanner 1.5 REST API.
///
/// OTP 1.5 uses REST API (not GraphQL) with:
/// - `/otp/routers/default/plan` endpoint
/// - Query parameters: fromPlace, toPlace, date, time, mode, etc.
/// - Location format: "lat,lon" string
/// - Times in milliseconds since epoch in response
class Otp15PlanRepository implements PlanRepository {
  Otp15PlanRepository({
    required String endpoint,
    http.Client? httpClient,
  })  : _endpoint = endpoint.endsWith('/')
            ? endpoint.substring(0, endpoint.length - 1)
            : endpoint,
        _httpClient = httpClient ?? http.Client();

  final String _endpoint;
  final http.Client _httpClient;

  @override
  Future<Plan> fetchPlan({
    required RoutingLocation from,
    required RoutingLocation to,
    int numItineraries = 5,
    String? locale,
    required DateTime dateTime,
    RoutingPreferences? preferences,
  }) async {
    final date = '${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}-${dateTime.year}';
    final time = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    // Build transport modes string from preferences
    final modes = preferences?.transportModes
            .map((m) => m.otpName)
            .join(',') ??
        'TRANSIT,WALK';

    final queryParams = <String, String>{
      'fromPlace': _formatLocation(from),
      'toPlace': _formatLocation(to),
      'numItineraries': numItineraries.toString(),
      'mode': modes,
      'date': date,
      'time': time,
    };

    // Add routing preferences
    if (preferences != null) {
      if (preferences.wheelchair) {
        queryParams['wheelchair'] = 'true';
      }
      queryParams['walkSpeed'] = preferences.walkSpeed.toString();
      queryParams['walkReluctance'] = preferences.walkReluctance.toString();
      if (preferences.maxWalkDistance != null) {
        queryParams['maxWalkDistance'] = preferences.maxWalkDistance.toString();
      }
      // Add bike speed if bicycle mode is selected
      if (preferences.transportModes.contains(RoutingMode.bicycle)) {
        queryParams['bikeSpeed'] = preferences.bikeSpeed.toString();
      }
    }

    if (locale != null) {
      queryParams['locale'] = locale;
    }

    final uri = Uri.parse(_endpoint)
        .replace(queryParameters: queryParams);

    // Debug: print('OTP 1.5 Request: $uri');

    try {
      final response = await _httpClient.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Otp15Exception(
          'HTTP error ${response.statusCode}: ${response.reasonPhrase}',
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      // Check for OTP error in response
      final error = json['error'] as Map<String, dynamic>?;
      if (error != null) {
        final errorId = error['id'] as int?;
        final errorMsg = error['msg'] as String? ?? 'Unknown error';
        throw Otp15Exception('OTP Error ($errorId): $errorMsg');
      }

      return Otp15ResponseParser.parsePlan(json);
    } on FormatException catch (e) {
      throw Otp15Exception('Invalid response format: ${e.message}');
    } on http.ClientException catch (e) {
      throw Otp15Exception('Network error: ${e.message}');
    }
  }

  /// Formats a location for OTP 1.5 REST API.
  ///
  /// OTP 1.5 expects location in format: "lat,lon"
  String _formatLocation(RoutingLocation location) {
    return '${location.position.latitude},${location.position.longitude}';
  }

  /// Closes the HTTP client.
  void dispose() {
    _httpClient.close();
  }
}

/// Exception thrown by OTP 1.5 operations.
class Otp15Exception implements Exception {
  Otp15Exception(this.message);

  final String message;

  @override
  String toString() => 'Otp15Exception: $message';
}
