import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trufi_core/blocs/gps_location/location_provider_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/widgets/alerts.dart';
import 'package:trufi_core/widgets/map/trufi_map_controller.dart';

import 'map/trufi_map_controller.dart';

class YourLocationButton extends StatefulWidget {
  const YourLocationButton({@required this.trufiMapController});
  final TrufiMapController trufiMapController;

  @override
  _YourLocationButtonState createState() => _YourLocationButtonState();
}

class _YourLocationButtonState extends State<YourLocationButton>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).backgroundColor,
      onPressed: () async {
        try {
          final location =
              context.read<LocationProviderCubit>().state.currentLocation;
          widget.trufiMapController.moveToYourLocation(
            location: location,
            context: context,
            tickerProvider: this,
          );
        } on PermissionDeniedException catch (_) {
          showDialog(
            context: context,
            builder: (context) => buildAlertLocationServicesDenied(context),
          );
        }
      },
      heroTag: null,
      child: const Icon(
        Icons.my_location,
        color: Colors.black,
      ),
    );
  }
}
