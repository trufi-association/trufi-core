import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const _defaultCenter = LatLng(-17.3920, -66.1575);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapEngineManager(
        engines: defaultMapEngines,
        defaultCenter: _defaultCenter,
      ),
      child: MaterialApp(
        title: 'Search Locations Example',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SearchLocationState _locationState = const SearchLocationState();

  final List<SearchLocation> _myPlaces = [
    const SearchLocation(
      id: 'home',
      displayName: 'Home',
      address: 'Av. Los Pinos 123',
      latitude: -17.3926,
      longitude: -66.1588,
    ),
    const SearchLocation(
      id: 'work',
      displayName: 'Work',
      address: 'Zona Central, Edificio Torre',
      latitude: -17.3940,
      longitude: -66.1570,
    ),
  ];

  final SearchLocationService _searchService = PhotonSearchService(
    baseUrl: 'https://photon.komoot.io',
    biasLatitude: -17.3920,
    biasLongitude: -66.1575,
    limit: 15,
  );

  @override
  void dispose() {
    _searchService.dispose();
    super.dispose();
  }

  Future<SearchLocation?> _showSearchScreen({required bool isOrigin}) async {
    return Navigator.push<SearchLocation>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationSearchScreen(
          isOrigin: isOrigin,
          myPlaces: _myPlaces,
          searchService: _searchService,
          onYourLocation: () async => const SearchLocation(
            id: 'current',
            displayName: 'Your Location',
            latitude: -17.3900,
            longitude: -66.1560,
          ),
          onChooseOnMap: () async {
            // ChooseOnMapScreen uses MapEngineManager.defaultCenter by default
            final result = await Navigator.push<MapLocationResult>(
              context,
              MaterialPageRoute(
                builder: (context) => const ChooseOnMapScreen(),
              ),
            );

            if (result != null) {
              return SearchLocation(
                id: 'map_${DateTime.now().millisecondsSinceEpoch}',
                displayName: 'Selected Location',
                address:
                    '${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)}',
                latitude: result.latitude,
                longitude: result.longitude,
              );
            }
            return null;
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: SearchLocationBar(
              state: _locationState,
              configuration: const SearchLocationBarConfiguration(
                originHintText: 'Where from?',
                destinationHintText: 'Where to?',
              ),
              onSearch: _showSearchScreen,
              onOriginSelected: (location) => setState(() {
                _locationState = _locationState.copyWith(origin: location);
              }),
              onDestinationSelected: (location) => setState(() {
                _locationState = _locationState.copyWith(destination: location);
              }),
              onSwap: () => setState(() {
                _locationState = _locationState.swapped();
              }),
              onReset: () => setState(() {
                _locationState = const SearchLocationState.empty();
              }),
              onMenuPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: const Center(
                child: Text('Map Area'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
