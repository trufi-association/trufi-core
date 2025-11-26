import 'package:flutter/material.dart';

class TrufiBottomSheet extends StatelessWidget {
  final Widget child;
  final Function(double)? onHeightChanged;
  const TrufiBottomSheet({
    super.key,
    required this.child,
    this.onHeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      bottom: false,
      child: DraggableScrollableSheet(
        initialChildSize: 0.52,
        minChildSize: 0.18,
        maxChildSize: 1.0,
        builder: (context, scrollController) {
          return LayoutBuilder(
            builder: (context, constraints) {
              onHeightChanged?.call(constraints.maxHeight);
              return Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(64),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _SheetGrabber(),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: child,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SheetGrabber extends StatelessWidget {
  const _SheetGrabber();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 5,
        margin: const EdgeInsets.only(top: 8, bottom: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade700,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
