import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

/// #1004: the badge's three visible states (estimate, loading, unavailable)
/// plus the dimmed "stale" variant and the hidden idle state.
void main() {
  final eta = VehicleEta(
    routeId: '1:1132',
    eta: const Duration(seconds: 240),
    timestamp: DateTime(2026, 10, 13, 10, 30),
  );

  Widget host(Widget child) => MaterialApp(
    localizationsDelegates: HomeScreenLocalizations.localizationsDelegates,
    supportedLocales: HomeScreenLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );

  test('kindFor maps status and estimate to a visual kind', () {
    expect(EtaBadge.kindFor(VehicleEtaStatus.idle, null), EtaBadgeKind.hidden);
    expect(EtaBadge.kindFor(VehicleEtaStatus.idle, eta), EtaBadgeKind.hidden);
    expect(
      EtaBadge.kindFor(VehicleEtaStatus.loading, null),
      EtaBadgeKind.loading,
    );
    expect(
      EtaBadge.kindFor(VehicleEtaStatus.loading, eta),
      EtaBadgeKind.stale,
      reason: 'a refresh keeps the old value visible, dimmed',
    );
    expect(EtaBadge.kindFor(VehicleEtaStatus.ready, eta), EtaBadgeKind.ready);
    expect(
      EtaBadge.kindFor(VehicleEtaStatus.ready, null),
      EtaBadgeKind.unavailable,
      reason: 'the source answered but not for this route',
    );
    expect(
      EtaBadge.kindFor(VehicleEtaStatus.unavailable, null),
      EtaBadgeKind.unavailable,
    );
    expect(
      EtaBadge.kindFor(VehicleEtaStatus.error, null),
      EtaBadgeKind.unavailable,
      reason: 'failures read as the fallback, never as an error message',
    );
  });

  testWidgets('ready shows the minutes with the updated-at tooltip', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        EtaBadge(
          status: VehicleEtaStatus.ready,
          eta: eta,
          fetchedAt: DateTime(2026, 10, 13, 10, 32),
        ),
      ),
    );

    expect(find.text('Arrives in ~4 min'), findsOneWidget);
    expect(find.byIcon(Icons.sensors_rounded), findsOneWidget);
    final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
    expect(tooltip.message, startsWith('Updated '));
    expect(tooltip.message, contains('10:32'));
    expect(find.byType(Opacity), findsNothing);
  });

  testWidgets('unavailable shows the fallback without a tooltip', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const EtaBadge(status: VehicleEtaStatus.unavailable)),
    );

    expect(find.text('Live ETA unavailable'), findsOneWidget);
    expect(find.byIcon(Icons.sensors_off_rounded), findsOneWidget);
    expect(find.byType(Tooltip), findsNothing);
  });

  testWidgets('loading spins', (tester) async {
    await tester.pumpWidget(
      host(const EtaBadge(status: VehicleEtaStatus.loading)),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Checking live ETA…'), findsOneWidget);
  });

  testWidgets('stale keeps the estimate, dimmed', (tester) async {
    await tester.pumpWidget(
      host(EtaBadge(status: VehicleEtaStatus.loading, eta: eta)),
    );

    expect(find.text('Arrives in ~4 min'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    final opacity = tester.widget<Opacity>(find.byType(Opacity));
    expect(opacity.opacity, 0.6);
  });

  testWidgets('idle renders nothing at all', (tester) async {
    await tester.pumpWidget(
      host(const EtaBadge(status: VehicleEtaStatus.idle)),
    );

    expect(tester.getSize(find.byType(EtaBadge)), Size.zero);
    expect(find.byType(Tooltip), findsNothing);
    expect(find.byType(Icon), findsNothing);
  });
}
