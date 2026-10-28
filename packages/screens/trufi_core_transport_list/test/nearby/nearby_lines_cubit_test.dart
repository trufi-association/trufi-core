import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart' show GtfsRouteType;
import 'package:trufi_core_transport_list/trufi_core_transport_list.dart';

NearbyLine row(
  String name,
  double distance, {
  NearbyMatchKind kind = NearbyMatchKind.stop,
}) => NearbyLine(
  lineKey: 'n:$name',
  routeId: name,
  patternId: 0,
  shortName: name,
  longName: 'Line $name',
  routeType: GtfsRouteType.bus,
  distanceMeters: distance,
  kind: kind,
  stopName: kind == NearbyMatchKind.stop ? 'Stop $name' : null,
  nearestPoint: LatLng(distance / 111195, 0),
);

const fakePolyline = [LatLng(0, 0), LatLng(0.001, 0.001), LatLng(0.002, 0)];

class _FakeDataSource implements NearbyLinesDataSource {
  _FakeDataSource({
    this.availability = NearbyAvailability.available,
    this.availabilityAfterLoad,
  });

  @override
  NearbyAvailability availability;

  /// What [ensureLoaded] switches to, when set.
  NearbyAvailability? availabilityAfterLoad;

  List<NearbyLine> rows = [row('201', 80), row('X10', 150), row('18', 380)];

  /// Rows per anchor for the street tests; [rows] for any other anchor.
  Map<LatLng, List<NearbyLine>> rowsByAnchor = const {};
  bool throwOnFind = false;
  final anchors = <LatLng>[];
  int loadCalls = 0;

  @override
  Future<void> ensureLoaded() async {
    loadCalls++;
    final next = availabilityAfterLoad;
    if (next != null) availability = next;
  }

  @override
  NearbyLinesResult findNearby(
    LatLng anchor, {
    double maxRadiusMeters = NearbyRadius.maxMeters,
  }) {
    anchors.add(anchor);
    if (throwOnFind) throw StateError('boom');
    return NearbyLinesResult(
      anchor: anchor,
      maxRadiusMeters: maxRadiusMeters,
      lines: rowsByAnchor[anchor] ?? rows,
    );
  }

  @override
  NearbyLineGeometry? geometryOf(NearbyLine line) =>
      const NearbyLineGeometry(polyline: fakePolyline, stops: []);
}

