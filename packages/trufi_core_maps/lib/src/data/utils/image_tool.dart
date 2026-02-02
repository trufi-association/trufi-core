import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../domain/entities/marker.dart';

/// Utility for converting widgets and SVGs to PNG images.
///
/// Used by MapLibre to convert Flutter widgets to images for markers.
/// Note: Caching is handled at the MapLibre level via `_loadedImages`,
/// not here. This class just does the conversion.
abstract class ImageTool {
  static Future<Uint8List> svgToPng(String svgString) async {
    final pictureInfo = await vg.loadPicture(SvgStringLoader(svgString), null);
    final ui.Image image = await pictureInfo.picture.toImage(100, 100);
    final ByteData? data = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return data!.buffer.asUint8List();
  }

  /// Converts a marker's widget to PNG bytes.
  ///
  /// Note: This method does NOT cache. Caching is handled by MapLibre
  /// internally via `_loadedImages` in maplibre_map.dart.
  static Future<Uint8List> widgetToBytes(
    TrufiMarker marker,
    BuildContext context,
  ) async {
    final mediaQuery = MediaQuery.of(context);
    return ImageTool.widgetToPng(
      marker.widget,
      devicePixelRatio: mediaQuery.devicePixelRatio,
      size: marker.size,
    );
  }

  static Future<Uint8List> widgetToPng(
    Widget widget, {
    double devicePixelRatio = 1.0,
    required Size size,
  }) async {
    final repaintBoundary = RenderRepaintBoundary();

    final renderView = RenderView(
      view: WidgetsBinding.instance.platformDispatcher.views.first,
      configuration: ViewConfiguration(
        logicalConstraints: BoxConstraints.tight(size),
        devicePixelRatio: devicePixelRatio,
      ),
      child: RenderPositionedBox(
        alignment: Alignment.center,
        child: repaintBoundary,
      ),
    );

    final pipelineOwner = PipelineOwner();
    final buildOwner = BuildOwner(focusManager: FocusManager());

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final renderWidget = Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: MediaQueryData(size: size, devicePixelRatio: devicePixelRatio),
        child: Center(
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: widget,
          ),
        ),
      ),
    );

    final renderElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: renderWidget,
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(renderElement);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final image = await repaintBoundary.toImage(pixelRatio: devicePixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }
}
