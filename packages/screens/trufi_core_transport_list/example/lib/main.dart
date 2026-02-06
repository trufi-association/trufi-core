import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart'
    show RoutingEngineManager, IRoutingProvider, Otp28RoutingProvider;
import 'package:trufi_core_transport_list/trufi_core_transport_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static const _defaultCenter = LatLng(-17.3988354, -66.1626903);

  // Routing engines
  static final List<IRoutingProvider> _routingEngines = [
    const Otp28RoutingProvider(
      endpoint: 'https://otp.trufi.app',
    ),
  ];

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = TransportListTrufiScreen();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MapEngineManager(
            engines: defaultMapEngines,
            defaultCenter: _defaultCenter,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => RoutingEngineManager(
            engines: _routingEngines,
          ),
        ),
        ...screen.providers,
      ],
      child: MaterialApp(
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
