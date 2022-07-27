import 'package:trufi_core/base/models/map_provider/trufi_map_definition.dart';
import 'package:trufi_core/base/pages/transport_list/transport_list_detail/maps/leaflet_map_transport.dart';
import 'package:trufi_core/base/models/map_provider/i_trufi_map_controller.dart';
import 'package:trufi_core/base/widgets/base_maps/leaflet_maps/leaflet_map_controller.dart';

class LeafletMapTransportProvider implements MapTransportProvider {
  @override
  final ITrufiMapController trufiMapController;
  @override
  final MapTransportBuilder mapTransportBuilder;

  const LeafletMapTransportProvider({
    required this.trufiMapController,
    required this.mapTransportBuilder,
  });

  factory LeafletMapTransportProvider.create() {
    final trufiMapController = LeafletMapController();
    return LeafletMapTransportProvider(
      trufiMapController: trufiMapController,
      mapTransportBuilder: (mapContext, transportData) {
        return LeafletMapTransport(
          trufiMapController: trufiMapController,
          transportData: transportData,
        );
      },
    );
  }
}
