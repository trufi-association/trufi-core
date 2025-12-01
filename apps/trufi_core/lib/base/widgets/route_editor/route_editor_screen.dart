import 'package:flutter/material.dart';
import 'package:trufi_core/base/models/map_provider_collection/trufi_map_definition.dart';
import 'package:trufi_core/base/models/transit_route/transit_route.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/widgets/route_editor/route_editor_section_screen.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';

class RouteEditorScreen extends StatefulWidget {
  static Future<bool?> editRoute(
    BuildContext buildContext, {
    required MapRouteEditorProvider mapRouteEditorProvider,
    required TransitRoute transitRoute,
  }) async {
    return await Navigator.push<bool>(
      buildContext,
      MaterialPageRoute(
        builder: (context) => BaseTrufiPage(
          child: RouteEditorScreen(
            mapRouteEditorProvider: mapRouteEditorProvider,
            transitRoute: transitRoute,
          ),
        ),
      ),
    );
  }

  const RouteEditorScreen({
    super.key,
    required this.mapRouteEditorProvider,
    required this.transitRoute,
  });

  final MapRouteEditorProvider mapRouteEditorProvider;
  final TransitRoute transitRoute;

  @override
  State<RouteEditorScreen> createState() => _RouteEditorScreenState();
}

class _RouteEditorScreenState extends State<RouteEditorScreen>
    with TickerProviderStateMixin {
  List<TrufiLatLng>? currentAreaSelected;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [Text("Editor")]),
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
          TextButton(
            onPressed: () {
              if (currentAreaSelected != null) {
                RouteEditorSectionScreen.editSection(
                  context,
                  mapRouteEditorProvider: widget.mapRouteEditorProvider,
                  areaSelected: currentAreaSelected!,
                );
              }
            },
            child: Text("next"),
          )
        ],
      ),
    );
  }
}
