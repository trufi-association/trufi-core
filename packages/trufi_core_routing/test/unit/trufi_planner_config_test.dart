import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

void main() {
  group('TrufiPlannerConfig transfer knobs', () {
    test(
      'local mode defaults match the planner (100 m, 3 routes per name)',
      () {
        const config = TrufiPlannerConfig.local(gtfsAsset: 'assets/gtfs.zip');
        expect(config.isLocal, isTrue);
        expect(config.transferRadiusMeters, 100);
        expect(config.sameNameRouteLimit, 3);
      },
    );

    test('local mode exposes both knobs', () {
      const config = TrufiPlannerConfig.local(
        gtfsAsset: 'assets/gtfs.zip',
        transferRadiusMeters: 0,
        sameNameRouteLimit: 1 << 30,
      );
      expect(config.transferRadiusMeters, 0);
      expect(config.sameNameRouteLimit, 1 << 30);
    });

    test('remote mode leaves them to the server (fixed defaults)', () {
      const config = TrufiPlannerConfig.remote(serverUrl: 'https://p.example');
      expect(config.isRemote, isTrue);
      expect(config.transferRadiusMeters, 100);
      expect(config.sameNameRouteLimit, 3);
    });
  });

  group('TrufiPlannerConfig persisted index (#993)', () {
    test('local mode persists by default and can opt out', () {
      const on = TrufiPlannerConfig.local(gtfsAsset: 'assets/gtfs.zip');
      expect(on.persistIndex, isTrue);
      const off = TrufiPlannerConfig.local(
        gtfsAsset: 'assets/gtfs.zip',
        persistIndex: false,
      );
      expect(off.persistIndex, isFalse);
    });

    test('remote mode has nothing to persist', () {
      const config = TrufiPlannerConfig.remote(serverUrl: 'https://p.example');
      expect(config.persistIndex, isFalse);
    });
  });
}
