import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_transport_list/trufi_core_transport_list.dart';

/// Provider whose initial [load] fails until [failLoad] is cleared,
/// mirroring a network/asset error on first fetch.
class _FailingProvider extends TransportListDataProvider {
  bool failLoad = true;

  static const _routes = [
    TransportRoute(
      id: '1',
      code: 'A1',
      name: 'Linea A',
      shortName: 'A',
      agencyName: 'Trufi Express',
    ),
  ];

  @override
  Future<void> load() async {
    if (failLoad) {
      state = state.copyWith(isLoading: false);
      throw Exception('network down');
    }
    state = state.copyWith(
      routes: _routes,
      filteredRoutes: _routes,
      isLoading: false,
    );
  }

  @override
  Future<void> refresh() => load();

  @override
  Future<TransportRouteDetails?> getRouteDetails(String code) async => null;
}

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: TransportListLocalizations.localizationsDelegates,
    supportedLocales: TransportListLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('failed load shows error state with retry instead of crashing '
      'or spinning forever', (tester) async {
    final provider = _FailingProvider();

    await tester.pumpWidget(
      _wrap(TransportListContent(dataProvider: provider, onRouteTap: (_) {})),
    );
    // Let the post-frame load() run and fail.
    await tester.pumpAndSettle();

    expect(find.text('Could not load routes'), findsWidgets);
    expect(find.text('Retry'), findsOneWidget);

    // Retry with the backend recovered: the list should appear.
    provider.failLoad = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Could not load routes'), findsNothing);
    expect(find.text('Linea A'), findsOneWidget);
  });

  testWidgets('failed refresh keeps the loaded list and just reports',
      (tester) async {
    final provider = _FailingProvider()..failLoad = false;

    await tester.pumpWidget(
      _wrap(TransportListContent(dataProvider: provider, onRouteTap: (_) {})),
    );
    await tester.pumpAndSettle();
    expect(find.text('Linea A'), findsOneWidget);

    provider.failLoad = true;
    await tester.fling(find.text('Linea A'), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    // List stays visible; a SnackBar reports the failure.
    expect(find.text('Linea A'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
