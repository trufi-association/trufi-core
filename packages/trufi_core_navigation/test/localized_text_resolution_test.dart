import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_navigation/l10n/navigation_localizations_de.dart';
import 'package:trufi_core_navigation/l10n/navigation_localizations_en.dart';
import 'package:trufi_core_navigation/l10n/navigation_localizations_es.dart';
import 'package:trufi_core_navigation/trufi_core_navigation.dart';

void main() {
  final en = NavigationLocalizationsEn();
  final es = NavigationLocalizationsEs();
  final de = NavigationLocalizationsDe();

  group('NavigationError.localizedMessage', () {
    test('resolves every error to the English message', () {
      expect(
        NavigationError.trackingStartFailed.localizedMessage(en),
        'Could not start location tracking',
      );
      expect(
        NavigationError.permissionDenied.localizedMessage(en),
        'Location permission denied',
      );
      expect(
        NavigationError.permissionDeniedForever.localizedMessage(en),
        'Location permission permanently denied. Please enable in settings.',
      );
      expect(
        NavigationError.serviceDisabled.localizedMessage(en),
        'Location services are disabled. Please enable them.',
      );
    });

    test('resolves to German messages for German users', () {
      expect(
        NavigationError.permissionDenied.localizedMessage(de),
        'Standortberechtigung verweigert',
      );
      expect(
        NavigationError.trackingStartFailed.localizedMessage(de),
        'Standortverfolgung konnte nicht gestartet werden',
      );
    });

    test('resolves to Spanish messages', () {
      expect(
        NavigationError.permissionDenied.localizedMessage(es),
        'Permiso de ubicación denegado',
      );
    });
  });

  group('NavigationInstruction.resolvedPrimaryText', () {
    test('resolves primaryTextKey per locale', () {
      const instruction = NavigationInstruction(
        type: InstructionType.arriveDestination,
        primaryTextKey: InstructionTextKey.youHaveArrived,
      );

      expect(instruction.resolvedPrimaryText(en), 'You have arrived');
      expect(instruction.resolvedPrimaryText(es), 'Has llegado');
      expect(instruction.resolvedPrimaryText(de), 'Sie sind angekommen');
    });

    test('resolves finalDestination key per locale', () {
      const instruction = NavigationInstruction(
        type: InstructionType.arriveDestination,
        primaryTextKey: InstructionTextKey.finalDestination,
      );

      expect(instruction.resolvedPrimaryText(en), 'Final destination');
      expect(instruction.resolvedPrimaryText(es), 'Destino final');
      expect(instruction.resolvedPrimaryText(de), 'Endziel');
    });

    test('falls back to primaryText when no key is set', () {
      const instruction = NavigationInstruction(
        type: InstructionType.arriveStop,
        primaryText: 'Plaza Colón',
      );

      expect(instruction.resolvedPrimaryText(en), 'Plaza Colón');
      expect(instruction.resolvedPrimaryText(de), 'Plaza Colón');
    });

    test('primaryTextKey takes precedence over primaryText', () {
      const instruction = NavigationInstruction(
        type: InstructionType.arriveDestination,
        primaryText: 'You have arrived',
        primaryTextKey: InstructionTextKey.youHaveArrived,
      );

      expect(instruction.resolvedPrimaryText(de), 'Sie sind angekommen');
    });
  });

  group('NavigationInstruction.resolvedSecondaryText', () {
    test('counts the remaining stops per locale, plural-aware', () {
      const several = NavigationInstruction(
        type: InstructionType.rideTransport,
        secondaryText: '12 stops remaining',
        secondaryTextKey: InstructionTextKey.stopsRemaining,
        remainingStops: 12,
      );
      const one = NavigationInstruction(
        type: InstructionType.rideTransport,
        secondaryTextKey: InstructionTextKey.stopsRemaining,
        remainingStops: 1,
      );

      expect(several.resolvedSecondaryText(en), '12 stops remaining');
      expect(several.resolvedSecondaryText(es), 'Quedan 12 paradas');
      expect(several.resolvedSecondaryText(de), 'Noch 12 Haltestellen');
      expect(one.resolvedSecondaryText(en), '1 stop remaining');
      expect(one.resolvedSecondaryText(es), 'Queda 1 parada');
      expect(one.resolvedSecondaryText(de), 'Noch 1 Haltestelle');
    });

    test('writes the distance to a stop in meters below a kilometer', () {
      const instruction = NavigationInstruction(
        type: InstructionType.rideTransport,
        secondaryTextKey: InstructionTextKey.distanceToStop,
        distance: 849.6,
      );

      expect(instruction.resolvedSecondaryText(en), '850 m');
      expect(instruction.resolvedSecondaryText(es), '850 m');
      expect(instruction.resolvedSecondaryText(de), '850 m');
    });

    test('writes it in kilometers from there on, with the decimal '
        'separator of the locale', () {
      const instruction = NavigationInstruction(
        type: InstructionType.rideTransport,
        secondaryTextKey: InstructionTextKey.distanceToStop,
        distance: 12345,
      );

      expect(instruction.resolvedSecondaryText(en), '12.3 km');
      expect(instruction.resolvedSecondaryText(es), '12,3 km');
      expect(instruction.resolvedSecondaryText(de), '12,3 km');
    });

    test('formats the number for the given locale instead of the one of '
        'the localizations', () {
      const instruction = NavigationInstruction(
        type: InstructionType.rideTransport,
        secondaryTextKey: InstructionTextKey.distanceToStop,
        distance: 1500,
      );

      expect(instruction.resolvedSecondaryText(es, locale: 'es_MX'), '1.5 km');
      // A locale intl has no number symbols for still gets a number (#945).
      expect(instruction.resolvedSecondaryText(es, locale: 'qu'), '1.5 km');
    });

    test('falls back to secondaryText without a distance or a key', () {
      const noDistance = NavigationInstruction(
        type: InstructionType.rideTransport,
        secondaryText: 'soon',
        secondaryTextKey: InstructionTextKey.distanceToStop,
      );
      const noKey = NavigationInstruction(
        type: InstructionType.walkStraight,
        secondaryText: 'in 50m',
      );
      const nothing = NavigationInstruction(type: InstructionType.depart);

      expect(noDistance.resolvedSecondaryText(en), 'soon');
      expect(noKey.resolvedSecondaryText(de), 'in 50m');
      expect(nothing.resolvedSecondaryText(en), isNull);
    });
  });
}
