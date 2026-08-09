import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_transport_list/trufi_core_transport_list.dart';

/// Minimal in-memory provider to exercise the base-class filter logic.
class _FakeProvider extends TransportListDataProvider {
  _FakeProvider(List<TransportRoute> routes) {
    state = TransportListState(routes: routes, filteredRoutes: routes);
  }

  @override
  Future<void> load() async {}

  @override
  Future<void> refresh() async {
    state = state.copyWith(filteredRoutes: state.routes);
  }

  @override
  Future<TransportRouteDetails?> getRouteDetails(String code) async => null;
}

const _routes = [
  TransportRoute(
    id: '1',
    code: 'V1',
    name: 'MiniBus 1',
    shortName: '1',
    longName: 'Verde',
  ),
  TransportRoute(
    id: '2',
    code: 'RA',
    name: 'Ruta A',
    shortName: 'RA',
    longName: 'Ruta América',
  ),
  TransportRoute(
    id: '3',
    code: 'R',
    name: 'Bus R',
    shortName: 'R',
    longName: 'Recoleta',
  ),
  TransportRoute(
    id: '4',
    code: 'TR7',
    name: 'TR-7',
    shortName: 'TR-7',
    longName: 'Circular',
  ),
  TransportRoute(
    id: '5',
    code: 'B2',
    name: 'MiniBus 2',
    shortName: '2',
    longName: 'Parque Central',
  ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('search ranking (#844)', () {
    late _FakeProvider provider;

    setUp(() => provider = _FakeProvider(_routes));

    test('exact short-name match ranks first for a single-letter query', () {
      provider.filter('r');
      final names = provider.state.filteredRoutes
          .map((r) => r.shortName)
          .toList();
      // Bus "R" first (exact), then "RA" (prefix), then "TR-7" (contains
      // in short name), then the ones matching only in other fields —
      // original order preserved within each rank.
      expect(names, ['R', 'RA', 'TR-7', '1', '2']);
    });

    test('exact match wins regardless of case', () {
      provider.filter('ra');
      expect(provider.state.filteredRoutes.first.shortName, 'RA');
    });

    test('non-matching routes stay excluded', () {
      provider.filter('recoleta');
      final names = provider.state.filteredRoutes
          .map((r) => r.shortName)
          .toList();
      expect(names, ['R']);
    });

    test('clearing the query restores the full list in original order', () {
      provider.filter('r');
      provider.filter('');
      expect(provider.state.filteredRoutes.length, _routes.length);
      expect(provider.state.filteredRoutes.first.shortName, '1');
    });

    test('a route without short name still matches via its other fields', () {
      final withNullShort = _FakeProvider([
        ..._routes,
        const TransportRoute(
          id: '6',
          code: 'X',
          name: 'Sin corto',
          longName: 'Ruta Recoleta Norte',
        ),
      ]);
      withNullShort.filter('recoleta');
      final names = withNullShort.state.filteredRoutes
          .map((r) => r.id)
          .toList();
      // Bus "R" (longName Recoleta) and the null-shortName route both
      // match; both rank 3, original order preserved.
      expect(names, ['3', '6']);
    });

    test('a query with an inner space keeps matching like before', () {
      provider.filter('ruta am');
      expect(provider.state.filteredRoutes.map((r) => r.id).toList(), ['2']);
    });

    test('ties keep original order even on large lists (unstable-sort guard)', () {
      // Dart's List.sort is insertion sort (de-facto stable) below ~32
      // elements, so only a large fixture can catch the decoration being
      // removed. All 120 routes match "z" via longName → all rank 3.
      final large = _FakeProvider([
        for (var i = 0; i < 120; i++)
          TransportRoute(
            id: '$i',
            code: 'C$i',
            name: 'Ruta $i',
            shortName: '$i',
            longName: 'Zona $i',
          ),
      ]);
      large.filter('z');
      final ids = large.state.filteredRoutes.map((r) => r.id).toList();
      expect(ids, [for (var i = 0; i < 120; i++) '$i']);
    });
  });
}
