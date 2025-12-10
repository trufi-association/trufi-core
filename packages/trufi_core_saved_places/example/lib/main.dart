import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_saved_places/trufi_core_saved_places.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('saved_places');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapEngineManager(engines: defaultMapEngines),
      child: MaterialApp(
        title: 'Saved Places Example',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const SavedPlacesExample(),
        localizationsDelegates: SavedPlacesLocalizations.localizationsDelegates,
        supportedLocales: SavedPlacesLocalizations.supportedLocales,
      ),
    );
  }
}

class SavedPlacesExample extends StatelessWidget {
  const SavedPlacesExample({super.key});

  Future<({double latitude, double longitude})?> _openMapPicker(
    BuildContext context, {
    double? initialLatitude,
    double? initialLongitude,
  }) async {
    final result = await Navigator.of(context).push<MapLocationResult>(
      MaterialPageRoute(
        builder: (context) => ChooseOnMapScreen(
          configuration: ChooseOnMapConfiguration(
            title: 'Choose Location',
            initialLatitude: initialLatitude ?? -17.3895,
            initialLongitude: initialLongitude ?? -66.1568,
            initialZoom: 15,
            confirmButtonText: 'Use this location',
          ),
        ),
      ),
    );

    if (result == null) return null;
    return (latitude: result.latitude, longitude: result.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return SavedPlacesScreen(
      repository: HiveSavedPlacesRepository(),
      onPlaceSelected: (place) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected: ${place.name}')),
        );
      },
      onChooseOnMap: ({initialLatitude, initialLongitude}) => _openMapPicker(
        context,
        initialLatitude: initialLatitude,
        initialLongitude: initialLongitude,
      ),
      defaultLatitude: -17.3895,
      defaultLongitude: -66.1568,
    );
  }
}
