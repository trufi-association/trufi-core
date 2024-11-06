import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:routemaster/routemaster.dart';
import 'package:trufi_core/base/pages/home/home.dart';

class SplashScreen extends StatefulWidget {
  static const String route = "/SplashScreen";

  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      Routemaster.of(context).replace(
        HomePage.route,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Lottie.asset(
        'assets/splash_screen.json',
        package: 'trufi_core',
        fit: BoxFit.fitWidth,
      ),
    );
  }
}