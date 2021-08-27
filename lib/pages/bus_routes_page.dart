import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:trufi_core/blocs/busses_info/bus_cubit.dart';
import 'package:trufi_core/pages/home/home_page.dart';
import 'package:trufi_core/widgets/stops_widget.dart';

class BusRoutesPage extends StatelessWidget {
  const BusRoutesPage({Key key}) : super(key: key);
  static const String route = '/busroutespage';

  @override
  Widget build(BuildContext context) {
    final Bus bus = ModalRoute.of(context).settings.arguments as Bus;
    bus.properites.name = bus.properites.name.split(":").first;
    return Scaffold(
      appBar: AppBar(
        title: Text(bus.properites.name),
      ),
      body: SafeArea(
          child: Column(
        children: [
          Flexible(
            flex: 5,
            child: Container(
              child: Center(
                child: Text('map will be here'),
              ),
              color: Colors.red,
              width: double.infinity,
            ),
          ),
          Flexible(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.train,
                          size: 30,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Text(
                          bus.properites.name,
                          style: const TextStyle(fontSize: 20),
                        )
                      ],
                    ),
                    Expanded(
                      child: StopsWidget(
                        bus: bus,
                      ),
                    ),
                  ],
                ),
              ))
        ],
      )),
    );
  }
}
