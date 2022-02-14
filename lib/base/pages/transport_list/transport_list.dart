import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routemaster/routemaster.dart';

import 'package:trufi_core/base/pages/transport_list/route_transports_cubit/route_transports_cubit.dart';
import 'package:trufi_core/base/pages/transport_list/services/models.dart';
import 'package:trufi_core/base/pages/transport_list/widgets/tile_transport.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/widgets/alerts/fetch_error_handler.dart';

class TransportList extends StatelessWidget {
  static const String route = "/TransportList";
  final Widget Function(BuildContext) drawerBuilder;

  const TransportList({
    Key? key,
    required this.drawerBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = TrufiBaseLocalization.of(context);
    final routeTransportsCubit = context.read<RouteTransportsCubit>();
    return BlocBuilder<RouteTransportsCubit, RouteTransportsState>(
      builder: (context, state) {
        final listTransports = state.transports;
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Text(localization.menuTransportList),
              ],
            ),
            actions: [
              if (!state.isLoading)
                IconButton(
                  onPressed: () {
                    if (!state.isLoading) {
                      routeTransportsCubit.refresh().catchError(
                          (error) => onFetchError(context, error as Exception));
                    }
                  },
                  icon: const Icon(Icons.refresh),
                ),
              const SizedBox(width: 10),
            ],
          ),
          drawer: drawerBuilder(context),
          body: Stack(
            children: [
              ListView.builder(
                itemCount: listTransports.length,
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                itemBuilder: (buildCOntext, index) {
                  final PatternOtp transport = listTransports[index];
                  return Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        child: TileTransport(
                          patternOtp: transport,
                          onTap: () {
                            final params =
                                '${TransportList.route}/${Uri.encodeQueryComponent(transport.code)}';
                            Routemaster.of(context).push(params);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              if (state.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
