import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CustomRepaintBoundary extends SingleChildRenderObjectWidget {
  const CustomRepaintBoundary({
    Key? key,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  CustomRenderRepaintBoundary createRenderObject(BuildContext context) =>
      CustomRenderRepaintBoundary();
}

class CustomRenderRepaintBoundary extends RenderProxyBox {
  CustomRenderRepaintBoundary({RenderBox? child}) : super(child);

  @override
  bool get isRepaintBoundary => true;

  Future<ui.Image?> toImage({double pixelRatio = 1.0}) async {
    try {
      assert(!debugNeedsPaint);
      final OffsetLayer offsetLayer = layer! as OffsetLayer;
      return offsetLayer.toImage(Offset.zero & size, pixelRatio: pixelRatio);
    } catch (e) {
      return null;
    }
  }

  /// The number of times that this render object repainted at the same time as
  /// its parent. Repaint boundaries are only useful when the parent and child
  /// paint at different times. When both paint at the same time, the repaint
  /// boundary is redundant, and may be actually making performance worse.
  ///
  /// Only valid when asserts are enabled. In release builds, always returns
  /// zero.
  ///
  /// Can be reset using [debugResetMetrics]. See [debugAsymmetricPaintCount]
  /// for the corresponding count of times where only the parent or only the
  /// child painted.
  int get debugSymmetricPaintCount => _debugSymmetricPaintCount;
  int _debugSymmetricPaintCount = 0;

  /// The number of times that either this render object repainted without the
  /// parent being painted, or the parent repainted without this object being
  /// painted. When a repaint boundary is used at a seam in the render tree
  /// where the parent tends to repaint at entirely different times than the
  /// child, it can improve performance by reducing the number of paint
  /// operations that have to be recorded each frame.
  ///
  /// Only valid when asserts are enabled. In release builds, always returns
  /// zero.
  ///
  /// Can be reset using [debugResetMetrics]. See [debugSymmetricPaintCount] for
  /// the corresponding count of times where both the parent and the child
  /// painted together.
  int get debugAsymmetricPaintCount => _debugAsymmetricPaintCount;
  int _debugAsymmetricPaintCount = 0;

  /// Resets the [debugSymmetricPaintCount] and [debugAsymmetricPaintCount]
  /// counts to zero.
  ///
  /// Only valid when asserts are enabled. Does nothing in release builds.
  void debugResetMetrics() {
    assert(() {
      _debugSymmetricPaintCount = 0;
      _debugAsymmetricPaintCount = 0;
      return true;
    }());
  }

  @override
  void debugRegisterRepaintBoundaryPaint(
      {bool includedParent = true, bool includedChild = false}) {
    assert(() {
      if (includedParent && includedChild) {
        _debugSymmetricPaintCount += 1;
      } else {
        _debugAsymmetricPaintCount += 1;
      }
      return true;
    }());
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    bool inReleaseMode = true;
    assert(() {
      inReleaseMode = false;
      if (debugSymmetricPaintCount + debugAsymmetricPaintCount == 0) {
        properties.add(MessageProperty(
            'usefulness ratio', 'no metrics collected yet (never painted)'));
      } else {
        final double fraction = debugAsymmetricPaintCount /
            (debugSymmetricPaintCount + debugAsymmetricPaintCount);
        final String diagnosis;
        if (debugSymmetricPaintCount + debugAsymmetricPaintCount < 5) {
          diagnosis =
              'insufficient data to draw conclusion (less than five repaints)';
        } else if (fraction > 0.9) {
          diagnosis =
              'this is an outstandingly useful repaint boundary and should definitely be kept';
        } else if (fraction > 0.5) {
          diagnosis = 'this is a useful repaint boundary and should be kept';
        } else if (fraction > 0.30) {
          diagnosis =
              'this repaint boundary is probably useful, but maybe it would be more useful in tandem with adding more repaint boundaries elsewhere';
        } else if (fraction > 0.1) {
          diagnosis =
              'this repaint boundary does sometimes show value, though currently not that often';
        } else if (debugAsymmetricPaintCount == 0) {
          diagnosis =
              'this repaint boundary is astoundingly ineffectual and should be removed';
        } else {
          diagnosis =
              'this repaint boundary is not very effective and should probably be removed';
        }
        properties.add(PercentProperty('metrics', fraction,
            unit: 'useful',
            tooltip:
                '$debugSymmetricPaintCount bad vs $debugAsymmetricPaintCount good'));
        properties.add(MessageProperty('diagnosis', diagnosis));
      }
      return true;
    }());
    if (inReleaseMode) {
      properties.add(DiagnosticsNode.message(
          '(run in debug mode to collect repaint boundary statistics)'));
    }
  }
}
