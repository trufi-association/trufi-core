import 'package:flutter/material.dart';
import 'package:trufi_core/base/models/map_provider_collection/map_engine.dart';
import 'package:trufi_core/base/models/map_provider_collection/trufi_map_definition.dart';
import 'package:trufi_core/base/pages/home/widgets/trufi_map_route/maps/trufi_core_maps/trufi_core_maps_route_provider.dart';
import 'package:trufi_core/base/widgets/choose_location/maps/trufi_core_maps/trufi_core_maps_choose_location_provider.dart';

/// Map provider collection using trufi_core_maps package.
///
/// This provides an alternative to LeafletMapCollection that uses the
/// trufi_core_maps package for map rendering.
///
/// Example usage:
/// ```dart
/// TrufiCoreMapsCollection(
///   mapEngines: [
///     MapLibreEngine(styleString: 'https://tiles.openfreemap.org/styles/liberty'),
///     FlutterMapEngine(),
///   ],
///   defaultEngineIndex: 0, // Use MapLibre as default
/// )
/// ```
class TrufiCoreMapsCollection implements ITrufiMapProvider {
  /// List of available map engines
  final List<ITrufiMapEngine> mapEngines;

  /// Index of the default engine to use (defaults to 0)
  final int defaultEngineIndex;

  const TrufiCoreMapsCollection({
    required this.mapEngines,
    this.defaultEngineIndex = 0,
  });

  /// Get the default map engine
  ITrufiMapEngine get defaultEngine => mapEngines[defaultEngineIndex];

  @override
  MapChooseLocationProvider mapChooseLocationProvider() {
    return TrufiCoreMapsChooseLocationProvider.create(
      mapEngine: defaultEngine,
    );
  }

  @override
  MapRouteProvider mapRouteProvider({
    Uri? shareBaseItineraryUri,
    WidgetBuilder? overlapWidget,
  }) {
    return TrufiCoreMapsRouteProvider.create(
      mapEngine: defaultEngine,
      availableEngines: mapEngines,
      shareBaseItineraryUri: shareBaseItineraryUri,
      overlapWidget: overlapWidget,
    );
  }

  @override
  MapTransportProvider mapTransportProvider({
    Uri? shareBaseRouteUri,
  }) {
    // TODO: Implement TrufiCoreMapsTransportProvider
    throw UnimplementedError(
      'TrufiCoreMapsCollection.mapTransportProvider is not yet implemented. '
      'Use LeafletMapCollection for transport display.',
    );
  }

  @override
  MapRouteEditorProvider mapRouteEditorProvider({bool isSelectionArea = true}) {
    // TODO: Implement TrufiCoreMapsRouteEditorProvider
    throw UnimplementedError(
      'TrufiCoreMapsCollection.mapRouteEditorProvider is not yet implemented. '
      'Use LeafletMapCollection for route editing.',
    );
  }
}
