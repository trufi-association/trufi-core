import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_saved_places/trufi_core_saved_places.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SavedPlacesTrufiScreen.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static const _defaultCenter = LatLng(-17.3895, -66.1568);

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = SavedPlacesTrufiScreen(
      config: SavedPlacesConfig(
        onPlaceSelected: (place) {
          debugPrint('Selected: ${place.name}');
        },
      ),
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
