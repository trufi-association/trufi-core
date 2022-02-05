import 'package:flutter/material.dart';

import 'package:trufi_core/base/blocs/providers/gps_location_provider.dart';

class AppLifecycleReactor extends StatefulWidget {
  const AppLifecycleReactor({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  _AppLifecycleReactorState createState() => _AppLifecycleReactorState();
}

class _AppLifecycleReactorState extends State<AppLifecycleReactor>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);

    WidgetsBinding.instance?.addPostFrameCallback(
      (duration) => GPSLocationProvider().start(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    GPSLocationProvider().close();
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    final locationProvider = GPSLocationProvider();
    if (state == AppLifecycleState.resumed) {
      locationProvider.start();
    } else {
      locationProvider.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
