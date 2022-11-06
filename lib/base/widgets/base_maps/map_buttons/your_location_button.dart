import 'package:flutter/material.dart';

import 'package:trufi_core/base/blocs/providers/gps_location_provider.dart';
import 'package:trufi_core/base/models/map_provider/i_trufi_map_controller.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';

class YourLocationButton extends StatefulWidget {
  final ITrufiMapController trufiMapController;
  final void Function(bool tracking) setTracking;
  final bool isTrackingPosition;

  const YourLocationButton({
    Key? key,
    required this.trufiMapController,
    required this.setTracking,
    required this.isTrackingPosition,
  }) : super(key: key);

  @override
  State<YourLocationButton> createState() => _YourLocationButtonState();
}

class _YourLocationButtonState extends State<YourLocationButton>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<TrufiLatLng?>(
      initialData: null,
      stream: GPSLocationProvider().streamLocation,
      builder: (context, snapshot) {
        final currentLocation = snapshot.data;
        widget.trufiMapController.onReady.then((value) {
          if (currentLocation != null && widget.isTrackingPosition) {
            widget.trufiMapController.moveToYourLocation(
              location: currentLocation,
              context: context,
              zoom: 15.5,
              tickerProvider: this,
            );
          }
        });
        return FloatingActionButton(
          onPressed: () async {
            if (currentLocation != null) {
              widget.setTracking(!widget.isTrackingPosition);
            } else {
              await GPSLocationProvider().startLocation(context, mounted);
            }
          },
          heroTag: null,
          child: currentLocation == null
              ? Stack(
                  children: const [
                    Center(
                      child: Icon(
                        Icons.location_searching,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                    Center(
                      child: Icon(
                        Icons.question_mark,
                        color: Colors.red,
                        size: 10,
                      ),
                    ),
                  ],
                )
              : Icon(
                  widget.isTrackingPosition
                      ? Icons.my_location
                      : Icons.location_searching,
                  color: widget.isTrackingPosition
                      ? theme.colorScheme.secondary
                      : theme.iconTheme.color,
                ),
        );
      },
    );
  }
}
