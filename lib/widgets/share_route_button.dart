import 'package:flutter/material.dart';

class ShareRouteButton extends StatelessWidget {
  ShareRouteButton({this.onPressed});

  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).backgroundColor,
      child: Icon(
        Icons.mobile_screen_share,
        color: Colors.black,
      ),
      onPressed: onPressed,
      heroTag: null,
    );
  }
}
