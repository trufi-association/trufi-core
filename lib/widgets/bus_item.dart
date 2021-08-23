import 'package:flutter/material.dart';
import 'package:trufi_core/blocs/busses_info/bus_cubit.dart';
import 'package:trufi_core/pages/bus_routes_page.dart';
import 'package:trufi_core/pages/home/home_page.dart';

class BusItem extends StatelessWidget {
  final Bus busdata;
  BusItem({this.busdata});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.of(context).pushNamed(BusRoutesPage.route,arguments: busdata);
      },
      title: Text(busdata.properites.name.split(":").first),
      leading: const Icon(Icons.train),
    );
  }
}
