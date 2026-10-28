import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core/base/models/transit_route/transit_info.dart';
import 'package:trufi_core/base/models/transit_route/transit_route.dart';
import 'package:trufi_core/base/providers/transit_route/repository/local_repository.dart';
import 'package:trufi_core/base/providers/transit_route/route_transports_cubit/route_transports_cubit.dart';
import 'package:trufi_core/base/providers/transit_route/services/route_transports_service.dart';

class _FakeLocal implements RouteTransportsLocalRepository {
  List<TransitRoute> stored;
  int saves = 0;
  _FakeLocal(this.stored);

  @override
  Future<void> loadRepository() async {}

  @override
  Future<List<TransitRoute>> getTransports() async => List.of(stored);

  @override
  Future<void> saveTransports(List<TransitRoute> data) async {
    stored = List.of(data);
    saves++;
  }
}

class _FakeRemote implements RouteTransportsRemoteRepository {
  final Future<List<TransitRoute>> Function() onFetch;
  int calls = 0;
  _FakeRemote(this.onFetch);

  @override
  Future<List<TransitRoute>> fetchPatterns() {
    calls++;
    return onFetch();
  }

  @override
  Future<TransitRoute> fetchDataPattern(String idStop) =>
      throw UnimplementedError();
}

TransitRoute _route(String code) =>
    TransitRoute(id: code, name: code, code: code);

TransitRoute _namedRoute(String code, {String? longName, String? agency}) =>
    TransitRoute(
      id: code,
      name: code,
      code: code,
      route: TransitInfo(
        shortName: code,
        longName: longName,
        agency: agency == null ? null : Agency(name: agency),
      ),
    );

Iterable<String> _codes(Iterable<TransitRoute> routes) =>
    routes.map((r) => r.code);

