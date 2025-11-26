import 'package:flutter/material.dart';

import 'package:trufi_core/repositories/services/gps_lcoation/gps_location.dart';

class AppLifecycleReactor extends StatefulWidget {
  const AppLifecycleReactor({super.key, required this.child});
  final Widget child;

  @override
  State<AppLifecycleReactor> createState() => _AppLifecycleReactorState();
}

class _AppLifecycleReactorState extends State<AppLifecycleReactor>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback(
      (duration) => GPSLocationProvider().start(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    GPSLocationProvider().dispose();
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
