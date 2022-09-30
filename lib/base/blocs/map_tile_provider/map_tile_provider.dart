import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_map/flutter_map.dart';

abstract class MapTileProvider {
  String get id;

  /// The image will be used for show on the Map Type Selector
  WidgetBuilder get imageBuilder;

  /// Build your own custom MapTiles
  List<Widget> buildTileLayerOptions();

  String name(BuildContext context);
}

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
      );

  @override
  String name(BuildContext context) {
    return id;
  }
}

class DefaultMapTileCaching extends TileProvider {
  DefaultMapTileCaching();

  @override
  ImageProvider getImage(Coords coords, TileLayer options) {
    return CachedNetworkImageProvider(getTileUrl(coords, options));
  }
}
