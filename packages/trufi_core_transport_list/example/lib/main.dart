import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_transport_list/trufi_core_transport_list.dart';

void main() {
  runApp(const TransportListExampleApp());
}

class TransportListExampleApp extends StatelessWidget {
  static const _defaultCenter = LatLng(-17.3988354, -66.1626903);
  static const _otpEndpoint = 'https://otp-240.trufi-core.trufi.dev';

  const TransportListExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = TransportListTrufiScreen(
      config: TransportListOtpConfig(otpEndpoint: _otpEndpoint),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MapEngineManager(
            engines: defaultMapEngines,
            defaultCenter: _defaultCenter,
          ),
        ),
        ...screen.providers,
      ],
      child: MaterialApp(
        title: 'Transport List Example',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: Builder(builder: screen.builder),
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
