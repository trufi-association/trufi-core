import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routemaster/routemaster.dart';

import 'package:trufi_core/base/models/map_provider_collection/trufi_map_definition.dart';
import 'package:trufi_core/base/models/transit_route/transit_route.dart';
import 'package:trufi_core/base/pages/transport_list/transport_list_detail/transport_list_detail.dart';
import 'package:trufi_core/base/pages/transport_list/widgets/tile_transport.dart';
import 'package:trufi_core/base/providers/transit_route/route_transports_cubit/route_transports_cubit.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/widgets/alerts/fetch_error_handler.dart';

class TransportList extends StatefulWidget {
  static const String route = "/TransportList";
  final Widget Function(BuildContext) drawerBuilder;
  final MapTransportProvider mapTransportProvider;
  final MapRouteEditorProvider mapRouteEditorProvider;

  const TransportList({
    super.key,
    required this.drawerBuilder,
    required this.mapTransportProvider,
    required this.mapRouteEditorProvider,
  });

  @override
  State<TransportList> createState() => _TransportListState();
}

class _TransportListState extends State<TransportList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      loadRoute();
      context.read<RouteTransportsCubit>().filterTransports("");
    });
  }

  @override
  void didUpdateWidget(covariant TransportList oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      loadRoute();
    });
  }

  void loadRoute() {
    final transportListId = RouteData.of(context).queryParameters['id'];
    if (transportListId != null) {
      TransportListDetail.showRouteDetails(
        context,
        id: Uri.decodeQueryComponent(transportListId),
        mapTransportProvider: widget.mapTransportProvider.rebuild(),
        mapRouteEditorProvider: widget.mapRouteEditorProvider,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiBaseLocalization.of(context);
    final routeTransportsCubit = context.watch<RouteTransportsCubit>();
    final routeTransportsState = routeTransportsCubit.state;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: null,
                autofocus: true,
                autocorrect: false,
                onChanged: (onChanged) {
                  routeTransportsCubit.filterTransports(
                    onChanged.trim().toLowerCase(),
                  );
                },
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: MaterialLocalizations.of(context).searchFieldLabel,
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (!routeTransportsState.isLoading)
            IconButton(
              onPressed: () {
                routeTransportsCubit.refresh().catchError(
                    (error) => onFetchError(context, error as Exception));
              },
              icon: const Icon(Icons.refresh),
            ),
          const SizedBox(width: 10),
        ],
      ),
      drawer: widget.drawerBuilder(context),
      body: Stack(
        children: [
          if (routeTransportsState.filterTransports.isEmpty &&
              !routeTransportsState.isLoading)
            Center(
              child: Text(
                localization.commonNoResults,
                style: theme.textTheme.bodyLarge,
              ),
            )
          else
            Scrollbar(
              thumbVisibility: true,
              trackVisibility: true,
              interactive: true,
              thickness: 8.0,
              child: ListView.builder(
                itemCount: routeTransportsState.filterTransports.length,
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                itemBuilder: (buildContext, index) {
                  final TransitRoute transport =
                      routeTransportsState.filterTransports[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: TileTransport(
                      patternOtp: transport,
                      onTap: () {
                        Routemaster.of(context).replace(
                          TransportList.route,
                          queryParameters: {'id': transport.code},
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          if (routeTransportsState.isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
