import 'package:flutter/widgets.dart';

/// Abstract interface for pushing overlays.
///
/// This allows managers to push overlays without depending on the concrete
/// OverlayManager implementation.
abstract class OverlayService {
  /// Push an overlay widget with the given configuration.
  void pushOverlay({
    required Widget child,
    required String id,
    bool dismissible = false,
  });

  /// Remove an overlay by its ID.
  void popOverlayById(String id);

  /// Check if an overlay with the given ID exists.
  bool hasOverlayWithId(String id);
}
