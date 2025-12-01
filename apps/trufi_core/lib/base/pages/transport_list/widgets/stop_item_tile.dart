import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/models/transit_route/stops.dart';

class StopItemTile extends StatelessWidget {
  final Stop stop;
  final Color color;
  final bool isFirstElement;
  final bool isLastElement;

  const StopItemTile({
    super.key,
    required this.stop,
    required this.color,
    this.isFirstElement = false,
    this.isLastElement = false,
  });

  @override
  Widget build(BuildContext context) {
    final mapConfiguratiom = context.read<MapConfigurationCubit>().state;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: !isLastElement ? 4 : 0,
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              if (isFirstElement)
                SizedBox(
                  height: 20,
                  width: 20,
                  child: mapConfiguratiom.markersConfiguration.fromMarker,
                )
              else if (isLastElement)
                SizedBox(
                  height: 28,
                  width: 28,
                  child: mapConfiguratiom.markersConfiguration.toMarker,
                )
              else
                Container(
                  height: 12,
                  width: 20,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              if (!isLastElement)
                Expanded(
                  child: Container(
                    width: 4,
                    color: color,
                  ),
                ),
            ],
          ),
          SizedBox(
            width: !isLastElement ? 10 : 6,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: !isLastElement ? 0 : 4),
              child: Text("${stop.name}\n"),
            ),
          ),
        ],
      ),
    );
  }
}
