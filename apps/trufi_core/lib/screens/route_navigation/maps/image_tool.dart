import 'dart:typed_data';
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/widgets.dart';
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';

abstract class ImageTool {
  static Future<Uint8List> svgToPng(String svgString) async {
    final pictureInfo = await vg.loadPicture(SvgStringLoader(svgString), null);
    final ui.Image image = await pictureInfo.picture.toImage(100, 100);
    final ByteData? data = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return data!.buffer.asUint8List();
  }

  static Future<Uint8List> widgetToBytes(
    TrufiMarker marker,
    BuildContext context,
  ) {
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
      configuration: ViewConfiguration.fromView(
        WidgetsBinding.instance.platformDispatcher.views.first,
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
