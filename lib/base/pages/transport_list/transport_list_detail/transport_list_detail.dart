import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

import 'package:trufi_core/base/models/map_provider_collection/trufi_map_definition.dart';
import 'package:trufi_core/base/models/transit_route/transit_route.dart';
import 'package:trufi_core/base/models/enums/transport_mode.dart';
import 'package:trufi_core/base/pages/transport_list/translations/transport_list_localizations.dart';
import 'package:trufi_core/base/pages/transport_list/widgets/bottom_stops_detail.dart';
import 'package:trufi_core/base/providers/transit_route/route_transports_cubit/route_transports_cubit.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/widgets/alerts/fetch_error_handler.dart';
import 'package:trufi_core/base/widgets/custom_scrollable_container.dart';
import 'package:trufi_core/base/widgets/material_widgets/custom_material_widgets.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';

class TransportListDetail extends StatefulWidget {
  static Future<bool?> showRouteDetails(
    BuildContext buildContext, {
    required String id,
    required MapTransportProvider mapTransportProvider,
    required MapRouteEditorProvider mapRouteEditorProvider,
  }) async {
    return await Navigator.push<bool>(
      buildContext,
      MaterialPageRoute(
        builder: (context) => BaseTrufiPage(
          child: TransportListDetail(
            id: id,
            mapTransportProvider: mapTransportProvider,
            mapRouteEditorProvider: mapRouteEditorProvider,
          ),
        ),
      ),
    );
  }

  final String id;
  final MapTransportProvider mapTransportProvider;
  final MapRouteEditorProvider mapRouteEditorProvider;

  const TransportListDetail({
    super.key,
    required this.id,
    required this.mapTransportProvider,
    required this.mapRouteEditorProvider,
  });

  @override
  State<TransportListDetail> createState() => _TransportListDetailState();
}

class _TransportListDetailState extends State<TransportListDetail> {
  TransitRoute? transitRoute;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((duration) async {
      final routeTransportsCubit = context.read<RouteTransportsCubit>();
      transitRoute = routeTransportsCubit.state.transports.firstWhereOrNull(
        (element) => element.code == widget.id,
      );
      // RouteReportScreen.reportRoute(
      //   context,
      //   mapRouteEditorProvider: widget.mapRouteEditorProvider,
      //   transitRoute: transitRoute!,
      // );
      if (!mounted) return;
      try {
        if (transitRoute == null) {
          await routeTransportsCubit.load();
          transitRoute = routeTransportsCubit.state.transports.firstWhereOrNull(
            (element) => element.code == widget.id,
          );
        }
        if (transitRoute != null) {
          await routeTransportsCubit.fetchDataPattern(transitRoute!).then(
            (value) {
              if (mounted) {
                setState(() {
                  transitRoute = value;
                });
              }
            },
          );
        }
      } catch (e) {
        onFetchError(context, e as Exception);
      }
    });
    BackButtonInterceptor.add(myInterceptor, context: context);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (!stopDefaultButtonEvent) {
      Navigator.of(context).pop();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final localization = TrufiBaseLocalization.of(context);
    final localizationTL = TransportListLocalization.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: AppBar(
          titleSpacing: 0,
          toolbarHeight: 65,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (transitRoute?.route?.mode != null)
                Text(
                  '${transitRoute!.route!.mode!.getTranslate(localization)} - ${transitRoute!.route?.shortName ?? ''}',
                  style: const TextStyle(fontSize: 18),
                ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      transitRoute?.route?.longNameData ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[400],
                        fontSize: 13,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TrufiPopupMenuButton(
              position: PopupMenuPosition.over,
              offset: const Offset(0, 56),
              icon: const Icon(Icons.more_vert),
              splashRadius: 20,
              itemBuilder: (BuildContext itemContext) =>
                  <PopupMenuEntry<String>>[
                if (transitRoute != null &&
                    widget.mapTransportProvider.shareBaseRouteUri != null)
                  PopupMenuItem(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    value: "ShareRoute",
                    child: Row(
                      children: [
                        Icon(
                          Icons.share,
                          color: theme.iconTheme.color,
                        ),
                        const SizedBox(width: 8),
                        Text(localizationTL.shareRoute)
                      ],
                    ),
                  ),
                // PopupMenuItem(
                //   padding:
                //       const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                //   value: "OpenEditor",
                //   child: Row(
                //     children: [
                //       Icon(
                //         Icons.edit_location_alt,
                //         color: theme.iconTheme.color,
                //       ),
                //       const SizedBox(width: 8),
                //       const Text('Open with editor'),
                //     ],
                //   ),
                // ),
                // PopupMenuItem(
                //   padding:
                //       const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                //   value: "ReportRoute",
                //   child: Row(
                //     children: [
                //       Icon(
                //         Icons.error,
                //         color: theme.iconTheme.color,
                //       ),
                //       const SizedBox(width: 8),
                //       const Text('Report Route')
                //     ],
                //   ),
                // ),
              ],
              onSelected: (value) async {
                switch (value) {
                  case 'ShareRoute':
                    Share.share(
                        widget.mapTransportProvider.shareBaseRouteUri!.replace(
                      queryParameters: {
                        "id": transitRoute!.code,
                      },
                    ).toString());
                    break;
                  case 'OpenEditor':
                    // await RouteEditorScreen.editRoute(
                    //   context,
                    //   mapTransportProvider: widget.mapTransportProvider,
                    // );
                    break;
                  case 'ReportRoute':
                    break;
                  default:
                }
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: theme.cardColor,
        child: SafeArea(
          child: BlocBuilder<RouteTransportsCubit, RouteTransportsState>(
            builder: (context, state) {
              return CustomScrollableContainer(
                openedPosition: 200,
                bottomPadding: 0,
                body: Stack(
                  children: [
                    Column(
                      children: [
                        if (state.isGeometryLoading)
                          const LinearProgressIndicator(),
                        Expanded(
                          child: widget.mapTransportProvider.mapTransportBuilder(
                            context,
                            transitRoute,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                panel: !state.isGeometryLoading &&
                        transitRoute != null &&
                        transitRoute!.stops != null
                    ? BottomStopsDetails(
                        routeOtp: transitRoute!.route!,
                        stops: transitRoute!.stops ?? [],
                        geometry: transitRoute!.geometry!,
                        moveTo: (point) {
                          widget.mapTransportProvider.trufiMapController.move(
                            center: point,
                            zoom: 18,
                          );
                        },
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}
