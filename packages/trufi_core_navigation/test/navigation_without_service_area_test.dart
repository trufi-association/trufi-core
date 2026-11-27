import 'package:flutter_test/flutter_test.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'support/navigation_fixtures.dart';
import 'support/navigation_screen_harness.dart';

/// trufi-lima#12 (reopened): an app that gives no `serviceArea` (every city
/// but Lima) keeps today's navigation, whatever the rider's position: the
/// distance and the ETA show, no "outside" notice, the map starts on the
/// rider. These pass before and after the service-area work.
void main() {
  final realWakelock = wakelockPlusPlatformInstance;
  setUp(() => wakelockPlusPlatformInstance = NoWakelock());
  tearDown(() => wakelockPlusPlatformInstance = realWakelock);

  testWidgets('no serviceArea, rider far away: distance and ETA show, no '
      'notice, the map starts on the rider', (tester) async {
    final run = await startSanaaNavigation(tester, rider: farAway);

    expect(distanceFigure, findsOneWidget);
    expect(etaFigure, findsOneWidget);
    expect(find.textContaining('outside'), findsNothing);
    expect(run.maps.engine.calls, isNotEmpty);
    expect(run.maps.engine.calls.last.target, farAway);
  });

  testWidgets('no serviceArea, rider at the trip: the distance shows', (
    tester,
  ) async {
    await startSanaaNavigation(tester, rider: SanaaTrip.origin);

    expect(distanceFigure, findsOneWidget);
    expect(find.textContaining('outside'), findsNothing);
  });
}
