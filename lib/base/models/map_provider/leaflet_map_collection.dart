import 'package:trufi_core/base/models/map_provider/trufi_map_definition.dart';
import 'package:trufi_core/base/pages/transport_list/transport_list_detail/maps/map_transport_provider.dart';
import 'package:trufi_core/base/pages/home/widgets/trufi_map_route/maps/map_route_provider.dart';
import 'package:trufi_core/base/widgets/choose_location/maps/map_choose_location_provider.dart';

class LeafletMapCollection implements ITrufiMapProvider {
  @override
  MapChooseLocationProvider mapChooseLocationProvider() {
    return LeafletMapChooseLocationProvider.create();
  }

  @override
  MapRouteProvider mapRouteProvider() {
    return LeafletMapRouteProvider.create();
  }

  @override
  MapTransportProvider mapTransportProvider() {
    return LeafletMapTransportProvider.create();
  }
}
