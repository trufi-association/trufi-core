import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

/// A draggable bottom sheet widget with built-in styling and height change notifications.
///
/// This widget wraps [DraggableScrollableSheet] and provides:
/// - Rounded top corners with shadow
/// - A visual drag handle (grabber)
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

  @override
  State<TrufiBottomSheet> createState() => _TrufiBottomSheetState();
}

class _TrufiBottomSheetState extends State<TrufiBottomSheet> {
  double _lastHeight = 0;

  void _onHeightChanged(double height) {
    if ((height - _lastHeight).abs() < 1.0) return; // Ignore tiny changes
    _lastHeight = height;

    // Schedule callback after frame to avoid calling during build
    SchedulerBinding.instance.addPostFrameCallback((_) {
      widget.onHeightChanged?.call(height);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: DraggableScrollableSheet(
        controller: widget.controller,
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
                      const _SheetGrabber(),
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
