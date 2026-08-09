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
}
