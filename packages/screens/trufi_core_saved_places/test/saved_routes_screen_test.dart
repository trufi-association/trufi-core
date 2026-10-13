import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_saved_places/trufi_core_saved_places.dart';

import 'in_memory_storage.dart';

// #1005 through the real widgets: the Your Routes screen lists each saved
// route as a card (title, endpoint chips, transit badges, summary), launches
// the trip through the SharedRouteNotifier channel on tap, and manages the
// route from its menu (rename / swap direction / remove).

const _oLat = -17.39884;
const _oLng = -66.16269;

SavedRoute _casaATrabajo() => SavedRoute(
  id: 'r1',
  name: 'Casa a Trabajo',
  origin: const SavedRoutePoint(
    name: 'Casa',
    latitude: _oLat,
    longitude: _oLng,
  ),
  destination: const SavedRoutePoint(
    name: 'Trabajo',
    latitude: -17.37,
    longitude: -66.15,
  ),
  createdAt: DateTime(2026, 10, 13),
  snapshot: const SavedRouteSnapshot(
    transitLegs: [
      SavedRouteTransitLeg(shortName: 'B301', colorHex: '7E57C2'),
      SavedRouteTransitLeg(shortName: 'T105'),
    ],
    distanceMeters: 5000,
    durationSeconds: 1800,
  ),
);

void main() {
  late InMemoryStorage storage;
  late SavedRoutesCubit cubit;
  late SharedRouteNotifier notifier;

  setUp(() async {
    storage = InMemoryStorage();
    cubit = SavedRoutesCubit(
      repository: SavedRoutesRepositoryImpl(storage: storage),
    );
    await cubit.initialize();
    notifier = SharedRouteNotifier();
  });

  tearDown(() async {
    await cubit.close();
    notifier.dispose();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    // Phone-sized surface, as the saved places tests use.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: SavedPlacesLocalizations.localizationsDelegates,
        supportedLocales: SavedPlacesLocalizations.supportedLocales,
        home: Scaffold(
          body: MultiProvider(
            providers: [
              ChangeNotifierProvider<SharedRouteNotifier>.value(
                value: notifier,
              ),
              BlocProvider<SavedRoutesCubit>.value(value: cubit),
            ],
            child: Builder(builder: SavedRoutesTrufiScreen().builder),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openMenuAction(WidgetTester tester, String label) async {
    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  test('screen wiring: id, path, drawer order and own app bar', () {
    final screen = SavedRoutesTrufiScreen();
    expect(screen.id, 'saved_routes');
    expect(screen.path, '/saved-routes');
    expect(screen.menuItem?.order, 55);
    expect(screen.hasOwnAppBar, isTrue);
    expect(screen.providers, hasLength(1));
  });

  testWidgets('shows the empty state when nothing is saved', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Your Routes'), findsOneWidget);
    expect(find.text('No routes saved yet'), findsOneWidget);
    expect(find.byType(SavedRouteCard), findsNothing);
  });

  testWidgets('renders a card with title, chips, badges and summary', (
    tester,
  ) async {
    await cubit.saveRoute(_casaATrabajo());
    await pumpScreen(tester);

    expect(find.text('Casa a Trabajo'), findsOneWidget);
    expect(find.text('Origin: Casa'), findsOneWidget);
    expect(find.text('Destination: Trabajo'), findsOneWidget);
    expect(find.text('B301'), findsOneWidget);
    expect(find.text('T105'), findsOneWidget);
    expect(find.text('5.0 km, ~30 min'), findsOneWidget);

    final badge = tester.widget<Container>(
      find
          .ancestor(of: find.text('B301'), matching: find.byType(Container))
          .first,
    );
    expect(
      (badge.decoration as BoxDecoration).color,
      const Color(0xFF7E57C2),
      reason: 'the badge wears the saved route colour',
    );
  });

  testWidgets('tapping a card hands the trip to the home screen and marks '
      'it used', (tester) async {
    await cubit.saveRoute(_casaATrabajo());
    await pumpScreen(tester);

    await tester.tap(find.text('Casa a Trabajo'));
    await tester.pumpAndSettle();

    final pending = notifier.pendingRoute;
    expect(pending, isNotNull, reason: 'the home screen consumes this');
    expect(pending!.fromLat, _oLat);
    expect(pending.fromLng, _oLng);
    expect(pending.fromName, 'Casa');
    expect(pending.toName, 'Trabajo');
    expect(cubit.state.routes.single.lastUsedAt, isNotNull);
  });

  testWidgets('onRouteSelected replaces the default launch', (tester) async {
    await cubit.saveRoute(_casaATrabajo());
    SavedRoute? selected;
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: SavedPlacesLocalizations.localizationsDelegates,
        supportedLocales: SavedPlacesLocalizations.supportedLocales,
        home: Scaffold(
          body: MultiProvider(
            providers: [
              ChangeNotifierProvider<SharedRouteNotifier>.value(
                value: notifier,
              ),
              BlocProvider<SavedRoutesCubit>.value(value: cubit),
            ],
            child: Builder(
              builder: SavedRoutesTrufiScreen(
                config: SavedRoutesConfig(
                  onRouteSelected: (route) => selected = route,
                ),
              ).builder,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Casa a Trabajo'));
    await tester.pumpAndSettle();

    expect(selected?.id, 'r1');
    expect(notifier.pendingRoute, isNull);
  });

  testWidgets('rename from the menu updates the title', (tester) async {
    await cubit.saveRoute(_casaATrabajo());
    await pumpScreen(tester);

    await openMenuAction(tester, 'Rename route');
    expect(find.byType(RouteNameDialog), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Rutina');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Rutina'), findsOneWidget);
    expect(find.text('Casa a Trabajo'), findsNothing);
    expect(cubit.state.routes.single.name, 'Rutina');
  });

  testWidgets('swap direction inverts the chips and drops the badges', (
    tester,
  ) async {
    await cubit.saveRoute(_casaATrabajo());
    await pumpScreen(tester);

    await openMenuAction(tester, 'Swap direction');

    expect(find.text('Origin: Trabajo'), findsOneWidget);
    expect(find.text('Destination: Casa'), findsOneWidget);
    expect(find.text('B301'), findsNothing);
    expect(find.text('5.0 km, ~30 min'), findsNothing);
  });

  testWidgets('swap is refused with a warning when the reversed trip '
      'already exists', (tester) async {
    await cubit.saveRoute(_casaATrabajo());
    await cubit.saveRoute(
      _casaATrabajo().copyWith(id: 'r2', name: 'Vuelta').swapped(),
    );
    await pumpScreen(tester);

    await tester.tap(find.byIcon(Icons.more_vert_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Swap direction'));
    await tester.pumpAndSettle();

    expect(
      find.text('This route is already saved as "Vuelta"'),
      findsOneWidget,
    );
    expect(cubit.state.routes.first.origin.name, 'Casa');
  });

  testWidgets('remove asks for confirmation and empties the list', (
    tester,
  ) async {
    await cubit.saveRoute(_casaATrabajo());
    await pumpScreen(tester);

    await openMenuAction(tester, 'Remove route');
    expect(
      find.text('Are you sure you want to remove Casa a Trabajo?'),
      findsOneWidget,
    );

    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    expect(find.text('No routes saved yet'), findsOneWidget);
    expect(cubit.state.routes, isEmpty);
  });
}
