import 'package:flutter/material.dart';

class YourLocationButton extends StatelessWidget {
  YourLocationButton({this.onPressed});

  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      child: Icon(
        Icons.my_location,
        color: Colors.black,
      ),
      onPressed: onPressed,
      heroTag: null,
    );
  }
}
