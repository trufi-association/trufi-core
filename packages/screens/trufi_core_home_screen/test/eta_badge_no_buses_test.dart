import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';

/// trufi-lima#13: `unavailable` split in two. A route with no vehicle in the
/// snapshot (no GPS) shows nothing; a route whose vehicles none heads to the
/// stop says so.
void main() {
  Widget host(Widget child) => MaterialApp(
    localizationsDelegates: HomeScreenLocalizations.localizationsDelegates,
    supportedLocales: HomeScreenLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );

  testWidgets('noneNearby says there are no buses nearby right now', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const EtaBadge(status: VehicleEtaStatus.noneNearby)),
    );

    expect(find.text('No buses nearby right now'), findsOneWidget);
    expect(find.text('Live ETA unavailable'), findsNothing);
  });

  testWidgets('noLiveData renders nothing at all (no text, no icon)', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const EtaBadge(status: VehicleEtaStatus.noLiveData)),
    );

    expect(tester.getSize(find.byType(EtaBadge)), Size.zero);
    expect(find.byType(Text), findsNothing);
    expect(find.byType(Icon), findsNothing);
    expect(
      EtaBadge.kindFor(VehicleEtaStatus.noLiveData, null),
      EtaBadgeKind.hidden,
    );
  });

  testWidgets('the Spanish texts are the ones of the report', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: HomeScreenLocalizations.localizationsDelegates,
        supportedLocales: HomeScreenLocalizations.supportedLocales,
        home: const Scaffold(
          body: EtaBadge(status: VehicleEtaStatus.noneNearby),
        ),
      ),
    );

    expect(find.text('Sin buses cerca ahora'), findsOneWidget);
  });
}
