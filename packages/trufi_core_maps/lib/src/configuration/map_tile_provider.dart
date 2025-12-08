import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_map/flutter_map.dart';

/// Abstract class for providing map tile layers.
///
/// Implement this class to create custom map tile providers.
abstract class MapTileProvider {
  String get id;

  /// The image will be used for show on the Map Type Selector
  WidgetBuilder get imageBuilder;

  /// Build your own custom MapTiles
  List<Widget> buildTileLayerOptions();

  String name(BuildContext context);
}

/// Default OpenStreetMap tile provider.
class OSMDefaultMapTile extends MapTileProvider {
  @override
  List<Widget> buildTileLayerOptions() {
    return [
      TileLayer(
        urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
        tileProvider: DefaultMapTileCaching(),
      ),
    ];
  }

  @override
  String get id => "OSMDefaulMapTile";

  @override
  WidgetBuilder get imageBuilder => (context) => Image.asset(
        "assets/images/OpenMapTiles.png",
        package: "trufi_core",
        fit: BoxFit.cover,
      );

  @override
  String name(BuildContext context) {
    return id;
  }
}

/// OpenStreetMap layer with custom tile URL.
class OSMMapLayer extends MapTileProvider {
  final String? mapTilesUrl;

  OSMMapLayer({
    required this.mapTilesUrl,
  }) : super();

  @override
  List<Widget> buildTileLayerOptions() {
    return [
      TileLayer(
        urlTemplate: mapTilesUrl,
        subdomains: const ['a', 'b', 'c'],
        tileProvider: DefaultMapTileCaching(),
      ),
    ];
  }

  @override
  String get id => "OSMDefaulMapTile";

  @override
  WidgetBuilder get imageBuilder => (context) => Image.asset(
        "assets/images/OpenMapTiles.png",
        fit: BoxFit.cover,
        package: 'trufi_core',
      );

  @override
  String name(BuildContext context) {
    return "Streets";
  }
}

/// Default tile provider with caching support.
class DefaultMapTileCaching extends TileProvider {
  DefaultMapTileCaching();

  @override
  ImageProvider getImage(TileCoordinates coords, TileLayer options) {
    return CachedNetworkImageProvider(getTileUrl(coords, options));
  }
}
