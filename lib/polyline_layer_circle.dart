import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/src/map/map.dart';
import 'package:latlong/latlong.dart';

class PolylineCircleLayerOptions extends PolylineLayerOptions {
  final List<Polyline> polylines;
  PolylineCircleLayerOptions({this.polylines = const []});
}

class PolylineCircle extends Polyline {
  final List<LatLng> points;
  final List<Offset> offsets = [];
  final double strokeWidth;
  final Color color;
  PolylineCircle({
    this.points,
    this.strokeWidth = 1.0,
    this.color = const Color(0xFF00FF00),
  });
}

class PolylineCircleLayer extends StatelessWidget {
  final PolylineLayerOptions polylineOpts;
  final MapState map;
  PolylineCircleLayer(this.polylineOpts, this.map);

  Widget build(BuildContext context) {
    return new LayoutBuilder(
      builder: (BuildContext context, BoxConstraints bc) {
        final size = new Size(bc.maxWidth, bc.maxHeight);
        return _build(context, size);
      },
    );
  }

  Widget _build(BuildContext context, Size size) {
    return new StreamBuilder<int>(
      stream: map.onMoved, // a Stream<int> or null
      builder: (BuildContext context, _) {
        for (var polylineOpt in polylineOpts.polylines) {
          polylineOpt.offsets.clear();
          var i = 0;
          for (var point in polylineOpt.points) {
            var pos = map.project(point);
            pos = pos.multiplyBy(map.getZoomScale(map.zoom, map.zoom)) - map.getPixelOrigin();
            polylineOpt.offsets.add(new Offset(pos.x.toDouble(), pos.y.toDouble()));
            if (i > 0 && i < polylineOpt.points.length) {
              polylineOpt.offsets.add(new Offset(pos.x.toDouble(), pos.y.toDouble()));
            }
            i++;
          }
        }

        var polylines = <Widget>[];
        for (var polylineOpt in this.polylineOpts.polylines) {
          polylines.add(
            new CustomPaint(
              painter: new PolylinePainter(polylineOpt),
              size: size,
            ),
          );
        }

        return new Container(
          child: new Stack(
            children: polylines,
          ),
        );
      },
    );
  }
}

class PolylinePainter extends CustomPainter {
  final Polyline polylineOpt;
  PolylinePainter(this.polylineOpt);

  @override
  void paint(Canvas canvas, Size size) {
    if (polylineOpt.offsets.isEmpty) {
      return;
    }
    final rect = Offset.zero & size;
    canvas.clipRect(rect);
    final paint = new Paint()
      ..color = polylineOpt.color
      ..strokeWidth = polylineOpt.strokeWidth;
    for (var offset in polylineOpt.offsets) {
      canvas.drawCircle(offset, 6.0, paint);
    }
  }

  @override
  bool shouldRepaint(PolylinePainter other) => false;
}
