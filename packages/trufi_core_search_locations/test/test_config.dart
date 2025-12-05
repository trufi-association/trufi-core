import 'package:trufi_core_search_locations/src/models/search_location.dart';

/// Test configuration for search location tests.
class TestConfig {
  TestConfig._();

  /// Photon API endpoint (komoot.io - free, open-source)
  static const photonEndpoint = 'https://photon.komoot.io';

  /// Nominatim API endpoint (OpenStreetMap official)
  static const nominatimEndpoint = 'https://nominatim.openstreetmap.org';

  /// User agent for Nominatim (required by usage policy)
  static const nominatimUserAgent = 'TrufiCoreSearchLocations/1.0 (test)';

  /// Test location: Berlin, Germany
  static const berlinLocation = SearchLocation(
    id: 'relation_62422',
    displayName: 'Berlin',
    address: 'Berlin, Germany',
    latitude: 52.5200066,
    longitude: 13.404954,
  );

  /// Test location: Brandenburg Gate, Berlin
  static const brandenburgGateLocation = SearchLocation(
    id: 'way_26995159',
    displayName: 'Brandenburger Tor',
    address: 'Pariser Platz, Mitte, Berlin, Germany',
    latitude: 52.5162746,
    longitude: 13.3777041,
  );

  /// Test location: Cochabamba, Bolivia (for South America tests)
  static const cochabambaLocation = SearchLocation(
    id: 'relation_2757969',
    displayName: 'Cochabamba',
    address: 'Cochabamba, Cercado, Bolivia',
    latitude: -17.3988354,
    longitude: -66.1626903,
  );

  /// Center of Berlin for bias testing
  static const berlinCenterLat = 52.52;
  static const berlinCenterLon = 13.405;

  /// Center of Cochabamba for bias testing
  static const cochabambaCenterLat = -17.3988354;
  static const cochabambaCenterLon = -66.1626903;

  /// Bounding box for Berlin area [minLon, minLat, maxLon, maxLat]
  static const berlinBoundingBox = [13.0, 52.3, 13.8, 52.7];

  /// Bounding box for Bolivia
  static const boliviaBoundingBox = [-69.6, -22.9, -57.5, -9.7];
}
