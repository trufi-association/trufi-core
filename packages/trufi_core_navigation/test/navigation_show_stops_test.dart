import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_navigation/l10n/navigation_localizations_en.dart';
import 'package:trufi_core_navigation/l10n/navigation_localizations_es.dart';
import 'package:trufi_core_navigation/trufi_core_navigation.dart';

import 'support/navigation_fixtures.dart';

/// #1059 (trufi-sanaa#18): a feed whose "stops" are OSM way nodes placed
/// along each line makes navigation read "44 stops remaining" and name
/// nodes nobody waits at. `NavigationConfig.showStops: false` keeps those
/// stops driving the progression — it is the state machine — and changes
/// only what the instruction says: the stop where the current leg ends and
/// the distance left to it. The default keeps the instruction as it was.
void main() {
  // The cubit gives haptic feedback on every stop it reaches.
  TestWidgetsFlutterBinding.ensureInitialized();

  final en = NavigationLocalizationsEn();
  final es = NavigationLocalizationsEs();

  // Track positions (see SanaaTrip.track): 0 the origin, 1 halfway to the
  // line, 2 the boarding stop, 2 + i way node i, 47 the alighting stop,
  // 48 halfway to the destination, 49 the destination.
  LatLng atNode(int i) => SanaaTrip.track[2 + i];

  Future<({NavigationCubit cubit, FakeLocationService gps})> start({
    required bool showStops,
    NavigationRoute? route,
    LatLng? at,
  }) async {
    final gps = FakeLocationService(initial: at);
    final cubit = NavigationCubit(
      locationService: gps,
      config: NavigationConfig(showStops: showStops),
    );
    addTearDown(cubit.close);
    await cubit.startNavigation(
      route ?? ItineraryConverter.toNavigationRoute(SanaaTrip.itinerary()),
    );
    expect(cubit.state.status, NavigationStatus.navigating);
    return (cubit: cubit, gps: gps);
  }

  String? primary(NavigationCubit cubit) =>
      cubit.state.currentInstruction?.resolvedPrimaryText(en);
  String? secondary(NavigationCubit cubit) =>
      cubit.state.currentInstruction?.resolvedSecondaryText(en);

  group('NavigationConfig.showStops', () {
    test('is on by default and survives copyWith', () {
      expect(const NavigationConfig().showStops, isTrue);
      expect(
        const NavigationConfig().copyWith(showStops: false).showStops,
        isFalse,
      );
      expect(
        const NavigationConfig(
          showStops: false,
        ).copyWith(keepScreenOn: false).showStops,
        isFalse,
      );
    });
  });

  group('showStops on (default): the instruction names and counts every '
      'stop (unchanged)', () {
    test(
      'before the first fix: the next stop, the count, the preview',
      () async {
        final nav = await start(showStops: true);

        expect(primary(nav.cubit), 'Boarding stop');
        expect(secondary(nav.cubit), '47 stops remaining');
        expect(
          nav.cubit.state.nextInstruction?.resolvedPrimaryText(en),
          'Boarding stop',
        );
      },
    );

    test('riding: a way node by name and how many are left', () async {
      final nav = await start(showStops: true);
      nav.gps.moveTo(atNode(9));

      final instruction = nav.cubit.state.currentInstruction!;
      expect(instruction.type, InstructionType.rideTransport);
      expect(primary(nav.cubit), 'Way node 11');
      expect(secondary(nav.cubit), '36 stops remaining');
      expect(instruction.resolvedSecondaryText(es), 'Quedan 36 paradas');
      expect(instruction.secondaryTextKey, InstructionTextKey.stopsRemaining);
      expect(instruction.remainingStops, 36);
      expect(instruction.distance, isNull);
      expect(
        nav.cubit.state.nextInstruction?.resolvedPrimaryText(en),
        'Way node 11',
      );
    });

    test(
      'the last stop before the destination is counted in the singular',
      () async {
        final nav = await start(showStops: true);
        nav.gps.moveTo(atNode(44));

        expect(primary(nav.cubit), 'University');
        expect(secondary(nav.cubit), '1 stop remaining');
      },
    );
  });

  group('showStops off: the instruction names the stop where the leg ends '
      'and the distance to it', () {
    test('before the first fix: the boarding stop, measured from the '
        'origin', () async {
      final nav = await start(showStops: false);

      final instruction = nav.cubit.state.currentInstruction!;
      expect(primary(nav.cubit), 'Boarding stop');
      expect(secondary(nav.cubit), '150 m');
      expect(
        instruction.distance,
        closeTo(
          nav.gps.metersAlong(SanaaTrip.origin, [SanaaTrip.boarding]),
          0.01,
        ),
      );
      expect(nav.cubit.state.nextInstruction, isNull);
    });

    test('on the walk to the line the distance follows every fix, not '
        'only the stops reached', () async {
      final nav = await start(showStops: false, at: SanaaTrip.origin);
      expect(secondary(nav.cubit), '150 m');

      nav.gps.moveTo(SanaaTrip.track[1]);

      // Still before the boarding stop: no stop was reached in between.
      expect(nav.cubit.state.currentStopIndex, 0);
      expect(primary(nav.cubit), 'Boarding stop');
      expect(secondary(nav.cubit), '75 m');
    });

    test('riding: the alighting stop and the distance along the line, '
        'never a way node nor a count', () async {
      final nav = await start(showStops: false);
      nav.gps.moveTo(atNode(9));

      final instruction = nav.cubit.state.currentInstruction!;
      expect(instruction.type, InstructionType.rideTransport);
      expect(primary(nav.cubit), 'Alighting stop');
      expect(instruction.stopName, 'Alighting stop');
      expect(secondary(nav.cubit), '991 m');
      expect(instruction.secondaryTextKey, InstructionTextKey.distanceToStop);
      expect(instruction.remainingStops, isNull);
      // The English fallback of a consumer without localizations.
      expect(instruction.secondaryText, '991 m');
      expect(nav.cubit.state.nextInstruction, isNull);

      // What is left of the line from where the rider is…
      final alongTheLine = nav.gps.metersAlong(atNode(9), [
        for (var i = 10; i <= SanaaTrip.nodeCount; i++) SanaaTrip.node(i),
        SanaaTrip.alighting,
      ]);
      expect(instruction.distance, closeTo(alongTheLine, 0.01));
      // …which turns a corner: the straight line would fall ~200 m short.
      final straight = nav.gps.metersAlong(atNode(9), [SanaaTrip.alighting]);
      expect(instruction.distance! - straight, greaterThan(200));
    });

    test('from a kilometer on it reads in kilometers, per locale', () async {
      final nav = await start(showStops: false);
      nav.gps.moveTo(SanaaTrip.boarding);

      final instruction = nav.cubit.state.currentInstruction!;
      expect(primary(nav.cubit), 'Alighting stop');
      expect(
        instruction.distance,
        closeTo(nav.gps.metersAlong(SanaaTrip.boarding, SanaaTrip.line), 0.01),
      );
      expect(secondary(nav.cubit), '1.2 km');
      expect(instruction.secondaryText, '1.2 km');
      expect(instruction.resolvedSecondaryText(es), '1,2 km');
      // A widget hands over its context's locale for the number.
      expect(instruction.resolvedSecondaryText(en, locale: 'de'), '1,2 km');
      // A locale intl has no number symbols for still gets a number.
      expect(instruction.resolvedSecondaryText(en, locale: 'qu'), '1.2 km');
    });

    test('once the alighting stop is reached: the destination', () async {
      final nav = await start(showStops: false);
      nav.gps.moveTo(atNode(44));

      expect(primary(nav.cubit), 'University');
      expect(secondary(nav.cubit), '195 m');
      expect(
        nav.cubit.state.currentInstruction!.distance,
        closeTo(nav.gps.metersAlong(atNode(44), [SanaaTrip.destination]), 0.01),
      );
    });

    test('over the whole trip no way node is named, no stop is counted '
        'and nothing is previewed', () async {
      final nav = await start(showStops: false);
      final seen = <String>{};

      for (final fix in SanaaTrip.track) {
        nav.gps.moveTo(fix);
        final state = nav.cubit.state;
        if (state.status != NavigationStatus.navigating) break;

        final instruction = state.currentInstruction!;
        seen.add(instruction.resolvedPrimaryText(en));
        for (final localizations in [en, es]) {
          expect(
            instruction.resolvedSecondaryText(localizations),
            matches(RegExp(r'^\d+([.,]\d)? (m|km)$')),
          );
        }
        expect(instruction.secondaryText, isNot(contains('stop')));
        expect(instruction.remainingStops, isNull);
        expect(state.nextInstruction, isNull);
      }

      expect(seen, {'Boarding stop', 'Alighting stop', 'University'});
      expect(nav.cubit.state.status, NavigationStatus.completed);
      expect(primary(nav.cubit), 'You have arrived');
      expect(nav.cubit.state.nextInstruction, isNull);
    });

    test('a route whose stops are not flagged treats each one as a leg '
        'end', () async {
      const stops = [
        NavigationStop(id: 'a', name: 'First', position: LatLng(15.35, 44.2)),
        NavigationStop(id: 'b', name: 'Second', position: LatLng(15.35, 44.21)),
        NavigationStop(id: 'c', name: 'Third', position: LatLng(15.36, 44.21)),
      ];
      final nav = await start(
        showStops: false,
        route: NavigationRoute(
          id: 'r',
          code: 'R',
          name: 'By hand',
          geometry: [for (final stop in stops) stop.position],
          stops: stops,
        ),
      );

      expect(primary(nav.cubit), 'Second');
      expect(
        nav.cubit.state.currentInstruction!.distance,
        closeTo(
          nav.gps.metersAlong(stops[0].position, [stops[1].position]),
          0.01,
        ),
      );
    });

    test(
      'a list that ends in a passed stop falls back to its last stop',
      () async {
        const stops = [
          NavigationStop(id: 'a', name: 'First', position: LatLng(15.35, 44.2)),
          NavigationStop(
            id: 'b',
            name: 'Passed',
            position: LatLng(15.35, 44.21),
            isIntermediate: true,
          ),
          NavigationStop(
            id: 'c',
            name: 'Also passed',
            position: LatLng(15.36, 44.21),
            isIntermediate: true,
          ),
        ];
        final nav = await start(
          showStops: false,
          route: NavigationRoute(
            id: 'r',
            code: 'R',
            name: 'By hand',
            geometry: [for (final stop in stops) stop.position],
            stops: stops,
          ),
        );

        expect(primary(nav.cubit), 'Also passed');
        expect(
          nav.cubit.state.currentInstruction!.distance,
          closeTo(
            nav.gps.metersAlong(stops[0].position, [
              stops[1].position,
              stops[2].position,
            ]),
            0.01,
          ),
        );
      },
    );
  });

  group('showStops off on a trip with two lines', () {
    NavigationRoute routeOf(TransferTrip trip) =>
        ItineraryConverter.toNavigationRoute(trip.itinerary());

    /// Rides [trip] with a fix every ~9 m and returns the names the rider
    /// read on the instruction, in order, each one once.
    Future<List<String>> namesRead(TransferTrip trip) async {
      final nav = await start(showStops: false, route: routeOf(trip));
      final names = <String>[];

      for (final fix in trip.track) {
        nav.gps.moveTo(fix);
        final state = nav.cubit.state;
        if (state.status != NavigationStatus.navigating) break;

        final instruction = state.currentInstruction!;
        final name = instruction.resolvedPrimaryText(en);
        expect(name, isNot(contains('node')), reason: 'at $fix');
        expect(
          instruction.resolvedSecondaryText(en),
          matches(RegExp(r'^\d+ m$')),
          reason: 'at $fix',
        );
        expect(instruction.remainingStops, isNull);
        expect(state.nextInstruction, isNull);
        if (names.isEmpty || names.last != name) names.add(name);
      }

      expect(nav.cubit.state.status, NavigationStatus.completed);
      return names;
    }

    /// A fix on line 7, [meters] before the stop where it is left.
    LatLng beforeLeavingLine7(FakeLocationService gps, double meters) {
      final first = TransferTrip.nodeA(1);
      final second = TransferTrip.nodeA(2);
      final metersPerDegree =
          gps.metersAlong(first, [second]) /
          (second.longitude - first.longitude);
      return LatLng(
        TransferTrip.alightA.latitude,
        TransferTrip.alightA.longitude - meters / metersPerDegree,
      );
    }

    test('with a walk between them the rider reads where line 7 is left, '
        'where line 12 is boarded, where it is left and the destination, '
        'never a way node', () async {
      expect(await namesRead(TransferTrip(walkAtTransfer: true)), [
        'Board A',
        'Alight A',
        'Board B',
        'Alight B',
        'University',
      ]);
    });

    test('each of those names comes with the distance to that stop', () async {
      final trip = TransferTrip(walkAtTransfer: true);
      final nav = await start(showStops: false, route: routeOf(trip));
      double? distance() => nav.cubit.state.currentInstruction!.distance;

      nav.gps.moveTo(TransferTrip.boardA);
      expect(primary(nav.cubit), 'Alight A');
      expect(secondary(nav.cubit), '295 m');
      expect(
        distance(),
        closeTo(nav.gps.metersAlong(TransferTrip.boardA, trip.lineA), 0.01),
      );

      nav.gps.moveTo(TransferTrip.alightA);
      expect(primary(nav.cubit), 'Board B');
      expect(secondary(nav.cubit), '67 m');
      expect(
        distance(),
        closeTo(nav.gps.metersAlong(TransferTrip.alightA, [trip.boardB]), 0.01),
      );

      nav.gps.moveTo(trip.boardB);
      expect(primary(nav.cubit), 'Alight B');
      expect(secondary(nav.cubit), '306 m');
      expect(
        distance(),
        closeTo(nav.gps.metersAlong(trip.boardB, trip.lineB), 0.01),
      );

      nav.gps.moveTo(trip.alightB);
      expect(primary(nav.cubit), 'University');
      expect(secondary(nav.cubit), '188 m');
      expect(
        distance(),
        closeTo(nav.gps.metersAlong(trip.alightB, [trip.destination]), 0.01),
      );
    });

    test('with a walk between them, from 50 m before the stop where line 7 '
        'is left the instruction already names where line 12 is boarded '
        '(the default mode moves on at the same fix)', () async {
      final trip = TransferTrip(walkAtTransfer: true);
      final nav = await start(showStops: false, route: routeOf(trip));

      nav.gps.moveTo(beforeLeavingLine7(nav.gps, 55));
      expect(primary(nav.cubit), 'Alight A');
      expect(secondary(nav.cubit), '55 m');

      final fix = beforeLeavingLine7(nav.gps, 45);
      nav.gps.moveTo(fix);
      expect(primary(nav.cubit), 'Board B');
      // "Alight A" counts as reached, so it is measured from the rider
      // straight to "Board B".
      expect(secondary(nav.cubit), '81 m');
      expect(
        nav.cubit.state.currentInstruction!.distance,
        closeTo(nav.gps.metersAlong(fix, [trip.boardB]), 0.01),
      );
      expect(nav.cubit.state.currentLeg?.routeName, '7');

      final byDefault = await start(showStops: true, route: routeOf(trip));
      byDefault.gps.moveTo(beforeLeavingLine7(byDefault.gps, 55));
      expect(primary(byDefault.cubit), 'Alight A');
      byDefault.gps.moveTo(beforeLeavingLine7(byDefault.gps, 45));
      expect(primary(byDefault.cubit), 'Board B');
    });

    test('a transfer at one stop, with no walk between the lines: the '
        'rider reads where line 7 is left, where line 12 is left and the '
        'destination, never a way node', () async {
      expect(await namesRead(TransferTrip(walkAtTransfer: false)), [
        'Board A',
        'Alight A',
        'Alight B',
        'University',
      ]);
    });

    test('a transfer at one stop: from 50 m before it the instruction '
        'already names the stop where line 12 is left, under the badge of '
        'line 7 the rider is still on (the default mode names a way node of '
        'line 12 from the same fix, under the same badge)', () async {
      final trip = TransferTrip(walkAtTransfer: false);
      final nav = await start(showStops: false, route: routeOf(trip));

      nav.gps.moveTo(beforeLeavingLine7(nav.gps, 55));
      expect(primary(nav.cubit), 'Alight A');
      expect(secondary(nav.cubit), '55 m');
      expect(nav.cubit.state.currentLeg?.routeName, '7');

      // Within the 50 m of the stop: the progression counts it as reached,
      // so the leg that ends next is line 12's.
      final fix = beforeLeavingLine7(nav.gps, 45);
      nav.gps.moveTo(fix);
      expect(primary(nav.cubit), 'Alight B');
      expect(secondary(nav.cubit), '331 m');
      expect(
        nav.cubit.state.currentInstruction!.distance,
        closeTo(
          nav.gps.metersAlong(fix, [
            for (var i = 1; i <= TransferTrip.nodesPerLine; i++) trip.nodeB(i),
            trip.alightB,
          ]),
          0.01,
        ),
      );
      // The badge follows the leg the rider is nearest to: still line 7.
      expect(nav.cubit.state.currentLeg?.routeName, '7');

      // Past the stop, on line 12, name and badge agree again.
      nav.gps.moveTo(trip.nodeB(3));
      expect(primary(nav.cubit), 'Alight B');
      expect(nav.cubit.state.currentLeg?.routeName, '12');

      final byDefault = await start(showStops: true, route: routeOf(trip));
      byDefault.gps.moveTo(beforeLeavingLine7(byDefault.gps, 55));
      expect(primary(byDefault.cubit), 'Alight A');
      byDefault.gps.moveTo(beforeLeavingLine7(byDefault.gps, 45));
      expect(primary(byDefault.cubit), 'B node 1');
      expect(byDefault.cubit.state.currentLeg?.routeName, '7');
    });
  });

  group('either way', () {
    for (final showStops in [true, false]) {
      test('showStops $showStops: starting at the destination says where '
          'to get off', () async {
        final nav = await start(
          showStops: showStops,
          at: SanaaTrip.destination,
        );

        final instruction = nav.cubit.state.currentInstruction!;
        expect(instruction.type, InstructionType.exitTransport);
        expect(primary(nav.cubit), 'Exit at University');
        expect(secondary(nav.cubit), isNull);
      });

      test('showStops $showStops: arriving says so', () async {
        final nav = await start(showStops: showStops);
        SanaaTrip.track.forEach(nav.gps.moveTo);

        expect(nav.cubit.state.status, NavigationStatus.completed);
        expect(primary(nav.cubit), 'You have arrived');
        expect(secondary(nav.cubit), isNull);
        expect(nav.cubit.state.destinationStop?.name, 'University');
      });
    }
  });

  group('the progression does not depend on showStops', () {
    /// Everything a state says about where the rider is in the trip — all of
    /// it but the two instructions.
    List<Object?> progression(NavigationState state) => [
      state.status,
      state.segmentType,
      state.currentStopIndex,
      state.currentLegIndex,
      state.totalStops,
      state.remainingStops,
      state.progress,
      state.nextStop?.id,
      state.distanceToNextStop,
      state.etaToNextStop,
      state.etaToDestination,
      state.isOffRoute,
      state.distanceFromRoute,
      state.isGpsWeak,
      state.isMapFollowingUser,
      state.currentLocation?.latitude,
      state.currentLocation?.longitude,
    ];

    /// The ridden / ahead split of the line on the map.
    List<Object?> mapLines(NavigationState state) => [
      for (final line in NavigationLayer().buildLayerData(state).lines) ...[
        line.id,
        line.position,
      ],
    ];

    /// Every state a cubit emits over [fixes], the first one before any fix.
    Future<List<NavigationState>> run({
      required bool showStops,
      required List<({LatLng position, double? accuracy})> fixes,
    }) async {
      final gps = FakeLocationService();
      final cubit = NavigationCubit(
        locationService: gps,
        config: NavigationConfig(showStops: showStops),
      );
      final states = <NavigationState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.startNavigation(
        ItineraryConverter.toNavigationRoute(SanaaTrip.itinerary()),
      );
      for (final fix in fixes) {
        gps.moveTo(fix.position, accuracy: fix.accuracy);
      }
      await pumpEventQueue();
      await subscription.cancel();
      await cubit.close();
      return states;
    }

    test('the whole trip: same stop index, count, progress, ETA, distance '
        'to the next stop and map split on every emission', () async {
      final fixes = [
        for (final position in SanaaTrip.track)
          (position: position, accuracy: 8.0),
      ];
      final withStops = await run(showStops: true, fixes: fixes);
      final withoutStops = await run(showStops: false, fixes: fixes);

      expect(withoutStops, hasLength(withStops.length));
      for (var i = 0; i < withStops.length; i++) {
        expect(
          progression(withoutStops[i]),
          progression(withStops[i]),
          reason: 'emission $i',
        );
        expect(
          mapLines(withoutStops[i]),
          mapLines(withStops[i]),
          reason: 'map lines of emission $i',
        );
      }

      // The comparison is not between two cubits that stood still.
      expect(withStops.last.status, NavigationStatus.completed);
      expect(
        withStops.map((state) => state.currentStopIndex).toSet().length,
        greaterThan(40),
      );
      expect(
        withStops.map((state) => state.etaToDestination).toSet().length,
        greaterThan(40),
      );
      expect(
        withStops.any((state) => mapLines(state).contains('leg-1-passed')),
        isTrue,
      );
    });

    test('a jump over several stops, a weak fix and a detour off the '
        'route are handled the same', () async {
      final fixes = <({LatLng position, double? accuracy})>[
        (position: SanaaTrip.origin, accuracy: 8.0),
        // Straight onto the line, eight stops in.
        (position: atNode(8), accuracy: 8.0),
        (position: atNode(12), accuracy: 150.0),
        // 400 m south of the line.
        (position: const LatLng(15.3464, 44.2035), accuracy: 8.0),
        (position: atNode(30), accuracy: 8.0),
      ];
      final withStops = await run(showStops: true, fixes: fixes);
      final withoutStops = await run(showStops: false, fixes: fixes);

      expect(withoutStops, hasLength(withStops.length));
      for (var i = 0; i < withStops.length; i++) {
        expect(
          progression(withoutStops[i]),
          progression(withStops[i]),
          reason: 'emission $i',
        );
      }
      expect(withStops.any((state) => state.isGpsWeak), isTrue);
      expect(withStops.any((state) => state.isOffRoute), isTrue);
      expect(withStops.last.isOffRoute, isFalse);
      expect(withStops.last.currentStopIndex, 32);
    });
  });
}
