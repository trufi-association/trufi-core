import 'package:trufi_core/models/enums/transport_mode.dart';
import 'package:trufi_core/models/enums/vertex_type.dart';
import 'package:trufi_core/models/plan_entity.dart';
import 'package:trufi_core/models/trufi_location.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;

/// Adapter to convert routing package entities to UI entities.
class PlanEntityAdapter {
  PlanEntityAdapter._();

  /// Converts a [routing.Plan] to a [PlanEntity] with UI components.
  static PlanEntity fromRoutingPlan(routing.Plan plan) {
    return PlanEntity(
      from: plan.from != null ? _convertPlanLocation(plan.from!) : null,
      to: plan.to != null ? _convertPlanLocation(plan.to!) : null,
      itineraries: plan.itineraries
          ?.map((i) => _convertItinerary(i))
          .toList(),
    );
  }

  static PlanLocation _convertPlanLocation(routing.PlanLocation loc) {
    return PlanLocation(
      name: loc.name,
      latitude: loc.latitude,
      longitude: loc.longitude,
    );
  }

  static PlanItinerary _convertItinerary(routing.Itinerary itinerary) {
    return PlanItinerary(
      legs: itinerary.legs.map((l) => _convertLeg(l)).toList(),
      startTime: itinerary.startTime,
      endTime: itinerary.endTime,
      walkTime: itinerary.walkTime,
      duration: itinerary.duration,
      walkDistance: itinerary.walkDistance,
      arrivedAtDestinationWithRentedBicycle:
          itinerary.arrivedAtDestinationWithRentedBicycle,
      emissionsPerPerson: itinerary.emissionsPerPerson,
    );
  }

  static PlanItineraryLeg _convertLeg(routing.ItineraryLeg leg) {
    final shortName = leg.route?.shortName ?? leg.shortName ?? '';

    return PlanItineraryLeg(
      points: leg.encodedPoints ?? '',
      mode: leg.mode,
      route: leg.route != null ? _convertRoute(leg.route!) : null,
      shortName: shortName.isNotEmpty ? shortName : null,
      routeLongName: leg.routeLongName ?? '',
      distance: leg.distance,
      duration: leg.duration,
      agency: leg.agency != null ? _convertAgency(leg.agency!) : null,
      toPlace: leg.toPlace != null ? _convertPlace(leg.toPlace!) : null,
      fromPlace: leg.fromPlace != null ? _convertPlace(leg.fromPlace!) : null,
      startTime: leg.startTime,
      endTime: leg.endTime,
      transitLeg: leg.transitLeg,
      rentedBike: leg.rentedBike,
      interlineWithPreviousLeg: leg.interlineWithPreviousLeg,
      accumulatedPoints: leg.decodedPoints,
      intermediatePlaces: leg.intermediatePlaces
          ?.map((p) => _convertPlace(p))
          .toList(),
    );
  }

  static RouteEntity _convertRoute(routing.Route route) {
    return RouteEntity(
      id: route.id,
      gtfsId: route.gtfsId,
      agency: route.agency != null ? _convertAgency(route.agency!) : null,
      shortName: route.shortName,
      longName: route.longName,
      mode: route.mode != null
          ? getTransportMode(mode: route.mode!.otpName)
          : null,
      type: route.type,
      desc: route.desc,
      url: route.url,
      color: route.color,
      textColor: route.textColor,
    );
  }

  static AgencyEntity _convertAgency(routing.Agency agency) {
    return AgencyEntity(
      id: agency.id ?? 0,
      gtfsId: agency.gtfsId ?? '',
      name: agency.name ?? '',
      url: agency.url ?? '',
      timezone: agency.timezone ?? '',
      lang: agency.lang ?? '',
      phone: agency.phone ?? '',
      fareUrl: agency.fareUrl ?? '',
    );
  }

  static PlaceEntity _convertPlace(routing.Place place) {
    return PlaceEntity(
      name: place.name,
      vertexType: _convertVertexType(place.vertexType),
      lat: place.lat,
      lon: place.lon,
      arrivalTime: place.arrivalTime,
      departureTime: place.departureTime,
      stopEntity: place.stopId != null
          ? StopEntity(
              gtfsId: place.stopId!,
              name: place.name,
              lat: place.lat,
              lon: place.lon,
            )
          : null,
      bikeRentalStation: null,
      bikeParkEntity: null,
      carParkEntity: null,
      vehicleParkingWithEntrance: null,
    );
  }

  static VertexTypeTrufi _convertVertexType(routing.VertexType type) {
    switch (type) {
      case routing.VertexType.bikePark:
        return VertexTypeTrufi.bikepark;
      case routing.VertexType.bikeShare:
        return VertexTypeTrufi.bikeshare;
      case routing.VertexType.carPark:
        return VertexTypeTrufi.parkandride;
      case routing.VertexType.transit:
        return VertexTypeTrufi.transit;
      default:
        return VertexTypeTrufi.normal;
    }
  }

  /// Converts a [TrufiLocation] to a [routing.RoutingLocation].
  static routing.RoutingLocation toRoutingLocation(TrufiLocation location) {
    return routing.RoutingLocation(
      position: location.position,
      description: location.description,
      address: location.address,
    );
  }

  /// Converts a [routing.RoutingLocation] to a [TrufiLocation].
  static TrufiLocation toTrufiLocation(routing.RoutingLocation location) {
    return TrufiLocation(
      position: location.position,
      description: location.description,
      address: location.address,
    );
  }
}
