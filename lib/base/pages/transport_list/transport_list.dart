import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routemaster/routemaster.dart';

import 'package:trufi_core/base/blocs/theme/theme_cubit.dart';
import 'package:trufi_core/base/models/map_provider/trufi_map_definition.dart';
import 'package:trufi_core/base/pages/transport_list/route_transports_cubit/route_transports_cubit.dart';
import 'package:trufi_core/base/pages/transport_list/services/models.dart';
import 'package:trufi_core/base/pages/transport_list/transport_list_detail/transport_list_detail.dart';
import 'package:trufi_core/base/pages/transport_list/widgets/tile_transport.dart';
import 'package:trufi_core/base/widgets/alerts/fetch_error_handler.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';

class TransportList extends StatefulWidget {
  static const String route = "/TransportList";
  final Widget Function(BuildContext) drawerBuilder;
  final MapTransportProvider mapTransportProvider;

  const TransportList({
    Key? key,
    required this.drawerBuilder,
    required this.mapTransportProvider,
  }) : super(key: key);

  @override
  State<TransportList> createState() => _TransportListState();
}

class _TransportListState extends State<TransportList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (duration) => loadRoute(),
    );
  }

  @override
  void didUpdateWidget(covariant TransportList oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback(
      (duration) => loadRoute(),
    );
  }

  void loadRoute() {
    final transportListId = RouteData.of(context).queryParameters['id'];
    if (transportListId != null) {
      showTrufiDialog(
        context: context,
        useSafeArea: false,
        builder: (BuildContext context) => TransportListDetail(
          id: Uri.decodeQueryComponent(transportListId),
          mapTransportProvider: widget.mapTransportProvider.rebuild(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeCubit>().themeData(context);
    final routeTransportsCubit = context.read<RouteTransportsCubit>();
    return BlocBuilder<RouteTransportsCubit, RouteTransportsState>(
      builder: (context, state) {
        final query = state.queryFilter.trim().toLowerCase();
        final listTransports = state.transports;
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Expanded(
                  child: Theme(
                    data: theme.copyWith(
                      textSelectionTheme: theme.textSelectionTheme.copyWith(
                        cursorColor: theme.colorScheme.secondary,
                        selectionColor:
                            theme.colorScheme.secondary.withOpacity(0.7),
                      ),
                      hintColor: Colors.grey[300],
                      textTheme: theme.textTheme.copyWith(
                        headline6: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    child: TextField(
                      controller: null,
                      onChanged: routeTransportsCubit.filterList,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            MaterialLocalizations.of(context).searchFieldLabel,
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
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
          drawer: widget.drawerBuilder(context),
          body: Stack(
            children: [
              Scrollbar(
                thumbVisibility: true,
                interactive: true,
                thickness: 8,
                child: ListView.builder(
                  itemCount: listTransports.length,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  itemBuilder: (buildContext, index) {
                    final PatternOtp transport = listTransports[index];
                    final name = '${transport.route?.shortName}'.toLowerCase();
                    return name.contains(query)
                        ? Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            child: TileTransport(
                              patternOtp: transport,
                              onTap: () {
                                Routemaster.of(context).push(
                                  TransportList.route,
                                  queryParameters: {'id': transport.code},
                                );
                              },
                            ),
                          )
                        : Container();
                  },
                ),
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
