import 'package:flutter/material.dart';

enum _VerticalSwipeDirection { none, down, up }

class VerticalSwipeDetector extends StatefulWidget {
  VerticalSwipeDetector({
    @required this.child,
    this.onSwipeDown,
    this.onSwipeUp,
  });

  final Widget child;
  final Function onSwipeDown;
  final Function onSwipeUp;

  @override
  VerticalSwipeDetectorState createState() => VerticalSwipeDetectorState();
}

class VerticalSwipeDetectorState extends State<VerticalSwipeDetector> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: (gestureDetails) {
        beginSwipe(gestureDetails);
      },
      onVerticalDragUpdate: (gestureDetails) {
        getDirection(gestureDetails);
      },
      onVerticalDragEnd: (gestureDetails) {
        endSwipe(gestureDetails);
      },
      child: widget.child,
    );
  }

  double _start = 0.0;
  _VerticalSwipeDirection _direction = _VerticalSwipeDirection.none;

  void beginSwipe(DragStartDetails gestureDetails) {
    _start = gestureDetails.globalPosition.dy;
  }

  void getDirection(DragUpdateDetails gestureDetails) {
    _direction = gestureDetails.globalPosition.dy < _start
        ? _VerticalSwipeDirection.up
        : _VerticalSwipeDirection.down;
  }

  void endSwipe(DragEndDetails gestureDetails) {
    if (_direction == _VerticalSwipeDirection.down) {
      if (widget.onSwipeDown != null) widget.onSwipeDown();
    } else if (_direction == _VerticalSwipeDirection.up) {
      if (widget.onSwipeUp != null) widget.onSwipeUp();
    }
  }
}
