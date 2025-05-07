import 'package:flutter/material.dart';
import 'package:trufi_core/base/models/map_provider_collection/trufi_map_definition.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';

class RouteEditorSectionScreen extends StatefulWidget {
  static Future<bool?> editSection(
    BuildContext buildContext, {
    required MapRouteEditorProvider mapRouteEditorProvider,
    required List<TrufiLatLng> areaSelected,
  }) async {
    return await Navigator.push<bool>(
      buildContext,
      MaterialPageRoute(
        builder: (context) => BaseTrufiPage(
          child: RouteEditorSectionScreen(
            mapRouteEditorProvider: mapRouteEditorProvider.rebuild(
              isSelectionArea: false,
            ),
            areaSelected: areaSelected,
          ),
        ),
      ),
    );
  }

  const RouteEditorSectionScreen({
    super.key,
    required this.mapRouteEditorProvider,
    required this.areaSelected,
  });

  final MapRouteEditorProvider mapRouteEditorProvider;
  final List<TrufiLatLng> areaSelected;

  @override
  State<RouteEditorSectionScreen> createState() =>
      _RouteEditorSectionScreenState();
}

class _RouteEditorSectionScreenState extends State<RouteEditorSectionScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    widget.mapRouteEditorProvider.trufiMapController.onReady.then((_) async {
      await Future.delayed(Duration(milliseconds: 100));
      widget.mapRouteEditorProvider.trufiMapController
          .moveBounds(points: widget.areaSelected, tickerProvider: this);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [Text("Editor Section")]),
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.mapRouteEditorProvider.mapRouteEditorBuilder(
              context,
              (data) {},
            ),
          ),
        ],
      ),
    );
  }
}
