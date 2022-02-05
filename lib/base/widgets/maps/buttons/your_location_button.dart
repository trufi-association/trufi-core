import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';

import 'package:trufi_core/base/blocs/providers/gps_location_provider.dart';
import 'package:trufi_core/base/widgets/maps/trufi_map_cubit/trufi_map_cubit.dart';

class YourLocationButton extends StatefulWidget {
  final TrufiMapController trufiMapController;

  const YourLocationButton({
    Key? key,
    required this.trufiMapController,
  }) : super(key: key);

  @override
  _YourLocationButtonState createState() => _YourLocationButtonState();
}

class _YourLocationButtonState extends State<YourLocationButton>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final mapConfiguratiom = context.read<MapConfigurationCubit>().state;
    return FloatingActionButton(
      onPressed: () async {
        final locationProvider = GPSLocationProvider();
        final currentLocation = locationProvider.myLocation;
        if (currentLocation != null) {
          widget.trufiMapController.moveToYourLocation(
            location: currentLocation,
            context: context,
            zoom: mapConfiguratiom.chooseLocationZoom,
            tickerProvider: this,
          );
        } else {
          await locationProvider.startLocation(context);
        }
      },
      heroTag: null,
      child: const Icon(
        Icons.my_location,
      ),
    );
  }
}
