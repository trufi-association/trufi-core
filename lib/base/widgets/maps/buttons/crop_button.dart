import 'package:flutter/material.dart';

class CropButton extends StatefulWidget {
  const CropButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  final Function onPressed;

  @override
  CropButtonState createState() => CropButtonState();
}

class CropButtonState extends State<CropButton>
    with SingleTickerProviderStateMixin {
  bool _visible = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: FloatingActionButton(
        onPressed: _handleOnPressed,
        heroTag: null,
        child: const Icon(
          Icons.crop_free,
        ),
      ),
    );
  }

  void _handleOnPressed() {
    widget.onPressed();
    setVisible(visible: false);
  }

  bool get isVisible => _visible;

  void setVisible({required bool visible}) {
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
