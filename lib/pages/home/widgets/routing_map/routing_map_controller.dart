import 'dart:async';
import 'package:flutter/material.dart';

import 'package:trufi_core/pages/home/repository/local_repository.dart';
import 'package:trufi_core/pages/home/repository/storage_map_route_repository.dart';
import 'package:trufi_core/repositories/storage/shared_preferences_storage.dart';
import 'package:trufi_core/pages/home/service/routing_service/otp_2_7/graphql_plan_data_source.dart';
import 'package:trufi_core/pages/home/widgets/routing_map/routing_map_selected.dart';
import 'package:trufi_core/consts.dart';
import 'package:trufi_core/models/enums/transport_mode.dart';
import 'package:trufi_core/models/plan_entity.dart';
import 'package:trufi_core/pages/home/service/i_plan_repository.dart';
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';

abstract class IRoutingMapComponent extends TrufiLayer {
  IRoutingMapComponent(super.controller) : super(id: layerId, layerLevel: 2) {
    routingMapSelected = RoutingMapSelected(controller, layerLevel: layerLevel);
  }

  static const String layerId = 'routing-map-component';
  late final RoutingMapSelected routingMapSelected;
  PlanItinerary? get selectedItinerary => routingMapSelected.selectedItinerary;
  void changeItinerary(PlanItinerary? itinerary);
  Future<void> addOrigin(TrufiLocation location);
  Future<void> addDestination(TrufiLocation location);
  Future<void> fetchPlan(BuildContext context);
  void selectNextItinerary();
  void cleanOriginAndDestination();
  TrufiLocation? origin;
  TrufiLocation? destination;
  PlanEntity? plan;
}

class RoutingMapComponent extends IRoutingMapComponent {
  static final Widget fromMarker = SizedBox(
    height: 24,
    child: FittedBox(
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 5.2,
            height: 5.2,
            decoration: const BoxDecoration(
              color: Color(0xffd81b60),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 3,
            height: 3,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    ),
  );

  static final Widget toMarker = Container(
    height: 24,
    color: Colors.transparent,
    child: FittedBox(
      fit: BoxFit.fitHeight,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 5),
            width: 7,
            height: 7,
            color: Colors.white,
          ),
          const Icon(Icons.location_on, size: 23, color: Colors.white),
          const Icon(Icons.location_on, color: Color(0xffd81b60), size: 20),
        ],
      ),
    ),
  );

  final MapRouteLocalRepository mapRouteHiveLocal =
      StorageMapRouteRepository(SharedPreferencesStorage());
  final IPlanRepository planRepository;

  RoutingMapComponent(super.controller, {IPlanRepository? customPlanRepository})
    : planRepository =
          customPlanRepository ??
          GraphQLPlanDataSource(ApiConfig().openTripPlannerUrl),
      super() {
    mapRouteHiveLocal.loadRepository().then((_) async {
      final results = await Future.wait([
        mapRouteHiveLocal.getOriginPosition(),
        mapRouteHiveLocal.getDestinationPosition(),
        mapRouteHiveLocal.getPlan(),
      ]);

      origin = results[0] as TrufiLocation?;
      destination = results[1] as TrufiLocation?;
      plan = results[2] as PlanEntity?;
      routingMapSelected.changeItinerary(plan?.itineraries?.firstOrNull);
      _rebuildGraphics();
    });
  }

  @override
  void changeItinerary(PlanItinerary? itinerary) {
    routingMapSelected.changeItinerary(itinerary);
    _rebuildGraphics();
  }

  @override
  void cleanOriginAndDestination() {
    origin = null;
    destination = null;
    plan = null;
    unawaited(mapRouteHiveLocal.saveOriginPosition(null));
    unawaited(mapRouteHiveLocal.saveDestinationPosition(null));
    unawaited(mapRouteHiveLocal.savePlan(null));
    routingMapSelected.changeItinerary(null);
    _rebuildGraphics();
  }

  @override
  Future<void> addOrigin(TrufiLocation location) async {
    origin = location;
    mapRouteHiveLocal.saveOriginPosition(location); // NUEVO
    _rebuildGraphics();
  }

  @override
  Future<void> addDestination(TrufiLocation location) async {
    destination = location;
    mapRouteHiveLocal.saveDestinationPosition(location); // NUEVO
    _rebuildGraphics();
  }

  @override
  Future<void> fetchPlan(BuildContext context) async {
    if (origin == null || destination == null) return;

    plan = await planRepository.fetchPlanAdvanced(
      fromLocation: origin!,
      toLocation: destination!,
    );

    if (plan?.itineraries != null && plan!.itineraries!.isNotEmpty) {
      final List<Future<void>> tasks = [];
      for (final itinerary in plan!.itineraries!) {
        for (final leg in itinerary.legs) {
          if (leg.transportMode == TransportMode.walk) continue;
          tasks.add(leg.selectedMarker.generateBytes(context));
          tasks.add(leg.unSelectedMarker.generateBytes(context));
        }
      }
      await Future.wait(tasks);
      await mapRouteHiveLocal.savePlan(plan);
    }
    _rebuildGraphics();
  }

  @override
  void selectNextItinerary() {
    final itineraries = plan?.itineraries;
    if (itineraries == null || itineraries.isEmpty) return;
    final currentIndex = routingMapSelected.selectedItinerary != null
        ? itineraries.indexOf(routingMapSelected.selectedItinerary!)
        : -1;
    final nextIndex = (currentIndex + 1) % itineraries.length;
    routingMapSelected.changeItinerary(itineraries[nextIndex]);
  }

  void _rebuildGraphics() {
    setMarkers(_buildMarkers());
    setLines(_buildLines());
  }

  List<TrufiMarker> _buildMarkers() {
    return [
      if (origin != null)
        TrufiMarker(
          id: origin!.description,
          position: origin!.position,
          widget: fromMarker,
          size: const Size(20, 20),
        ),
      if (destination != null)
        TrufiMarker(
          id: destination!.description,
          position: destination!.position,
          widget: toMarker,
          alignment: Alignment.topCenter,
        ),
      ...?plan?.itineraries?.expand((itinerary) {
        if (routingMapSelected.selectedItinerary == itinerary) return [];
        return itinerary.legs
            .where((leg) => leg.transportMode != TransportMode.walk)
            .map((leg) => leg.unSelectedMarker);
      }),
    ];
  }

  List<TrufiLine> _buildLines() {
    return [
      ...?plan?.itineraries?.expand((itinerary) {
        if (routingMapSelected.selectedItinerary == itinerary) return [];
        return itinerary.legs.map(
          (leg) => TrufiLine(
            id: leg.points,
            position: leg.accumulatedPoints,
            activeDots: leg.transportMode == TransportMode.walk,
            color: Colors.grey.withAlpha(128),
            layerLevel: 1,
            lineWidth: 4,
          ),
        );
      }),
    ];
  }
}
