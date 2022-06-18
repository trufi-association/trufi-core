import 'package:flutter/material.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/pages/transport_list/services/models.dart';

import 'stop_item_tile.dart';

class BottomStopsDetails extends StatelessWidget {
  final RouteEntity routeOtp;
  final List<Stop> stops;
  final Function(TrufiLatLng) moveTo;
  const BottomStopsDetails({
    Key? key,
    required this.routeOtp,
    required this.stops,
    required this.moveTo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        itemCount: stops.length,
        itemBuilder: (contextBuilde, index) {
          final Stop stop = stops[index];
          return Padding(
            padding: index == 0
                ? const EdgeInsets.only(top: 8)
                : const EdgeInsets.all(0),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => moveTo(TrufiLatLng(stop.lat, stop.lon)),
                child: StopItemTile(
                  stop: stop,
                  color: routeOtp.primaryColor,
                  isLastElement: index == stops.length - 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
