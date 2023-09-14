import 'package:trufi_core/base/models/map_provider_collection/i_trufi_map_controller.dart';
import 'package:trufi_core/base/models/map_provider_collection/trufi_map_definition.dart';
import 'package:trufi_core/base/widgets/base_maps/leaflet_maps/leaflet_map_controller.dart';
import 'package:trufi_core/base/widgets/route_editor/maps/leaflet_map_route_editor.dart';

class LeafletMapRouteEditorProvider implements MapRouteEditorProvider {
  @override
  final ITrufiMapController trufiMapController;
  @override
  final MapRouteEditorBuilder mapRouteEditorBuilder;

  @override
  MapRouteEditorProvider rebuild({bool isSelectionArea = true}) {
    return LeafletMapRouteEditorProvider.create(
      isSelectionArea: isSelectionArea,
    );
  }

  const LeafletMapRouteEditorProvider({
    required this.trufiMapController,
    required this.mapRouteEditorBuilder,
  });

  factory LeafletMapRouteEditorProvider.create({bool isSelectionArea = true}) {
    final trufiMapController = LeafletMapController();
    return LeafletMapRouteEditorProvider(
      trufiMapController: trufiMapController,
      mapRouteEditorBuilder: (mapContext, onAreaSelected) {
        return LeafletMapRouteEditor(
          trufiMapController: trufiMapController,
          onAreaSelected: onAreaSelected,
          isSelectionArea: isSelectionArea,
        );
      },
    );
  }
}
