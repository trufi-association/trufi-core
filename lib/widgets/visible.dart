import 'package:flutter/cupertino.dart';

// Example found in
// https://medium.com/flutter-io/managing-visibility-in-flutter-f558588adefe

enum VisibilityFlag {
  visible,
  invisible,
  offscreen,
  gone,
}

class VisibleWidget extends StatelessWidget {
  final VisibilityFlag visibility;
  final Widget child;
  final Widget removedChild;

  VisibleWidget({
    @required this.child,
    @required this.visibility,
    @required this.removedChild,
  });

  @override
  Widget build(BuildContext context) {
    if (visibility == VisibilityFlag.visible) {
      return child;
    } else if (visibility == VisibilityFlag.invisible) {
      return new IgnorePointer(
        ignoring: true,
        child: new Opacity(
          opacity: 0.0,
          child: child,
        ),
      );
    } else if (visibility == VisibilityFlag.offscreen) {
      return new Offstage(
        offstage: true,
        child: child,
      );
    } else {
      return removedChild;
    }
  }
}
