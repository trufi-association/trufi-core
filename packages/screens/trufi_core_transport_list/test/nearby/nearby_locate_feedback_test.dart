import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_transport_list/src/nearby/widgets/nearby_locate_feedback.dart';
import 'package:trufi_core_transport_list/trufi_core_transport_list.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart' show LocationService;

import 'geolocator_mock.dart';

/// [showNearbyLocateFailure] on its own: what the screen test cannot
/// reach (a platform without settings pages, a settings page that fails
/// to open) and the wording of every language (trufi-app#78).
Future<void> _pumpAndShow(
  WidgetTester tester,
  NearbyLocateFailure failure, {
  Locale? locale,
  bool? canOpenSettings,
  double textScale = 1.0,
}) async {
  final service = LocationService();
  addTearDown(service.dispose);
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: TransportListLocalizations.localizationsDelegates,
      supportedLocales: TransportListLocalizations.supportedLocales,
      // The device's font size setting.
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => canOpenSettings == null
                ? showNearbyLocateFailure(
                    context,
                    failure,
                    locationService: service,
                  )
                : showNearbyLocateFailure(
                    context,
                    failure,
                    locationService: service,
                    canOpenSettings: canOpenSettings,
                  ),
            child: const Text('locate'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('locate'));
  await tester.pumpAndSettle();
}

/// Lets a snack bar run out: its timer must not outlive the test.
Future<void> _expireSnackBar(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 7));
  await tester.pumpAndSettle();
  expect(find.byType(SnackBar), findsNothing);
}

