import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';

import 'package:trufi_core/base/blocs/providers/gps_location_provider.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/widgets/base_maps/google_maps/google_map_controller.dart';
import 'package:trufi_core/base/widgets/base_maps/google_maps/widget_marker/marker_generator.dart';
import 'package:trufi_core/base/widgets/base_maps/map_buttons/your_location_button.dart';

class TGoogleMap extends StatelessWidget {
  final TGoogleMapController trufiMapController;
  final Widget? floatingActionButtons;
  final Function(LatLng)? onTap;
  final Function(LatLng)? onLongPress;
  final Function(CameraPosition)? onCameraMove;
  const TGoogleMap({
    Key? key,
    required this.trufiMapController,
    this.floatingActionButtons,
    this.onTap,
    this.onLongPress,
    this.onCameraMove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mapConfiguratiom = context.read<MapConfigurationCubit>().state;
    return Stack(
      children: [
        StreamBuilder<TrufiLatLng?>(
          initialData: null,
          stream: GPSLocationProvider().streamLocation,
          builder: (context, snapshot) {
            final currentLocation = snapshot.data;
            return MarkerGenerator(
              widgetMarkers: [
                if (currentLocation != null)
                  WidgetMarker(
                    position: LatLng(
                        currentLocation.latitude, currentLocation.longitude),
                    markerId: const MarkerId('MyLocationMarkerId'),
                    widget: SizedBox(
                      height: 30,
                      child: mapConfiguratiom
                          .markersConfiguration.yourLocationMarker,
                    ),
                    anchor: const Offset(0.5, 0.5),
                    zIndex: 10,
                    consumeTapEvents: true,
                  ),
              ],
              onMarkerGenerated: trufiMapController.onMarkerGenerated,
            );
          },
        ),
        BlocBuilder<TGoogleMapController, GoogleMapState>(
          bloc: trufiMapController,
          builder: (context, state) {
            return GoogleMap(
              mapToolbarEnabled: false,
              myLocationButtonEnabled: false,
              myLocationEnabled: false,
              minMaxZoomPreference: const MinMaxZoomPreference(10, 18),
              initialCameraPosition: const CameraPosition(
                target: LatLng(-17.3895, -66.1568),
                zoom: 14,
              ),
              onMapCreated: (GoogleMapController controller) {
                trufiMapController.mapController = controller;
                if (!trufiMapController.readyCompleter.isCompleted) {
                  trufiMapController.readyCompleter.complete();
                }
              },
              onCameraMove: onCameraMove,
              zoomControlsEnabled: false,
              markers: state.markers,
              polylines: state.polylines,
              onTap: onTap,
              onLongPress: onLongPress,
            );
          },
        ),
        Positioned(
          bottom: 16.0,
          right: 16.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              if (floatingActionButtons != null) floatingActionButtons!,
              const Padding(padding: EdgeInsets.all(4.0)),
              YourLocationButton(
                trufiMapController: trufiMapController,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
