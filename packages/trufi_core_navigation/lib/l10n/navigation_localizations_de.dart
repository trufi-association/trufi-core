// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'navigation_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class NavigationLocalizationsDe extends NavigationLocalizations {
  NavigationLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get navExitNavigation => 'Navigation beenden';

  @override
  String get navExitConfirmTitle => 'Navigation beenden?';

  @override
  String get navExitConfirmMessage =>
      'Möchten Sie die Navigation auf dieser Route wirklich beenden?';

  @override
  String get navCancel => 'Abbrechen';

  @override
  String get navExit => 'Beenden';

  @override
  String get navClose => 'Schließen';

  @override
  String get navRetry => 'Wiederholen';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get navArrived => 'Sie sind angekommen!';

  @override
  String get navOffRoute => 'Sie scheinen von der Route abgekommen zu sein';

  @override
  String get navWeakGps => 'GPS-Signal ist schwach';

  @override
  String get navNext => 'Nächste: ';

  @override
  String get navError => 'Ein Fehler ist aufgetreten';

  @override
  String get navStarting => 'Navigation wird gestartet...';

  @override
  String get navGettingLocation => 'Standort wird ermittelt';

  @override
  String get navCouldNotStartTracking =>
      'Standortverfolgung konnte nicht gestartet werden';

  @override
  String get navArrivedShort => 'Sie sind angekommen';

  @override
  String get navOneStop => '1 Haltestelle';

  @override
  String navStops(int count) {
    return '$count Haltestellen';
  }

  @override
  String navExitAt(String stopName) {
    return 'Aussteigen an $stopName';
  }

  @override
  String get navFinalDestination => 'Endziel';

  @override
  String get navPermissionDenied => 'Standortberechtigung verweigert';

  @override
  String get navPermissionPermanentlyDenied =>
      'Standortberechtigung dauerhaft verweigert. Bitte in den Einstellungen aktivieren.';

  @override
  String get navLocationDisabled =>
      'Standortdienste sind deaktiviert. Bitte aktivieren Sie diese.';

  @override
  String get navOrigin => 'Startpunkt';

  @override
  String get navTransfer => 'Umstieg';

  @override
  String get navDestination => 'Ziel';
}
