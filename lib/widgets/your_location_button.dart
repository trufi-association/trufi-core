import 'package:flutter/material.dart';

class YourLocationButton extends StatelessWidget {
  const YourLocationButton({this.onPressed, Key key}): super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).backgroundColor,
      onPressed: onPressed,
      heroTag: null,
      child: const Icon(
        Icons.my_location,
        color: Colors.black,
      ),
    );
  }
}
