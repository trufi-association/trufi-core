import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

import '../../../composite_subscription.dart';
import '../../../utils/util_icons/custom_icons.dart';

class MyLocationMarker extends StatefulWidget {
  const MyLocationMarker({Key key}) : super(key: key);

  @override
  MyLocationMarkerState createState() => MyLocationMarkerState();
}

class MyLocationMarkerState extends State<MyLocationMarker> {
  final _subscriptions = CompositeSubscription();

  double _direction;

  @override
  void initState() {
    super.initState();
    _subscriptions.add(
      FlutterCompass.events.listen((CompassEvent event) {
        setState(() {
          _direction = event.heading;
        });
      }),
    );
  }

  @override
  void dispose() {
    _subscriptions.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Center(
          child: Transform.scale(
            scale: 0.5,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                border: Border.all(color: Colors.white, width: 3.5),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).accentColor,
                    spreadRadius: 8.0,
                    blurRadius: 30.0,
                  ),
                ],
              ),
              child: Icon(
                CustomIcons.circle,
                color: Theme.of(context).accentColor,
              ),
            ),
          ),
        ),
        if (_direction != null)
          Transform.rotate(
            angle: (pi / 180.0) * _direction,
            child: Container(
              alignment: Alignment.topCenter,
              child: Icon(
                Icons.arrow_drop_up,
                color: Theme.of(context).accentColor,
              ),
            ),
          ),
      ],
    );
  }
}
