// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'core_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class CoreLocalizationsDe extends CoreLocalizations {
  CoreLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Trufi App';

  @override
  String get appLoading => 'Laden...';

  @override
  String get navHome => 'Startseite';

  @override
  String get navSearch => 'Suchen';

  @override
  String get navFeedback => 'Feedback';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get navAbout => 'Über';

  @override
  String get actionSave => 'Speichern';

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionConfirm => 'Bestätigen';

  @override
  String get errorGeneric => 'Ein Fehler ist aufgetreten';

  @override
  String get errorNetwork =>
      'Netzwerkfehler. Bitte überprüfen Sie Ihre Verbindung.';
}
