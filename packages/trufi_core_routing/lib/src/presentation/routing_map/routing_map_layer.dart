import 'package:flutter/material.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';

import '../../domain/entities/itinerary.dart';
import '../../domain/entities/itinerary_leg.dart';
import '../../domain/entities/plan.dart';
import '../../domain/entities/routing_location.dart';
import '../../domain/entities/transport_mode.dart';
import 'leg_marker_factory.dart';

/// Callback to get the transport icon for a leg.
typedef TransportIconBuilder = Widget Function(ItineraryLeg leg);

/// Layer that displays routing information on the map.
class RoutingMapLayer extends TrufiLayer {
  static const String layerId = 'routing-map-layer';

  RoutingMapLayer(
    super.controller, {
    required this.transportIconBuilder,
    int layerLevel = 2,
  }) : super(id: layerId, layerLevel: layerLevel) {
    _selectedLayer = SelectedItineraryLayer(
      controller,
      transportIconBuilder: transportIconBuilder,
      layerLevel: layerLevel + 1,
    );
  }

  final TransportIconBuilder transportIconBuilder;
  late final SelectedItineraryLayer _selectedLayer;

  RoutingLocation? _origin;
  RoutingLocation? _destination;
  Plan? _plan;

  RoutingLocation? get origin => _origin;
  RoutingLocation? get destination => _destination;
  Plan? get plan => _plan;
  Itinerary? get selectedItinerary => _selectedLayer.selectedItinerary;

  /// Sets the origin location.
  void setOrigin(RoutingLocation? location) {
    _origin = location;
    _rebuildGraphics();
  }

  /// Sets the destination location.
  void setDestination(RoutingLocation? location) {
    _destination = location;
    _rebuildGraphics();
  }

  /// Sets the plan with itineraries.
  void setPlan(Plan? plan) {
    _plan = plan;
    _selectedLayer.changeItinerary(plan?.itineraries?.firstOrNull);
    _rebuildGraphics();
  }

  /// Changes the selected itinerary.
  void changeItinerary(Itinerary? itinerary) {
    _selectedLayer.changeItinerary(itinerary);
    _rebuildGraphics();
  }

  /// Selects the next itinerary in the list.
  void selectNextItinerary() {
    final itineraries = _plan?.itineraries;
    if (itineraries == null || itineraries.isEmpty) return;

    final currentIndex = _selectedLayer.selectedItinerary != null
        ? itineraries.indexOf(_selectedLayer.selectedItinerary!)
        : -1;
    final nextIndex = (currentIndex + 1) % itineraries.length;
    changeItinerary(itineraries[nextIndex]);
  }

  /// Clears all routing data.
  void clear() {
    _origin = null;
    _destination = null;
    _plan = null;
    _selectedLayer.changeItinerary(null);
    _rebuildGraphics();
  }

  void _rebuildGraphics() {
    setMarkers(_buildMarkers());
    setLines(_buildLines());
  }

  List<TrufiMarker> _buildMarkers() {
    return [
      if (_origin != null)
        TrufiMarker(
          id: 'origin-${_origin!.description}',
          position: _origin!.position,
          widget: _buildOriginMarker(),
          size: const Size(20, 20),
        ),
      if (_destination != null)
        TrufiMarker(
          id: 'destination-${_destination!.description}',
          position: _destination!.position,
          widget: _buildDestinationMarker(),
          alignment: Alignment.topCenter,
        ),
      ..._buildUnselectedItineraryMarkers(),
    ];
  }

  List<TrufiMarker> _buildUnselectedItineraryMarkers() {
    if (_plan?.itineraries == null) return [];

    return _plan!.itineraries!
        .where((itinerary) => _selectedLayer.selectedItinerary != itinerary)
        .expand((itinerary) => itinerary.legs
            .where((leg) => leg.transportMode != TransportMode.walk)
            .map((leg) => LegMarkerFactory.createUnselectedMarker(
                  leg: leg,
                  transportIcon: transportIconBuilder(leg),
                )))
        .toList();
  }

  List<TrufiLine> _buildLines() {
    if (_plan?.itineraries == null) return [];

    return _plan!.itineraries!
        .where((itinerary) => _selectedLayer.selectedItinerary != itinerary)
        .expand((itinerary) => itinerary.legs.map(
              (leg) => LegMarkerFactory.createLine(
                leg: leg,
                layerLevel: 1,
                isSelected: false,
              ),
            ))
        .toList();
  }

  Widget _buildOriginMarker() {
    return SizedBox(
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
  }

  Widget _buildDestinationMarker() {
    return Container(
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
  }

  @override
  void dispose() {
    _selectedLayer.dispose();
    super.dispose();
  }
}

/// Layer that displays the selected itinerary.
class SelectedItineraryLayer extends TrufiLayer {
  static const String layerId = 'selected-itinerary-layer';

  SelectedItineraryLayer(
    super.controller, {
    required this.transportIconBuilder,
    required int layerLevel,
  }) : super(id: layerId, layerLevel: layerLevel);

  final TransportIconBuilder transportIconBuilder;
  Itinerary? selectedItinerary;

  void changeItinerary(Itinerary? itinerary) {
    selectedItinerary = itinerary;
    _rebuildGraphics();
  }

  void _rebuildGraphics() {
    setMarkers(_buildMarkers());
    setLines(_buildLines());
  }

  List<TrufiMarker> _buildMarkers() {
    if (selectedItinerary == null) return [];

    return selectedItinerary!.legs
        .where((leg) => leg.transportMode != TransportMode.walk)
        .map((leg) => LegMarkerFactory.createSelectedMarker(
              leg: leg,
              transportIcon: transportIconBuilder(leg),
            ))
        .toList();
  }

  List<TrufiLine> _buildLines() {
    if (selectedItinerary == null) return [];

    return selectedItinerary!.legs
        .map((leg) => LegMarkerFactory.createLine(
              leg: leg,
              layerLevel: layerLevel,
              isSelected: true,
            ))
        .toList();
  }
}
