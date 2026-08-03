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
}
