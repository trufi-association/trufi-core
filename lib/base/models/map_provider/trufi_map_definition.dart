import 'package:async_executor/async_executor.dart';
import 'package:flutter/material.dart';

import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/models/map_provider/i_trufi_map_controller.dart';
import 'package:trufi_core/base/pages/transport_list/services/models.dart';

abstract class ITrufiMapProvider {
  MapChooseLocationProvider mapChooseLocationProvider();
  MapRouteProvider mapRouteProvider({
    Uri? shareBaseItineraryUri,
    WidgetBuilder? overlapWidget,
  });
  MapTransportProvider mapTransportProvider({
    Uri? shareBaseRouteUri,
  });
}

////////////////////////////////////////////////
// MapChooseLocation interfaces

abstract class MapChooseLocationProvider {
  ITrufiMapController get trufiMapController;
  MapChooseLocationBuilder get mapChooseLocationBuilder;
  MapChooseLocationProvider rebuild();
}

abstract class IMapChooseLocation extends Widget {
  const IMapChooseLocation({
    Key? key,
  }) : super(key: key);
  ITrufiMapController get trufiMapController;
  Function(TrufiLatLng?) get onCenterChanged;
}

typedef MapChooseLocationBuilder = IMapChooseLocation Function(
  BuildContext context,
  void Function(TrufiLatLng?) onCenterChanged,
);

////////////////////////////////////////////////
// MapRoute interfaces
abstract class MapRouteProvider {
  ITrufiMapController get trufiMapController;
  MapRouteBuilder get mapRouteBuilder;
}

typedef MapRouteBuilder = Widget Function(
  BuildContext,
  AsyncExecutor asyncExecutor,
);
////////////////////////////////////////////////
// MapTransport interfaces

abstract class MapTransportProvider {
  ITrufiMapController get trufiMapController;
  MapTransportBuilder get mapTransportBuilder;
  Uri? get shareBaseRouteUri;
  MapTransportProvider rebuild();
}

typedef MapTransportBuilder = Widget Function(
  BuildContext,
  PatternOtp? transportData,
);
