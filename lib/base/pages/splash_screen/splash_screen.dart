import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:trufi_core/base/blocs/providers/city_selection_manager.dart';
import 'package:trufi_core/base/pages/home/home.dart';

class SplashScreen extends StatefulWidget {
  static const String route = "/SplashScreen";

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? splashAssetPath;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Routemaster.of(context).replace(HomePage.route);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final splashScreenAsset =
          (await CitySelectionManager().getCityInstance)?.getSplashScreenAsset;

      if (mounted) {
        setState(() {
          splashAssetPath = splashScreenAsset ??
              'assets/images/splash-screens/splash-screen-default.png';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: splashAssetPath == null
          ? const SizedBox.shrink()
          : SizedBox.expand(
              child: Image.asset(
                splashAssetPath!,
                fit: BoxFit.fill,
              ),
            ),
    );
  }
}
