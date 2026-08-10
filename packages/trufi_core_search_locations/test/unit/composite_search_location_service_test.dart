import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';

class _FakeService implements SearchLocationService {
  _FakeService(this.results, {this.fails = false, this.delay = Duration.zero});

  final List<SearchLocation> results;
  final bool fails;
  final Duration delay;
  bool disposed = false;
  SearchLocation? reverseResult;

  @override
  Future<List<SearchLocation>> search(String query) async {
    await Future<void>.delayed(delay);
    if (fails) throw SearchLocationException('offline');
    return results;
  }

  @override
  Future<SearchLocation?> reverse(double latitude, double longitude) async {
    await Future<void>.delayed(delay);
    if (fails) throw SearchLocationException('offline');
    return reverseResult;
  }

  @override
  void dispose() => disposed = true;
}

SearchLocation _loc(String id, String name, {double lat = -17.39, double lon = -66.15}) =>
    SearchLocation(id: id, displayName: name, latitude: lat, longitude: lon);

void main() {
  group('CompositeSearchLocationService (#745)', () {
    test('merges results from every service, offline first', () async {
      final offline = _FakeService([_loc('junction:1', 'Ayacucho & Heroínas')]);
      final online = _FakeService([_loc('photon:1', 'Plaza Colón', lat: -17.38)]);

      final results = await CompositeSearchLocationService(
        services: [offline, online],
      ).search('ayacucho');

      expect(results.map((r) => r.displayName), [
        'Ayacucho & Heroínas',
        'Plaza Colón',
      ]);
    });

    test('a failing service does not sink the search', () async {
      // Losing the network is the everyday case: the offline data must
      // still answer instead of the user getting an error.
      final offline = _FakeService([_loc('street:1', 'Avenida Ayacucho')]);
      final online = _FakeService(const [], fails: true);

      final results = await CompositeSearchLocationService(
        services: [offline, online],
      ).search('ayacucho');

      expect(results.single.displayName, 'Avenida Ayacucho');
    });

    test('a slow service is dropped at the timeout', () async {
      final offline = _FakeService([_loc('street:1', 'Avenida Ayacucho')]);
      final online = _FakeService(
        [_loc('photon:1', 'Too late')],
        delay: const Duration(milliseconds: 300),
      );

      final results = await CompositeSearchLocationService(
        services: [offline, online],
        timeout: const Duration(milliseconds: 50),
      ).search('ayacucho');

      expect(results.map((r) => r.displayName), ['Avenida Ayacucho']);
    });

    test('the same place found twice appears once', () async {
      final a = _FakeService([_loc('a', 'Plaza Colón', lat: -17.3900, lon: -66.1500)]);
      final b = _FakeService([_loc('b', 'plaza colón', lat: -17.39000001, lon: -66.15000001)]);

      final results = await CompositeSearchLocationService(
        services: [a, b],
      ).search('plaza');

      expect(results.length, 1);
    });

    test('different places at the same name but far apart both stay', () async {
      final a = _FakeService([_loc('a', 'Mercado', lat: -17.39, lon: -66.15)]);
      final b = _FakeService([_loc('b', 'Mercado', lat: -17.42, lon: -66.20)]);

      final results = await CompositeSearchLocationService(
        services: [a, b],
      ).search('mercado');

      expect(results.length, 2);
    });

    test('reverse uses the first service that answers', () async {
      final offline = _FakeService(const []); // returns null by design
      final online = _FakeService(const [])
        ..reverseResult = _loc('photon:rev', 'Pasaje A');

      final result = await CompositeSearchLocationService(
        services: [offline, online],
      ).reverse(-17.39, -66.15);

      expect(result?.displayName, 'Pasaje A');
    });

    test('disposing disposes every service', () {
      final a = _FakeService(const []);
      final b = _FakeService(const []);
      CompositeSearchLocationService(services: [a, b]).dispose();
      expect(a.disposed && b.disposed, isTrue);
    });
  });
  group('drill-down forwarding (#745)', () {
    final street = _loc('street:s1', 'Avenida Ayacucho');
    final corner = _loc('junction:s1:s2', 'Ayacucho & Heroínas');

    test('delegates to the child that knows the location', () async {
      final offline = _FakeDrillDownService(
        [street],
        corners: {
          'street:s1': [corner],
        },
      );
      final online = _FakeService(const []);
      final composite = CompositeSearchLocationService(
        services: [online, offline], // the capable child is not the first
      );

      expect(composite.canDrillDown(street), isTrue);
      expect(await composite.drillDown(street), [corner]);
      expect(offline.drillDownCalls, 1);
    });

    test('a result no child can expand reports not drillable', () async {
      final offline = _FakeDrillDownService(
        [street],
        corners: {
          'street:s1': [corner],
        },
      );
      final other = _loc('photon:9', 'Plaza Colón');
      final composite = CompositeSearchLocationService(services: [offline]);

      expect(composite.canDrillDown(other), isFalse);
      expect(await composite.drillDown(other), isEmpty);
      expect(offline.drillDownCalls, 0);
    });

    test('plain services are simply skipped', () {
      final composite = CompositeSearchLocationService(
        services: [_FakeService(const [])],
      );
      expect(composite.canDrillDown(street), isFalse);
    });
  });

  group('language forwarding (#945)', () {
    test('forwards the language to every capable child and skips the rest',
        () {
      final aware = _FakeLanguageAwareService();
      final plain = _FakeService(const []);
      final composite = CompositeSearchLocationService(
        services: [plain, aware],
      );

      composite.searchLanguage = 'qu';

      expect(aware.received, 'qu');
    });
  });
}

class _FakeDrillDownService extends _FakeService with SearchLocationDrillDown {
  _FakeDrillDownService(super.results, {required this.corners});

  /// Corners returned for any street id present in this map.
  final Map<String, List<SearchLocation>> corners;
  int drillDownCalls = 0;

  @override
  bool canDrillDown(SearchLocation location) =>
      corners.containsKey(location.id);

  @override
  Future<List<SearchLocation>> drillDown(SearchLocation location) async {
    drillDownCalls++;
    return corners[location.id] ?? const [];
  }
}

class _FakeLanguageAwareService extends _FakeService with LanguageAwareSearch {
  _FakeLanguageAwareService() : super(const []);

  String? received;

  @override
  set searchLanguage(String? languageCode) => received = languageCode;
}
