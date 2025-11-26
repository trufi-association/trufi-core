import 'package:flutter/material.dart';
import 'package:trufi_core/pages/home/widgets/routing_map/routing_map_controller.dart';
import 'package:trufi_core/widgets/tabs/responsive_tab.dart';

class TravelModeSelector extends StatelessWidget {
  final RoutingMapComponent routingMapComponent;
  const TravelModeSelector({super.key, required this.routingMapComponent});

  @override
  Widget build(BuildContext context) {
    return ResponsiveTab(
      tabs: [
        TabItem(index: 0, text: "14 min", icon: Icons.car_crash),
        TabItem(index: 1, text: "--", icon: Icons.two_wheeler),
        TabItem(index: 2, text: "24 min", icon: Icons.train_outlined),
        TabItem(index: 3, text: "1 hr 50", icon: Icons.directions_walk),
        TabItem(index: 4, text: "34 min", icon: Icons.directions_bike),
      ],
      children: [
        Container(color: Colors.orange, height: 60),
        Container(color: Colors.amber, height: 60),
        // TransitModeSection(routingMapComponent: routingMapComponent),
        Container(color: Colors.red, height: 60),
        Container(color: Colors.purple, height: 60),
      ],
    );
  }
}
