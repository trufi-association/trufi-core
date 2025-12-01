import 'package:async_executor/async_executor.dart';
import 'package:flutter/material.dart';

import 'package:trufi_core/base/models/transit_route/transit_route.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/models/map_provider_collection/i_trufi_map_controller.dart';

abstract class ITrufiMapProvider {
  MapChooseLocationProvider mapChooseLocationProvider();
  MapRouteProvider mapRouteProvider({
    Uri? shareBaseItineraryUri,
    WidgetBuilder? overlapWidget,
  });
  MapTransportProvider mapTransportProvider({
    Uri? shareBaseRouteUri,
  });
  MapRouteEditorProvider mapRouteEditorProvider();
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
    super.key,
  });
  ITrufiMapController get trufiMapController;
  Function(TrufiLatLng?) get onCenterChanged;
}

typedef MapChooseLocationBuilder = IMapChooseLocation Function(
  BuildContext context,
  void Function(TrufiLatLng?) onCenterChanged,
);

////////////////////////////////////////////////
// MapRouteEditor interfaces

abstract class MapRouteEditorProvider {
  ITrufiMapController get trufiMapController;
  MapRouteEditorBuilder get mapRouteEditorBuilder;
  MapRouteEditorProvider rebuild({bool isSelectionArea = true});
}

abstract class IMapRouteEditor extends Widget {
  const IMapRouteEditor({
    super.key,
  });
  ITrufiMapController get trufiMapController;
  Function(List<TrufiLatLng>) get onAreaSelected;
  bool get isSelectionArea;
}

typedef MapRouteEditorBuilder = IMapRouteEditor Function(
  BuildContext context,
  void Function(List<TrufiLatLng>) onAreaSelected,
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
  TransitRoute? transportData,
);
