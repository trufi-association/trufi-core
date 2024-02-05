import 'package:flutter/material.dart';

import 'package:trufi_core/base/models/transit_route/stops.dart';
import 'package:trufi_core/base/models/transit_route/transit_info.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';

import 'stop_item_tile.dart';

class BottomStopsDetails extends StatelessWidget {
  final TransitInfo routeOtp;
  final List<Stop> stops;
  final List<TrufiLatLng> geometry;
  final Function(TrufiLatLng) moveTo;
  const BottomStopsDetails({
    super.key,
    required this.routeOtp,
    required this.stops,
    required this.geometry,
    required this.moveTo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        itemCount: stops.length + 1,
        itemBuilder: (contextBuilde, index) {
          if (index == stops.length) {
            return Padding(
              padding: const EdgeInsets.all(0),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => moveTo(geometry.last),
                  child: StopItemTile(
                    stop: Stop(
                      name: routeOtp.longNameLast,
                      lat: geometry.last.latitude,
                      lon: geometry.last.longitude,
                    ),
                    color: routeOtp.backgroundColor,
                    isFirstElement: index == 0,
                    isLastElement: true,
                  ),
                ),
              ),
            );
          }
          final Stop stop = stops[index];
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => moveTo(geometry.first),
                  child: StopItemTile(
                    stop: Stop(
                      name: routeOtp.longNameStart,
                      lat: geometry.first.latitude,
                      lon: geometry.first.longitude,
                    ),
                    color: routeOtp.backgroundColor,
                    isFirstElement: true,
                    isLastElement: false,
                  ),
                ),
              ),
            );
          }
          return Padding(
            padding: EdgeInsets.zero,
            child: InkWell(
              onTap: () => moveTo(TrufiLatLng(stop.lat, stop.lon)),
              child: StopItemTile(
                stop: stop,
                color: routeOtp.backgroundColor,
              ),
            ),
          );
        },
      ),
    );
  }
}
