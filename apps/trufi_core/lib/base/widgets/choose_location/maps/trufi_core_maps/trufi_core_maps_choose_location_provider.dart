import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/models/map_provider_collection/i_trufi_map_controller.dart';
import 'package:trufi_core/base/models/map_provider_collection/map_engine.dart';
import 'package:trufi_core/base/models/map_provider_collection/trufi_map_definition.dart';
import 'package:trufi_core/base/widgets/base_maps/trufi_core_maps/trufi_core_maps_controller.dart';
import 'package:trufi_core/base/widgets/choose_location/maps/trufi_core_maps/trufi_core_maps_choose_location.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';

class TrufiCoreMapsChooseLocationProvider
    implements MapChooseLocationProvider {
  @override
  final ITrufiMapController trufiMapController;
  @override
  final MapChooseLocationBuilder mapChooseLocationBuilder;

  final ITrufiMapEngine _mapEngine;

  @override
  MapChooseLocationProvider rebuild() {
    return TrufiCoreMapsChooseLocationProvider.create(mapEngine: _mapEngine);
  }

  const TrufiCoreMapsChooseLocationProvider({
    required this.trufiMapController,
    required this.mapChooseLocationBuilder,
    required ITrufiMapEngine mapEngine,
  }) : _mapEngine = mapEngine;

  factory TrufiCoreMapsChooseLocationProvider.create({
    required ITrufiMapEngine mapEngine,
  }) {
    final controller = TrufiCoreMapsController(
      initialCameraPosition: const TrufiCameraPosition(
        target: latlng.LatLng(0, 0),
        zoom: 12.0,
      ),
    );

    return TrufiCoreMapsChooseLocationProvider(
      trufiMapController: controller,
      mapEngine: mapEngine,
      mapChooseLocationBuilder: (mapContext, onCenterChanged) {
        // Get configuration from context if available
        final mapConfig = mapContext.read<MapConfigurationCubit>().state;
        controller.mapController.updateCamera(
          target: latlng.LatLng(
            mapConfig.center.latitude,
            mapConfig.center.longitude,
          ),
          zoom: mapConfig.onlineZoom,
        );

        return TrufiCoreMapsChooseLocation(
          trufiMapController: controller,
          onCenterChanged: onCenterChanged,
          mapEngine: mapEngine,
        );
      },
    );
  }
}
