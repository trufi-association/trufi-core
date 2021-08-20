import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

import 'package:trufi_core/blocs/busses_info/bus_cubit.dart';
import 'package:trufi_core/widgets/bus_item.dart';
import 'package:trufi_core/widgets/trufi_drawer.dart';

class ListOfBusses extends StatelessWidget {
  const ListOfBusses({Key key}) : super(key: key);
  static const String route = '/listofbusses';

  @override
  Widget build(BuildContext context) {
    final Future<List<Bus>> buslist = context.read<BusCubit>().getBusses();
    return Scaffold(
        drawer: const TrufiDrawer(ListOfBusses.route),
        appBar: AppBar(
          title: const Text('List of Busses'),
        ),
        //TODO:create a list view and pass the data required
        body: FutureBuilder(
          future: buslist,
          builder: (context, AsyncSnapshot<List<Bus>> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return BusItem(
                        busname: snapshot.data[index].name.split(':').first);
                  });
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ));
  }
}
