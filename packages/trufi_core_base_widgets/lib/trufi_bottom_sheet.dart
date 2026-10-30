import 'package:flutter/gestures.dart' show kMinFlingVelocity;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

/// A draggable bottom sheet widget with built-in styling and height change notifications.
///
/// This widget wraps [DraggableScrollableSheet] and provides:
/// - Rounded top corners with shadow
/// - A visual drag handle (grabber) that resizes the sheet
/// - An optional pinned [header] below the grabber
/// - Height change callback for integrating with map camera adjustments
///
/// Use [builder] when your content needs to manage its own scrolling (e.g., ListView).
/// Use [child] for simple content that will be wrapped in a SingleChildScrollView.
class TrufiBottomSheet extends StatefulWidget {
  /// Builder that provides the scroll controller for content that manages its own scrolling.
  /// Use this for ListView, GridView, or other scrollable content.
  final Widget Function(
    BuildContext context,
    ScrollController scrollController,
  )?
  builder;

  /// Simple content to display inside the bottom sheet.
  /// Will be wrapped in a SingleChildScrollView automatically.
  /// Use [builder] instead if your content already handles scrolling.
  final Widget? child;

  /// Content pinned between the grabber and the scrolling area: it never
  /// scrolls away with [child]/[builder], and dragging it resizes the sheet
  /// just like dragging the grabber (#1055).
  final Widget? header;

  /// Callback triggered when the sheet height changes.
  /// Useful for adjusting map padding dynamically.
  final void Function(double height)? onHeightChanged;

  /// Initial size as a fraction of parent height (0.0 to 1.0).
  final double initialChildSize;

  /// Minimum size as a fraction of parent height (0.0 to 1.0).
  final double minChildSize;

  /// Maximum size as a fraction of parent height (0.0 to 1.0).
  final double maxChildSize;

  /// Whether the sheet should snap to [snapSizes].
  final bool snap;

  /// Sizes to snap to when [snap] is true.
  final List<double>? snapSizes;

  /// Optional controller for programmatic control of the sheet.
  final DraggableScrollableController? controller;

  const TrufiBottomSheet({
    super.key,
    this.builder,
    this.child,
    this.header,
    this.onHeightChanged,
    this.initialChildSize = 0.52,
    this.minChildSize = 0.18,
    this.maxChildSize = 1.0,
    this.snap = false,
    this.snapSizes,
    this.controller,
  }) : assert(
         builder != null || child != null,
         'Either builder or child must be provided',
       );

  /// Where a handle drag released at [size] (a fraction of the parent) with
  /// [velocity] (logical pixels per second, positive = the sheet growing)
  /// settles, given the sorted [snapSizes]. Flutter's own rule for the
  /// sheet's content (`_SnappingSimulation`): a fling picks the next snap in
  /// its direction, a plain release (below [kMinFlingVelocity]) the nearest.
  @visibleForTesting
  static double snapTargetFor(
    double size,
    double velocity,
    List<double> snapSizes,
  ) {
    final nextIndex = snapSizes.indexWhere((s) => s >= size);
    if (nextIndex == -1) return snapSizes.last;
    if (nextIndex == 0) return snapSizes.first;
    final next = snapSizes[nextIndex];
    if (next == size) return size;
    final previous = snapSizes[nextIndex - 1];
    if (velocity.abs() < kMinFlingVelocity) {
      return size - previous < next - size ? previous : next;
    }
    return velocity < 0 ? previous : next;
  }

  @override
  State<TrufiBottomSheet> createState() => _TrufiBottomSheetState();
}

class _TrufiBottomSheetState extends State<TrufiBottomSheet> {
  double _lastHeight = 0;

  /// Created only when the host passes no controller: the handle drag needs
  /// one to move the sheet.
  DraggableScrollableController? _ownController;

  DraggableScrollableController get _controller =>
      widget.controller ?? (_ownController ??= DraggableScrollableController());

  @override
  void dispose() {
    _ownController?.dispose();
    super.dispose();
  }

  void _onHeightChanged(double height) {
    if ((height - _lastHeight).abs() < 1.0) return; // Ignore tiny changes
    _lastHeight = height;

    // Schedule callback after frame to avoid calling during build
    SchedulerBinding.instance.addPostFrameCallback((_) {
      widget.onHeightChanged?.call(height);
    });
  }

  /// The grabber and the header sit outside the sheet's scrollable, and a
  /// [DraggableScrollableSheet] only resizes through that scrollable's
  /// position — so a drag on them drives the controller by hand.
  void _onHandleDragUpdate(DragUpdateDetails details) {
    final controller = _controller;
    if (!controller.isAttached) return;
    final parentHeight = controller.sizeToPixels(1.0);
    if (parentHeight <= 0) return;
    final size = (controller.size - details.primaryDelta! / parentHeight).clamp(
      widget.minChildSize,
      widget.maxChildSize,
    );
    controller.jumpTo(size);
  }

  void _onHandleDragEnd(DragEndDetails details) {
    final controller = _controller;
    if (!controller.isAttached || !widget.snap) return;
    final sizes = <double>{
      widget.minChildSize,
      ...?widget.snapSizes,
      widget.maxChildSize,
    }.toList()..sort();
    // The finger's velocity is along the screen's y axis (down = positive);
    // the sheet grows when the finger moves up.
    final target = TrufiBottomSheet.snapTargetFor(
      controller.size,
      -(details.primaryVelocity ?? 0),
      sizes,
    );
    if (target == controller.size) return;
    controller.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: DraggableScrollableSheet(
        controller: _controller,
        initialChildSize: widget.initialChildSize,
        minChildSize: widget.minChildSize,
        maxChildSize: widget.maxChildSize,
        snap: widget.snap,
        snapSizes: widget.snapSizes,
        builder: (context, scrollController) {
          return LayoutBuilder(
            builder: (context, constraints) {
              _onHeightChanged(constraints.maxHeight);
              // PointerInterceptor prevents platform views (maps) from
              // capturing touch events meant for this sheet on web
              return PointerInterceptor(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(40),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onVerticalDragUpdate: _onHandleDragUpdate,
                        onVerticalDragEnd: _onHandleDragEnd,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const _SheetGrabber(),
                            if (widget.header != null) widget.header!,
                          ],
                        ),
                      ),
                      Expanded(
                        child: widget.builder != null
                            ? widget.builder!(context, scrollController)
                            : SingleChildScrollView(
                                controller: scrollController,
                                child: widget.child,
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Visual drag handle indicator for the bottom sheet.
class _SheetGrabber extends StatelessWidget {
  const _SheetGrabber();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
