import 'package:flutter/material.dart';

class BusItem extends StatelessWidget {
  String busname;
  BusItem({this.busname});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      title: Text(busname),
      leading: const Icon(Icons.train),
    );
  }
}
