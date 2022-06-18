import 'dart:typed_data';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trufi_core/base/widgets/base_maps/google_maps/widget_marker/custom_repaint_boundary.dart';

part 'widget_marker.dart';

typedef ValueMarkerChanged = void Function(
  List<Marker> value,
  List<MarkerId> idsRemove,
);

class MarkerGenerator extends StatefulWidget {
  const MarkerGenerator({
    Key? key,
    required this.widgetMarkers,
    required this.onMarkerGenerated,
    this.initPaintDuration = const Duration(milliseconds: 10),
    this.awaitRepaintDuration = const Duration(milliseconds: 20),
    this.secondPaintDuration,
  }) : super(key: key);
  final List<WidgetMarker> widgetMarkers;
  final ValueMarkerChanged onMarkerGenerated;
  final Duration initPaintDuration;
  final Duration? secondPaintDuration;
  final Duration awaitRepaintDuration;

  @override
  _MarkerGeneratorState createState() => _MarkerGeneratorState();
}

class _MarkerGeneratorState extends State<MarkerGenerator> {
  final compareList = const ListEquality().equals;
  List<GlobalKey> globalKeys = [];
  List<WidgetMarker> lastMarkers = [];

  @override
  void initState() {
    super.initState();
    // log("------------------initState------------------\n");
    WidgetsBinding.instance?.addPostFrameCallback(
      (_) async => Future.delayed(
        widget.initPaintDuration,
        () => _onBuildCompleted(),
      ).then((value) {
        if (widget.secondPaintDuration != null) {
          Future.delayed(
            widget.secondPaintDuration!,
            () => _onBuildCompleted(),
          );
        }
      }),
    );
  }

  @override
  void didUpdateWidget(covariant MarkerGenerator oldWidget) {
    super.didUpdateWidget(oldWidget);
    // log("------------------didUpdateWidget------------------\n");
    if (!compareList(oldWidget.widgetMarkers, widget.widgetMarkers)) {
      WidgetsBinding.instance?.addPostFrameCallback(
        (_) => _onBuildCompleted(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // log("------------------build------------------\n");
    globalKeys = [];
    return Transform.translate(
      offset: Offset(
        0,
        -MediaQuery.of(context).size.height,
      ),
      child: Stack(
        children: widget.widgetMarkers.map(
          (widgetMarker) {
            final key = GlobalKey();
            globalKeys.add(key);
            return CustomRepaintBoundary(
              key: key,
              child: widgetMarker.widget,
            );
          },
        ).toList(),
      ),
    );
  }

  Future<void> _onBuildCompleted() async {
    // log("------------------_onBuildCompleted------------------\n");
    final removeMarkers = lastMarkers
        .where((widgetMarker) => !widget.widgetMarkers.contains(widgetMarker))
        .map((widgetMarker) => widgetMarker.markerId)
        .toList();

    lastMarkers = widget.widgetMarkers;
    final markers = <Marker>[];
    for (final key in globalKeys) {
      final marker = await _convertToMarker(key);
      if (marker == null) {
        markers.clear();
        break;
      }
      markers.add(marker);
      removeMarkers.removeWhere((markerId) => marker.markerId == markerId);
    }
    // log("-----------${markers.length}-----------${removeMarkers.length}-----------\n");
    widget.onMarkerGenerated.call(
      markers,
      removeMarkers,
    );
  }

  Future<Marker?> _convertToMarker(GlobalKey key) async {
    // log("------------------_convertToMarker------------------\n");
    if (!globalKeys.contains(key)) return null;
    final CustomRenderRepaintBoundary? boundary =
        key.currentContext?.findRenderObject() as CustomRenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 2.8);
    if (image == null) {
      await Future.delayed(widget.awaitRepaintDuration);
      return _convertToMarker(key);
    }
    final ByteData? byteData =
        await image.toByteData(format: ImageByteFormat.png);
    if (byteData == null) return null;
    final uint8List = byteData.buffer.asUint8List();
    if (!globalKeys.contains(key)) return null;
    final widgetMarker = widget.widgetMarkers[globalKeys.indexOf(key)];
    return widgetMarker.toMarker(
      iconParam: BitmapDescriptor.fromBytes(uint8List),
    );
  }
}