/// Lets the constructor's load() run to completion.
Future<void> _settle() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  test(
      'a cached list is shown at once and replaced by the feed fetched in the '
      'background (trufi-arequipa#74)', () async {
    final local = _FakeLocal([_route('old-2024')]);
    final remote = _FakeRemote(() async => [_route('new-a'), _route('new-b')]);
    final states = <RouteTransportsState>[];
    final cubit = RouteTransportsCubit(
      'http://unused',
      localRepository: local,
      routeTransportsRepository: remote,
    );
    cubit.stream.listen(states.add);
    await _settle();

    expect(remote.calls, 1, reason: 'the feed is requested on start');
    expect(
        _codes(states.first.transports),
        [
          'old-2024',
        ],
        reason: 'the cached list is emitted first');
    expect(
      states.any((s) => s.isLoading),
      isFalse,
      reason: 'the background fetch shows no loading overlay',
    );
    expect(_codes(cubit.state.transports), unorderedEquals(['new-a', 'new-b']));
    expect(
      _codes(cubit.state.filterTransports),
      unorderedEquals(['new-a', 'new-b']),
    );
    expect(
      _codes(local.stored),
      unorderedEquals(['new-a', 'new-b']),
      reason: 'the cache is updated',
    );
    await cubit.close();
  });

  test('offline the cached list stays and nothing is thrown', () async {
    final local = _FakeLocal([_route('old-2024')]);
    final remote = _FakeRemote(() async => throw Exception('Error connection'));
    final states = <RouteTransportsState>[];
    final cubit = RouteTransportsCubit(
      'http://unused',
      localRepository: local,
      routeTransportsRepository: remote,
    );
    cubit.stream.listen(states.add);
    await _settle();

    expect(remote.calls, 1);
    expect(_codes(cubit.state.transports), ['old-2024']);
    expect(cubit.state.isLoading, isFalse);
    expect(states.any((s) => s.isLoading), isFalse);
    expect(local.saves, 0, reason: 'a failed fetch never overwrites the cache');
    await cubit.close();
  });

  test(
    'without a cache the first fetch still shows the loading overlay',
    () async {
      final local = _FakeLocal([]);
      final remote = _FakeRemote(() async => [_route('new-a')]);
      final states = <RouteTransportsState>[];
      final cubit = RouteTransportsCubit(
        'http://unused',
        localRepository: local,
        routeTransportsRepository: remote,
      );
      cubit.stream.listen(states.add);
      await _settle();

      expect(states.any((s) => s.isLoading), isTrue);
      expect(cubit.state.isLoading, isFalse);
      expect(_codes(cubit.state.transports), ['new-a']);
      expect(local.saves, 1);
      await cubit.close();
    },
  );

  test(
    'a background refresh that fails completes quietly and keeps the list',
    () async {
      final local = _FakeLocal([_route('old-2024')]);
      var fail = false;
      final remote = _FakeRemote(() async {
        if (fail) throw Exception('Error connection');
        return [_route('old-2024')];
      });
      final cubit = RouteTransportsCubit(
        'http://unused',
        localRepository: local,
        routeTransportsRepository: remote,
      );
      await _settle();
      fail = true;
      await expectLater(cubit.refresh(silent: true), completes);
      expect(cubit.state.isLoading, isFalse);
      expect(_codes(cubit.state.transports), ['old-2024']);
      expect(local.saves, 0);
      await cubit.close();
    },
  );

  test(
    'a feed equal to the list shown emits nothing and writes nothing',
    () async {
      final local = _FakeLocal([_route('a'), _route('b')]);
      final remote = _FakeRemote(() async => [_route('a'), _route('b')]);
      final states = <RouteTransportsState>[];
      final cubit = RouteTransportsCubit(
        'http://unused',
        localRepository: local,
        routeTransportsRepository: remote,
      );
      cubit.stream.listen(states.add);
      await _settle();

      expect(remote.calls, 1);
      expect(states.length, 1, reason: 'only the cached list was emitted');
      expect(local.saves, 0, reason: 'no Hive frame for an unchanged list');
      await cubit.refresh(silent: true);
      expect(local.saves, 0);
      await cubit.close();
    },
  );

  test(
      'a refresh asked while the background one is in flight shares the '
      'request', () async {
    final local = _FakeLocal([_route('old-2024')]);
    final gate = Completer<List<TransitRoute>>();
    final remote = _FakeRemote(() => gate.future);
    final cubit = RouteTransportsCubit(
      'http://unused',
      localRepository: local,
      routeTransportsRepository: remote,
    );
    await _settle();
    expect(remote.calls, 1, reason: 'the background fetch is in flight');
    final explicit = cubit.refresh();
    await _settle();
    expect(remote.calls, 1, reason: 'the explicit refresh joins it');
    expect(cubit.state.isLoading, isTrue);
    gate.complete([_route('new-a')]);
    await explicit;
    expect(cubit.state.isLoading, isFalse);
    expect(_codes(cubit.state.transports), ['new-a']);
    expect(local.saves, 1, reason: 'one write for one answer');
    await cubit.close();
  });

  test('the filter typed meanwhile survives the background refresh', () async {
    final local = _FakeLocal([_route('old-2024')]);
    final gate = Completer<List<TransitRoute>>();
    final remote = _FakeRemote(() => gate.future);
    final cubit = RouteTransportsCubit(
      'http://unused',
      localRepository: local,
      routeTransportsRepository: remote,
    );
    await _settle();
    cubit.filterTransports('new-a');
    expect(cubit.state.filterTransports, isEmpty);
    gate.complete([_route('new-a'), _route('new-b')]);
    await _settle();
    expect(_codes(cubit.state.transports), ['new-a', 'new-b']);
    expect(
      _codes(cubit.state.filterTransports),
      ['new-a'],
      reason: 'the fresh list is shown through the active filter',
    );
    await cubit.close();
  });

  test('an explicit refresh still surfaces the error to the caller', () async {
    final local = _FakeLocal([_route('old-2024')]);
    var fail = false;
    final remote = _FakeRemote(() async {
      if (fail) throw Exception('Error connection');
      return [_route('new-a')];
    });
    final cubit = RouteTransportsCubit(
      'http://unused',
      localRepository: local,
      routeTransportsRepository: remote,
    );
    await _settle();
    fail = true;
    await expectLater(cubit.refresh(), throwsException);
    expect(cubit.state.isLoading, isFalse);
    expect(_codes(cubit.state.transports), ['new-a']);
    await cubit.close();
  });

  group('filterTransports (trufi-core#1039)', () {
    late RouteTransportsCubit cubit;
    setUp(() async {
      final routes = [
        _namedRoute('C9',
            longName: 'El Golf → Feria Altiplano', agency: 'Emarsistran'),
        _namedRoute('4D', longName: 'Cayma → Enace', agency: 'Albotran'),
        _namedRoute('AJ', agency: 'Transportes Arequipa'),
      ];
      cubit = RouteTransportsCubit(
        'http://unused',
        localRepository: _FakeLocal(routes),
        routeTransportsRepository: _FakeRemote(() async => routes),
      );
      await _settle();
    });
    tearDown(() => cubit.close());

    test('matches the code regardless of case', () {
      cubit.filterTransports('c9');
      expect(_codes(cubit.state.filterTransports), ['C9']);
      cubit.filterTransports('C9');
      expect(_codes(cubit.state.filterTransports), ['C9']);
    });

    test('matches the operator name', () {
      cubit.filterTransports('EMARSISTRAN');
      expect(_codes(cubit.state.filterTransports), ['C9']);
      cubit.filterTransports('arequipa');
      expect(_codes(cubit.state.filterTransports), ['AJ']);
    });

    test('matches the long name and trims the query', () {
      cubit.filterTransports('  altiplano ');
      expect(_codes(cubit.state.filterTransports), ['C9']);
    });

    test('an empty or blank query shows everything', () {
      cubit.filterTransports('zzz');
      expect(cubit.state.filterTransports, isEmpty);
      cubit.filterTransports('   ');
      // the background refresh re-sorts the list by operator, hence unordered
      expect(
        _codes(cubit.state.filterTransports),
        unorderedEquals(['C9', '4D', 'AJ']),
      );
    });
  });
}
