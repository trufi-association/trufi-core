import 'package:flutter/material.dart';
import 'package:trufi_core/blocs/busses_info/bus_cubit.dart';

class BusItem extends StatelessWidget {
  final Bus busdata;
  BusItem({this.busdata});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      title: Text(busdata.properites.name.split(":").first),
      leading: const Icon(Icons.train),
    );
  }
}