void main() {
  const dialogFailures = [
    NearbyLocateFailure.permissionDeniedForever,
    NearbyLocateFailure.serviceDisabled,
  ];

  for (final failure in dialogFailures) {
    testWidgets('${failure.name}: where the platform has no settings pages '
        '(web) the dialog only explains, with a single "Close"', (
      tester,
    ) async {
      final calls = mockGeolocator();
      await _pumpAndShow(tester, failure, canOpenSettings: false);

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
      expect(find.text('Open settings'), findsNothing);
      expect(find.text('Cancel'), findsNothing);

      await tester.tap(find.widgetWithText(TextButton, 'Close'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(calls, isEmpty);
    });

    testWidgets('${failure.name}: a settings page that fails to open is '
        'not an error', (tester) async {
      final calls = mockGeolocator(settingsFail: true);
      await _pumpAndShow(tester, failure);

      await tester.tap(find.widgetWithText(FilledButton, 'Open settings'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(calls, [
        failure == NearbyLocateFailure.serviceDisabled
            ? 'openLocationSettings'
            : 'openAppSettings',
      ]);
      expect(tester.takeException(), isNull);
    });
  }

  group('a small phone with the largest font size (360x640, scale 2.0): '
      'the whole message can be read and the action stays in reach', () {
    for (final locale in TransportListLocalizations.supportedLocales) {
      for (final failure in dialogFailures) {
        testWidgets('$locale ${failure.name}', (tester) async {
          tester.view.physicalSize = const Size(360, 640);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          mockGeolocator();
          await _pumpAndShow(tester, failure, locale: locale, textScale: 2.0);

          final l10n = lookupTransportListLocalizations(locale);
          final message = failure == NearbyLocateFailure.serviceDisabled
              ? l10n.nearbyLocationDisabledMessage
              : l10n.nearbyLocationPermissionDeniedForever;

          // Laid out at its full height: nothing is cut off.
          final paragraph = tester.renderObject<RenderParagraph>(
            find.text(message),
          );
          expect(
            paragraph.size.height,
            moreOrLessEquals(
              paragraph.getMaxIntrinsicHeight(paragraph.size.width),
              epsilon: 0.5,
            ),
          );

          // It is taller than the room it has here, so it scrolls; pulled
          // up, its last line shows above the buttons.
          final scrollView = find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(SingleChildScrollView),
          );
          expect(scrollView, findsOneWidget);
          await tester.drag(scrollView, const Offset(0, -2000));
          await tester.pumpAndSettle();
          final action = tester.getRect(
            find.widgetWithText(FilledButton, l10n.nearbyLocationOpenSettings),
          );
          expect(
            tester.getRect(find.text(message)).bottom,
            lessThanOrEqualTo(tester.getRect(scrollView).bottom + 0.5),
          );
          expect(tester.getRect(scrollView).bottom, lessThanOrEqualTo(640));

          // The action is on screen and still works.
          expect(action.top, greaterThanOrEqualTo(0));
          expect(action.bottom, lessThanOrEqualTo(640));
          expect(tester.takeException(), isNull);
          await tester.tap(
            find.widgetWithText(FilledButton, l10n.nearbyLocationOpenSettings),
          );
          await tester.pumpAndSettle();
          expect(find.byType(AlertDialog), findsNothing);
        });
      }
    }
  });

  testWidgets('a second snack bar replaces the first instead of queueing '
      'behind it', (tester) async {
    await _pumpAndShow(tester, NearbyLocateFailure.permissionDenied);
    expect(find.byType(SnackBar), findsOneWidget);

    await tester.tap(find.text('locate'));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    await _expireSnackBar(tester);
  });

  group('every failure has its own text in every language', () {
    /// The texts [failure] puts on screen.
    List<String> textsOf(
      TransportListLocalizations l10n,
      NearbyLocateFailure failure,
    ) => switch (failure) {
      NearbyLocateFailure.permissionDeniedForever => [
        l10n.nearbyLocationPermissionTitle,
        l10n.nearbyLocationPermissionDeniedForever,
        l10n.nearbyLocationOpenSettings,
      ],
      NearbyLocateFailure.serviceDisabled => [
        l10n.nearbyLocationDisabledTitle,
        l10n.nearbyLocationDisabledMessage,
        l10n.nearbyLocationOpenSettings,
      ],
      NearbyLocateFailure.permissionDenied => [
        l10n.nearbyLocationPermissionDenied,
      ],
      NearbyLocateFailure.noFix => [l10n.nearbyLocationNoFix],
    };

    for (final locale in TransportListLocalizations.supportedLocales) {
      for (final failure in NearbyLocateFailure.values) {
        testWidgets('$locale ${failure.name}', (tester) async {
          mockGeolocator();
          await _pumpAndShow(tester, failure, locale: locale);

          final l10n = lookupTransportListLocalizations(locale);
          for (final text in textsOf(l10n, failure)) {
            expect(find.text(text), findsOneWidget, reason: text);
          }
          expect(
            find.byType(AlertDialog),
            dialogFailures.contains(failure) ? findsOneWidget : findsNothing,
          );
          expect(
            find.byType(SnackBar),
            dialogFailures.contains(failure) ? findsNothing : findsOneWidget,
          );
          expect(tester.takeException(), isNull);
          if (!dialogFailures.contains(failure)) await _expireSnackBar(tester);
        });
      }
    }

    test('no language is left with the English text of another', () {
      final english = lookupTransportListLocalizations(const Locale('en'));
      for (final locale in TransportListLocalizations.supportedLocales) {
        if (locale.languageCode == 'en') continue;
        final l10n = lookupTransportListLocalizations(locale);
        for (final failure in NearbyLocateFailure.values) {
          final translated = textsOf(l10n, failure);
          final source = textsOf(english, failure);
          for (var i = 0; i < translated.length; i++) {
            expect(
              translated[i],
              isNot(source[i]),
              reason: '$locale ${failure.name}',
            );
          }
        }
      }
    });

    test('the four reasons read differently', () {
      for (final locale in TransportListLocalizations.supportedLocales) {
        final l10n = lookupTransportListLocalizations(locale);
        final messages = {
          l10n.nearbyLocationPermissionDeniedForever,
          l10n.nearbyLocationDisabledMessage,
          l10n.nearbyLocationPermissionDenied,
          l10n.nearbyLocationNoFix,
        };
        expect(messages, hasLength(4), reason: '$locale');
      }
    });
  });
}
