// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String instruction_distance_meters(String distance) {
    return '$distance m';
  }

  @override
  String instruction_distance_km(String distance) {
    return '$distance km';
  }

  @override
  String get selected_on_map => 'Auf der Karte ausgewählt';

  @override
  String get default_location_home => 'Zuhause';

  @override
  String get default_location_work => 'Arbeit';

  @override
  String default_location_add(String location) {
    return '$location-Standort festlegen';
  }

  @override
  String get default_location_setLocation => 'Standort festlegen';

  @override
  String get yourPlaces_menu => 'Deine Orte';

  @override
  String get feedback_menu => 'Feedback senden';

  @override
  String get feedback_title => 'Bitte senden Sie uns eine E-Mail';

  @override
  String get feedback_content =>
      'Haben Sie Vorschläge für unsere App oder Fehler in den Daten gefunden? Wir würden uns freuen, von Ihnen zu hören! Bitte geben Sie Ihre E-Mail-Adresse oder Telefonnummer an, damit wir Ihnen antworten können.';

  @override
  String get aboutUs_menu => 'Über diesen Dienst';

  @override
  String aboutUs_version(String version) {
    return 'Version $version';
  }

  @override
  String get aboutUs_licenses => 'Lizenzen';

  @override
  String get aboutUs_openSource =>
      'Diese App wird als Open Source auf GitHub veröffentlicht. Sie können gerne zum Code beitragen oder eine App in Ihre eigene Stadt bringen.';
}
