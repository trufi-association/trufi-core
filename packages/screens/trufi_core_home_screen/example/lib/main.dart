import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HomeScreenTrufiScreen.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static const _defaultCenter = LatLng(-17.3988354, -66.1626903);
  static const _otpEndpoint = 'https://otp-240.trufi-core.trufi.dev';

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = HomeScreenTrufiScreen(
      config: HomeScreenConfig(otpEndpoint: _otpEndpoint),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MapEngineManager(
            engines: defaultMapEngines,
            defaultCenter: _defaultCenter,
          ),
        ),
        BlocProvider(
          create: (_) => SearchLocationsCubit(
            searchLocationService: PhotonSearchService(
              biasLatitude: _defaultCenter.latitude,
              biasLongitude: _defaultCenter.longitude,
            ),
          ),
        ),
        ...screen.providers,
      ],
      child: MaterialApp(
        title: 'Home Screen Example',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: Scaffold(body: Builder(builder: screen.builder)),
        localizationsDelegates: [
          ...screen.localizationsDelegates,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: screen.supportedLocales,
      ),
    );
  }
}
