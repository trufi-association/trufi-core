import 'package:flutter/material.dart';
import 'package:trufi_core/base/models/map_provider_collection/trufi_map_definition.dart';
import 'package:trufi_core/base/models/transit_route/transit_route.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';

class RouteReportScreen extends StatefulWidget {
  static Future<bool?> reportRoute(
    BuildContext buildContext, {
    required MapRouteEditorProvider mapRouteEditorProvider,
    required TransitRoute transitRoute,
  }) async {
    return await Navigator.push<bool>(
      buildContext,
      MaterialPageRoute(
        builder: (context) => BaseTrufiPage(
          child: RouteReportScreen(
            mapRouteEditorProvider: mapRouteEditorProvider,
            transitRoute: transitRoute,
          ),
        ),
      ),
    );
  }

  const RouteReportScreen({
    super.key,
    required this.mapRouteEditorProvider,
    required this.transitRoute,
  });

  final MapRouteEditorProvider mapRouteEditorProvider;
  final TransitRoute transitRoute;

  @override
  State<RouteReportScreen> createState() => _RouteReportScreenState();
}

class _RouteReportScreenState extends State<RouteReportScreen>
    with TickerProviderStateMixin {
  List<TrufiLatLng>? currentAreaSelected;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TODO translate
        title: Row(children: [Text("Report Route")]),
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.mapRouteEditorProvider.mapRouteEditorBuilder(
              context,
              (data) {
                currentAreaSelected = data;
              },
            ),
          ),
        ],
      ),
    );
  }
}
