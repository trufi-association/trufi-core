import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/base/models/map_provider/trufi_map_definition.dart';

import 'package:trufi_core/base/pages/transport_list/route_transports_cubit/route_transports_cubit.dart';
import 'package:trufi_core/base/pages/transport_list/services/models.dart';
import 'package:trufi_core/base/models/enums/transport_mode.dart';
import 'package:trufi_core/base/pages/transport_list/widgets/bottom_stops_detail.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/widgets/alerts/fetch_error_handler.dart';
import 'package:trufi_core/base/widgets/custom_scrollable_container.dart';

class TransportListDetail extends StatefulWidget {
  final String id;
  final MapTransportProvider mapTransportProvider;

  const TransportListDetail({
    Key? key,
    required this.id,
    required this.mapTransportProvider,
  }) : super(key: key);

  @override
  State<TransportListDetail> createState() => _TransportListDetailState();
}

class _TransportListDetailState extends State<TransportListDetail> {
  PatternOtp? transportData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((duration) async {
      final routeTransportsCubit = context.read<RouteTransportsCubit>();
      transportData = routeTransportsCubit.state.transports.firstWhereOrNull(
        (element) => element.code == widget.id,
      );
      if (!mounted) return;
      try {
        if (transportData == null) {
          await routeTransportsCubit.load();
          transportData =
              routeTransportsCubit.state.transports.firstWhereOrNull(
            (element) => element.code == widget.id,
          );
        }
        if (transportData != null) {
          await routeTransportsCubit.fetchDataPattern(transportData!).then(
            (value) {
              if (mounted) {
                setState(() {
                  transportData = value;
                });
              }
            },
          );
        }
      } catch (e) {
        onFetchError(context, e as Exception);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localization = TrufiBaseLocalization.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (transportData != null)
              Text(transportData!.route!.mode!.getTranslate(localization)),
            if (transportData != null)
              Text(' - ${transportData!.route?.shortName ?? ''}'),
          ],
        ),
      ),
      body: BlocBuilder<RouteTransportsCubit, RouteTransportsState>(
        builder: (context, state) {
          return CustomScrollableContainer(
            openedPosition: 200,
            bottomPadding: 100,
            body: Stack(
              children: [
                Column(
                  children: [
                    if (state.isGeometryLoading)
                      const LinearProgressIndicator(),
                    Expanded(
                      child: widget.mapTransportProvider.mapTransportBuilder(
                        context,
                        transportData,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            panel: !state.isGeometryLoading &&
                    transportData != null &&
                    transportData!.stops != null
                ? BottomStopsDetails(
                    routeOtp: transportData!.route!,
                    stops: transportData!.stops ?? [],
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
    );
  }
}
