import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;
import 'package:trufi_core_saved_places/trufi_core_saved_places.dart';

// #1005: the bookmark on route results. It only exists when the app has a
// saved routes screen (a SavedRoutesCubit in scope), proposes
// "origin → destination" as the name, stores the itinerary snapshot and
// reports through a snackbar; once saved it shows a solid bookmark.

const _from = TrufiLocation(
  description: 'Plaza',
  latitude: -17.39,
  longitude: -66.16,
);
const _to = TrufiLocation(
  description: 'Terminal',
  latitude: -17.37,
  longitude: -66.15,
);

routing.Itinerary _itinerary() {
  final bus = routing.Leg(
    mode: 'BUS',
    startTime: DateTime(2026, 10, 13, 8),
    endTime: DateTime(2026, 10, 13, 8, 30),
    duration: const Duration(minutes: 30),
    distance: 5000,
    transitLeg: true,
    route: routing.Route(gtfsId: '1:123', shortName: '123', color: '7E57C2'),
    shortName: '123',
  );
  return routing.Itinerary(
    legs: [bus],
    startTime: DateTime(2026, 10, 13, 8),
    endTime: DateTime(2026, 10, 13, 8, 30),
    walkTime: Duration.zero,
    duration: const Duration(minutes: 30),
    walkDistance: 0,
  );
}

/// Test double: keeps routes in memory, no platform channels.
class _InMemorySavedRoutesRepository implements SavedRoutesRepository {
  final List<SavedRoute> _routes = [];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<List<SavedRoute>> getAllRoutes() async => List.of(_routes);

  @override
  Future<void> saveRoute(SavedRoute route) async => _routes.add(route);

  @override
  Future<void> updateRoute(SavedRoute route) async {
    final index = _routes.indexWhere((r) => r.id == route.id);
    if (index != -1) _routes[index] = route;
  }

  @override
  Future<void> deleteRoute(String id) async =>
      _routes.removeWhere((r) => r.id == id);
}

void main() {
  late SavedRoutesCubit cubit;

  setUp(() async {
    cubit = SavedRoutesCubit(repository: _InMemorySavedRoutesRepository());
    await cubit.initialize();
  });

  tearDown(() => cubit.close());

  // Only the home screen's own delegates: the dialog's labels are injected,
  // so the button must not need SavedPlacesLocalizations to be installed.
  Widget host(Widget child, {bool withCubit = true}) => MaterialApp(
    localizationsDelegates: HomeScreenLocalizations.localizationsDelegates,
    supportedLocales: HomeScreenLocalizations.supportedLocales,
    home: Scaffold(
      body: withCubit
          ? BlocProvider<SavedRoutesCubit>.value(value: cubit, child: child)
          : child,
    ),
  );

  SaveRouteButton button({TrufiLocation from = _from, bool dense = true}) =>
      SaveRouteButton(
        from: from,
        to: _to,
        itinerary: _itinerary(),
        dense: dense,
      );

  Finder bookmarkOutlined() => find.byIcon(Icons.bookmark_add_outlined);
  Finder bookmarkSolid() => find.byIcon(Icons.bookmark_rounded);
  Finder saveButton() => find.widgetWithText(FilledButton, 'Save');

  testWidgets('renders nothing without a SavedRoutesCubit', (tester) async {
    await tester.pumpWidget(host(button(), withCubit: false));

    expect(find.byType(SaveRouteButton), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(SaveRouteButton),
        matching: find.byType(Icon),
      ),
      findsNothing,
    );
  });

  testWidgets('saves the trip under the proposed name with the itinerary '
      'snapshot and confirms', (tester) async {
    await tester.pumpWidget(host(button()));

    await tester.tap(bookmarkOutlined());
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(TextFormField, 'Plaza → Terminal'),
      findsOneWidget,
    );

    await tester.tap(saveButton());
    await tester.pumpAndSettle();

    final route = cubit.state.routes.single;
    expect(route.name, 'Plaza → Terminal');
    expect(route.origin.name, 'Plaza');
    expect(route.destination.latitude, -17.37);
    expect(route.snapshot?.transitLegs.single.shortName, '123');
    expect(route.snapshot?.transitLegs.single.colorHex, '7E57C2');
    expect(route.snapshot?.transitLegs.single.mode, 'BUS');
    expect(route.snapshot?.durationSeconds, 1800);
    expect(find.text('Route saved as "Plaza → Terminal"'), findsOneWidget);
    expect(
      bookmarkSolid(),
      findsOneWidget,
      reason: 'the icon follows the cubit',
    );
    expect(bookmarkOutlined(), findsNothing);
  });

  testWidgets('a saved trip shows the solid bookmark and warns instead of '
      'asking again', (tester) async {
    await cubit.saveRoute(
      SavedRoute.create(
        name: 'Al trabajo',
        origin: SavedRoutePoint.fromTrufiLocation(_from),
        destination: SavedRoutePoint.fromTrufiLocation(_to),
      ),
    );
    await tester.pumpWidget(host(button()));

    expect(bookmarkSolid(), findsOneWidget);

    await tester.tap(bookmarkSolid());
    await tester.pumpAndSettle();

    expect(find.byType(RouteNameDialog), findsNothing);
    expect(
      find.text('This route is already saved as "Al trabajo"'),
      findsOneWidget,
    );
    expect(cubit.state.routes, hasLength(1));
  });

  testWidgets('falls back to generic names for unlabeled endpoints', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        button(
          from: const TrufiLocation(
            description: '',
            latitude: -17.39,
            longitude: -66.16,
          ),
        ),
      ),
    );

    await tester.tap(bookmarkOutlined());
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(TextFormField, 'Origin → Terminal'),
      findsOneWidget,
    );
  });

  testWidgets('cancelling the dialog saves nothing', (tester) async {
    await tester.pumpWidget(host(button()));

    await tester.tap(bookmarkOutlined());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Cancel'));
    await tester.pumpAndSettle();

    expect(cubit.state.routes, isEmpty);
    expect(bookmarkOutlined(), findsOneWidget);
  });

  testWidgets('the filled variant is an IconButton with the tooltip', (
    tester,
  ) async {
    await tester.pumpWidget(host(button(dense: false)));

    expect(find.byType(IconButton), findsOneWidget);
    expect(find.byTooltip('Save route'), findsOneWidget);
    expect(bookmarkOutlined(), findsOneWidget);
  });
}
