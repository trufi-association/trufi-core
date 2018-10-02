import 'package:flutter/material.dart';

class CropButton extends StatefulWidget {
  CropButton({
    Key key,
    @required this.iconData,
    @required this.onPressed,
  }) : super(key: key);

  final IconData iconData;
  final Function onPressed;

  @override
  CropButtonState createState() => CropButtonState();
}

class CropButtonState extends State<CropButton>
    with SingleTickerProviderStateMixin {
  bool _visible = false;

  AnimationController _animationController;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _animation = Tween(begin: 0.0, end: 0.8).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: FloatingActionButton(
        backgroundColor: Colors.grey,
        child: Icon(widget.iconData),
        onPressed: _handleOnPressed,
        heroTag: null,
      ),
    );
  }

  void _handleOnPressed() {
    widget.onPressed();
    setVisible(false);
  }

  bool get isVisible => _visible;

  void setVisible(bool visible) {
    if (_visible != visible) {
      setState(() {
        _visible = visible;
        if (visible) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      });
    }
  }
}
