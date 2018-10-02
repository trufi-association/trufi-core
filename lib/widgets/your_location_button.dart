import 'package:flutter/material.dart';

class YourLocationButton extends StatelessWidget {
  YourLocationButton({this.onPressed});

  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.8,
      child: FloatingActionButton(
        backgroundColor: Colors.grey,
        child: Icon(Icons.my_location),
        onPressed: onPressed,
        heroTag: null,
      ),
    );
  }
}