void main() {
  const defaultAnchor = LatLng(-17.39, -66.15);
  const fix = LatLng(-17.40, -66.16);
  const pin = LatLng(-17.41, -66.17);
  const expectedCounts = {
    NearbyRadius.m100: 1,
    NearbyRadius.m300: 2,
    NearbyRadius.m500: 3,
  };

  var locateCalls = 0;
  setUp(() => locateCalls = 0);

  NearbyLinesCubit cubit(
    _FakeDataSource? source, {
    LatLng? located = fix,
    NearbyRadius initialRadius = NearbyRadius.m300,
  }) => NearbyLinesCubit(
    dataSource: source,
    defaultAnchor: defaultAnchor,
    locate: () async {
      locateCalls++;
      return located;
    },
    initialRadius: initialRadius,
  );

  test('initial state is loading with the configured radius', () {
    final c = cubit(_FakeDataSource(), initialRadius: NearbyRadius.m100);
    expect(c.state.isLoading, isTrue);
    expect(c.state.anchor, isNull);
    expect(c.state.radius, NearbyRadius.m100);
    expect(c.state.availability, NearbyAvailability.available);
    expect(c.state.hasSelection, isFalse);
  });

  test('start() with a fix anchors on the device and queries', () async {
    final source = _FakeDataSource();
    final c = cubit(source);
    await c.start();

    expect(c.state.anchorSource, NearbyAnchorSource.device);
    expect(c.state.anchor, fix);
    expect(c.state.lines, source.rows);
    expect(c.state.counts, expectedCounts);
    expect(c.state.isLoading, isFalse);
    expect(c.state.isLocating, isFalse);
    expect(c.state.locationDenied, isFalse);
    expect(c.state.errorMessage, isNull);
    expect(source.anchors, [fix]);
  });

  test('start() without a fix falls back to the default anchor and still '
      'queries', () async {
    final source = _FakeDataSource();
    final c = cubit(source, located: null);
    await c.start();

    expect(c.state.anchor, defaultAnchor);
    expect(c.state.anchorSource, NearbyAnchorSource.fallback);
    expect(c.state.locationDenied, isTrue);
    expect(c.state.lines, hasLength(3));
    expect(source.anchors, [defaultAnchor]);
  });

  test('setAnchor() pins and re-queries at the pin', () async {
    final source = _FakeDataSource();
    final c = cubit(source);
    await c.start();
    c.setAnchor(pin);

    expect(c.state.anchor, pin);
    expect(c.state.anchorSource, NearbyAnchorSource.pin);
    expect(c.state.locationDenied, isFalse);
    expect(source.anchors, [fix, pin]);
  });

  test('setRadius() only filters: counts unchanged, no extra query', () async {
    final source = _FakeDataSource();
    final c = cubit(source);
    await c.start();
    c.setRadius(NearbyRadius.m100);

    expect(c.state.radius, NearbyRadius.m100);
    expect(c.state.visibleLines.map((l) => l.displayName), ['201']);
    expect(c.state.counts, expectedCounts);
    expect(c.state.lines, hasLength(3));
    expect(source.anchors, hasLength(1));

    c.setRadius(NearbyRadius.m500);
    expect(c.state.visibleLines, hasLength(3));
  });

  test('toggleLine() highlights with the geometry, again clears it', () async {
    final c = cubit(_FakeDataSource());
    await c.start();
    c.toggleLine('n:X10');

    expect(c.state.selectedLineKey, 'n:X10');
    expect(c.state.selectedLine?.displayName, 'X10');
    expect(c.state.selectedGeometry, fakePolyline);

    c.toggleLine('n:X10');
    expect(c.state.hasSelection, isFalse);
    expect(c.state.selectedGeometry, isEmpty);

    c.toggleLine('n:unknown');
    expect(c.state.hasSelection, isFalse);
  });

  test('clearSelection() and selection survives a radius change', () async {
    final c = cubit(_FakeDataSource());
    await c.start();
    c.toggleLine('n:18');
    c.setRadius(NearbyRadius.m100);
    expect(c.state.selectedLineKey, 'n:18');
    expect(c.state.visibleLines, hasLength(1));

    c.clearSelection();
    expect(c.state.hasSelection, isFalse);
  });

  test('a selection is dropped when the line leaves the new result', () async {
    final source = _FakeDataSource();
    final c = cubit(source);
    await c.start();
    c.toggleLine('n:18');
    source.rows = [row('201', 80)];
    c.setAnchor(pin);

    expect(c.state.hasSelection, isFalse);
    expect(c.state.selectedGeometry, isEmpty);
    expect(c.state.lines, hasLength(1));
  });

  test('no data source: missing, default anchor, never throws', () async {
    final c = cubit(null);
    await c.start();

    expect(c.state.availability, NearbyAvailability.missing);
    expect(c.state.anchor, defaultAnchor);
    expect(c.state.isLoading, isFalse);
    expect(c.state.lines, isEmpty);

    c.setAnchor(pin);
    c.toggleLine('n:201');
    await c.useMyLocation();
    await c.refresh();
    expect(c.state.availability, NearbyAvailability.missing);
  });

  test('a loading source becomes available after ensureLoaded()', () async {
    final source = _FakeDataSource(
      availability: NearbyAvailability.loading,
      availabilityAfterLoad: NearbyAvailability.available,
    );
    final c = cubit(source);
    expect(c.state.availability, NearbyAvailability.loading);
    await c.start();

    expect(source.loadCalls, 1);
    expect(c.state.availability, NearbyAvailability.available);
    expect(c.state.lines, hasLength(3));
  });

  test('a source that fails to load ends up missing', () async {
    final source = _FakeDataSource(
      availability: NearbyAvailability.loading,
      availabilityAfterLoad: NearbyAvailability.missing,
    );
    final c = cubit(source);
    await c.start();

    expect(c.state.availability, NearbyAvailability.missing);
    expect(c.state.anchor, defaultAnchor);
    expect(c.state.isLoading, isFalse);
    expect(source.anchors, isEmpty);
  });

  test('a throwing query becomes an error state, not an exception', () async {
    final source = _FakeDataSource()..throwOnFind = true;
    final c = cubit(source);
    await c.start();

    expect(c.state.errorMessage, contains('boom'));
    expect(c.state.lines, isEmpty);
    expect(c.state.counts.values, everyElement(0));
    expect(c.state.isLoading, isFalse);

    source.throwOnFind = false;
    await c.refresh();
    expect(c.state.errorMessage, isNull);
    expect(c.state.lines, hasLength(3));
  });

  test(
    'useMyLocation() after a pin keeps the pin when the fix fails',
    () async {
      LatLng? located = fix;
      final source = _FakeDataSource();
      final c = NearbyLinesCubit(
        dataSource: source,
        defaultAnchor: defaultAnchor,
        locate: () async => located,
      );
      await c.start();
      c.setAnchor(pin);
      located = null;
      await c.useMyLocation();

      expect(c.state.anchor, pin);
      expect(c.state.anchorSource, NearbyAnchorSource.pin);
      expect(c.state.locationDenied, isTrue);
      expect(c.state.isLocating, isFalse);
      expect(source.anchors, [fix, pin, pin]);

      located = fix;
      await c.useMyLocation();
      expect(c.state.anchor, fix);
      expect(c.state.anchorSource, NearbyAnchorSource.device);
      expect(c.state.locationDenied, isFalse);
    },
  );

  test('a stale start() completion is ignored', () async {
    final source = _FakeDataSource();
    var calls = 0;
    final c = NearbyLinesCubit(
      dataSource: source,
      defaultAnchor: defaultAnchor,
      locate: () async {
        calls++;
        // The first visit's fix is slow and lands after a second visit
        // already re-anchored on its own (fast) fix.
        if (calls == 1) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return fix;
        }
        return pin;
      },
    );
    final first = c.start();
    // Let the first visit reach `locate` before the second one starts.
    await Future<void>.delayed(Duration.zero);
    expect(calls, 1);
    final second = c.start();
    await Future.wait([first, second]);
    await Future<void>.delayed(const Duration(milliseconds: 40));

    expect(c.state.anchor, pin);
    expect(c.state.anchorSource, NearbyAnchorSource.device);
    expect(source.anchors, [pin]);
  });

  group('lines along a street (trufi-sanaa#20)', () {
    const c1 = LatLng(-17.3925, -66.1588);
    const c2 = LatLng(-17.3907, -66.1571);
    // The index repeats a corner per crossing street: queried once.
    final street = NearbyStreetAnchor(
      name: 'Avenida Ayacucho',
      subtitle: 'Cercado',
      corners: const [c1, c2, c1],
    );

    _FakeDataSource streetSource() => _FakeDataSource()
      ..rowsByAnchor = {
        c1: [row('201', 80), row('X10', 150)],
        c2: [row('201', 40), row('18', 380)],
      };

    test('startAlongStreet() queries every distinct corner, unions the rows '
        'and does not locate', () async {
      final source = streetSource();
      final c = cubit(source);
      await c.startAlongStreet(street);

      expect(source.anchors, [c1, c2]);
      expect(locateCalls, 0);
      expect(c.state.anchorSource, NearbyAnchorSource.street);
      expect(c.state.street, street);
      expect(c.state.anchor, street.center);
      expect(c.state.lines.map((l) => l.displayName), ['201', 'X10', '18']);
      expect(c.state.lines.first.distanceMeters, 40);
      expect(c.state.counts, expectedCounts);
      expect(c.state.isLoading, isFalse);
      expect(c.state.isLocating, isFalse);
      expect(c.state.locationDenied, isFalse);
      expect(c.state.errorMessage, isNull);
    });

    test('the street replaces a fix or a pin and clears the highlight', () async {
      final source = streetSource();
      final c = cubit(source);
      await c.start();
      c.toggleLine('n:201');
      expect(c.state.hasSelection, isTrue);

      await c.startAlongStreet(street);
      expect(c.state.anchorSource, NearbyAnchorSource.street);
      expect(c.state.hasSelection, isFalse);
      expect(c.state.selectedGeometry, isEmpty);
    });

    test('a long-press leaves the street for a pin', () async {
      final source = streetSource();
      final c = cubit(source);
      await c.startAlongStreet(street);

      c.setAnchor(pin);
      expect(c.state.anchorSource, NearbyAnchorSource.pin);
      expect(c.state.street, isNull);
      expect(c.state.anchor, pin);
      expect(source.anchors.last, pin);
      expect(c.state.lines, source.rows);
    });

    test('useMyLocation() leaves the street for the fix', () async {
      final source = streetSource();
      final c = cubit(source);
      await c.startAlongStreet(street);

      await c.useMyLocation();
      expect(locateCalls, 1);
      expect(c.state.anchorSource, NearbyAnchorSource.device);
      expect(c.state.street, isNull);
      expect(c.state.anchor, fix);
    });

    test('a failed fix keeps the street, as it keeps a pin', () async {
      final source = streetSource();
      final c = cubit(source, located: null);
      await c.startAlongStreet(street);

      await c.useMyLocation();
      expect(c.state.anchorSource, NearbyAnchorSource.street);
      expect(c.state.street, street);
      expect(c.state.locationDenied, isTrue);
      expect(c.state.lines.map((l) => l.displayName), ['201', 'X10', '18']);
    });

    test('refresh() re-runs the union; start() (a drawer visit) relocates '
        'and drops the street', () async {
      final source = streetSource();
      final c = cubit(source);
      await c.startAlongStreet(street);
      source.anchors.clear();

      await c.refresh();
      expect(source.anchors, [c1, c2]);
      expect(c.state.street, street);

      await c.start();
      expect(locateCalls, 1);
      expect(c.state.anchorSource, NearbyAnchorSource.device);
      expect(c.state.street, isNull);
    });

    test('without a source the street is reported unavailable', () async {
      final c = cubit(null);
      await c.startAlongStreet(street);

      expect(c.state.availability, NearbyAvailability.missing);
      expect(c.state.anchorSource, NearbyAnchorSource.street);
      expect(c.state.street, street);
      expect(c.state.anchor, street.center);
      expect(c.state.isLoading, isFalse);
    });

    test('a street without corners queries nothing and lists nothing', () async {
      final source = streetSource();
      final c = cubit(source);
      await c.startAlongStreet(
        NearbyStreetAnchor(name: 'Sin esquinas', corners: const []),
      );

      expect(source.anchors, isEmpty);
      expect(c.state.lines, isEmpty);
      expect(c.state.anchor, defaultAnchor);
      expect(c.state.isLoading, isFalse);
    });
  });
}
