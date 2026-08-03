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
    // Mirrors real providers: refresh resets filteredRoutes to all routes.
    state = state.copyWith(filteredRoutes: state.routes);
  }

  @override
  Future<TransportRouteDetails?> getRouteDetails(String code) async => null;
}

const _routes = [
  TransportRoute(
    id: '1',
    code: 'A1',
    name: 'Linea A',
    shortName: 'A',
    agencyName: 'Trufi Express',
  ),
  TransportRoute(
    id: '2',
    code: 'B2',
    name: 'Linea B',
    shortName: 'B',
    agencyName: 'Micros Unidos',
  ),
  TransportRoute(
    id: '3',
    code: 'C3',
    name: 'Linea C',
    shortName: 'C',
    agencyName: 'Trufi Express',
  ),
  TransportRoute(id: '4', code: 'D4', name: 'Linea D', shortName: 'D'),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TransportListDataProvider.setAgencyFilter', () {
    test('keeps only routes of the given operator (issue #924)', () {
      final provider = _FakeProvider(_routes);

      provider.setAgencyFilter('Trufi Express');

      expect(provider.state.agencyFilter, 'Trufi Express');
      expect(provider.state.filteredRoutes.map((r) => r.id), ['1', '3']);
    });

    test('matches case-insensitively and trims', () {
      final provider = _FakeProvider(_routes);

      provider.setAgencyFilter('  trufi express ');

      expect(provider.state.filteredRoutes.map((r) => r.id), ['1', '3']);
    });

    test('unknown operator yields an empty list, not all routes', () {
      final provider = _FakeProvider(_routes);

      provider.setAgencyFilter('No Existe');

      expect(provider.state.filteredRoutes, isEmpty);
    });

    test('null or empty clears the restriction', () {
      final provider = _FakeProvider(_routes);
      provider.setAgencyFilter('Trufi Express');

      provider.setAgencyFilter(null);
      expect(provider.state.agencyFilter, isNull);
      expect(provider.state.filteredRoutes.length, _routes.length);

      provider.setAgencyFilter('Micros Unidos');
      provider.setAgencyFilter('');
      expect(provider.state.agencyFilter, isNull);
      expect(provider.state.filteredRoutes.length, _routes.length);
    });

    test('text query intersects with the agency restriction', () {
      final provider = _FakeProvider(_routes);

      provider.setAgencyFilter('Trufi Express');
      provider.filter('c');

      expect(provider.state.filteredRoutes.map((r) => r.id), ['3']);

      // Clearing the text keeps the agency scope.
      provider.filter('');
      expect(provider.state.filteredRoutes.map((r) => r.id), ['1', '3']);
    });

    test('reapplyFilters restores scoping after a refresh reset', () async {
      final provider = _FakeProvider(_routes);
      provider.setAgencyFilter('Micros Unidos');

      await provider.refresh();
      expect(provider.state.filteredRoutes.length, _routes.length);

      provider.reapplyFilters();
      expect(provider.state.filteredRoutes.map((r) => r.id), ['2']);
    });
  });
}
