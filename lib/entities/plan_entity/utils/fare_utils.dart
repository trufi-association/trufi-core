import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/entities/plan_entity/route_entity.dart';
import 'package:trufi_core/services/models_otp/fare.dart';
import 'package:trufi_core/services/models_otp/fare_component.dart';
import 'package:trufi_core/services/models_otp/route.dart';

Future<List<Fare>> fetchFares(PlanItinerary itinerary, String faresUrl) async {
  if (itinerary.legs.isEmpty) {
    return [];
  }
  final Map<String, dynamic> body = <String, dynamic>{
    'startTime': itinerary?.startTime?.millisecondsSinceEpoch,
    'endTime': itinerary?.endTime?.millisecondsSinceEpoch,
    'walkDistance': itinerary?.walkDistance,
    'duration': itinerary?.durationTrip?.inSeconds,
    'legs': itinerary.legs..map((e) => e.toJson()).toList()
  };
  final response = await http.post(
    Uri.parse(
      faresUrl,
    ),
    body: jsonEncode(body),
    headers: {'content-type': 'application/json'},
  );
  if (response.statusCode != 200) {
    throw Exception(
      "Server Error on fetchPBF ${response.request.url} with ${response.statusCode}",
    );
  }
  return List<Fare>.from((jsonDecode(response.body) as List<dynamic>)
      .map((x) => Fare.fromMap(x as Map<String, dynamic>)));
}

List<RouteEntity> getRoutes(List<PlanItineraryLeg> legs) {
  return legs.map((e) => e.route).toList();
}

List<FareComponent> getFares(
  List<Fare> fares,
) {
  if (fares.isNotEmpty) {
    final knownFares = mapFares(fares);
    return [...knownFares];
  }
  return [];
}

List<FareComponent> getUnknownFares(
  List<Fare> fares,
  List<FareComponent> knownFares,
  List<RouteEntity> routes,
) {
  if (fares.isNotEmpty) {
    final routesWithFares = knownFares
        .map((fareComponent) => fareComponent?.routes ?? <RouteOtp>[])
        .reduce((value, element) => [...value, ...element])
        .map((route) => route.gtfsId)
        .toList();

    final unknownTotalFare =
        fares[0]?.type == 'regular' && fares[0]?.cents == -1;
    final unknownFares = (unknownTotalFare ? routes : <RouteEntity>[])
        .where((route) => !routesWithFares.contains(route?.gtfsId))
        .map((e) => null)
        .toList();

    return [...unknownFares];
  }
  return [];
}

List<FareComponent> mapFares(List<Fare> fares) {
  final regularFares = fares.where((fare) => fare.type == 'regular').toList();
  if (regularFares.isEmpty) {
    return [];
  }
  final components = regularFares[0].components;
  if (components != null && components.isEmpty) {
    return [];
  }
  return components;
}

bool getUnknownFareRoute(List<FareComponent> fares, RouteEntity route) {
  bool exist = false;
  for (final FareComponent fare in fares) {
    if (fare.routes[0].gtfsId == route.gtfsId) {
      exist = true;
      break;
    }
  }
  return exist;
}
