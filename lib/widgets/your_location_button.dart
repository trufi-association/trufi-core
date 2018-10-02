import 'package:flutter/material.dart';

class YourLocationButton extends StatelessWidget {
  YourLocationButton({
    this.iconData,
    this.onPressed,
  });

  final IconData iconData;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.8,
      child: FloatingActionButton(
        backgroundColor: Colors.grey,
        child: Icon(iconData),
        onPressed: onPressed,
        heroTag: null,
      ),
    );
  }
}
