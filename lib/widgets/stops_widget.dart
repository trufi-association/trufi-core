import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:trufi_core/blocs/busses_info/bus_cubit.dart';

class StopsWidget extends StatelessWidget {
  StopsWidget({@required this.bus});
  Bus bus;

  @override
  Widget build(BuildContext context) {
    Future<Map<String, dynamic>> stops =
        context.read<BusCubit>().getStopsdata();
    List nodes = bus.geometry.nodes;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder(
        future: stops,
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          return ListView.builder(
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(snapshot.data['${nodes[index]}'] as String),
              );
            },
            itemCount: nodes.length,
          );
        },
      ),
    );
  }
}
