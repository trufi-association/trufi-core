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

  @override
  String get errorInitialization => 'App konnte nicht initialisiert werden';

  @override
  String get actionRetry => 'Erneut versuchen';

  @override
  String get errorPageNotFound => 'Seite nicht gefunden';

  @override
  String get errorNoScreensRegistered => 'Keine Bildschirme registriert';

  @override
  String get actionGoHome => 'Zur Startseite';

  @override
  String get titleError => 'Fehler';

  @override
  String unreadCount(int count) {
    return '$count ungelesen';
  }

  @override
  String get markAllAsRead => 'Alle als gelesen markieren';

  @override
  String get initStepStarting => 'Wird gestartet';

  @override
  String get initStepInitializing => 'Wird initialisiert';

  @override
  String get initStepLoadingMaps => 'Karten werden geladen';

  @override
  String get initStepLoadingRoutes => 'Routen werden geladen';

  @override
  String get initStepAlmostReady => 'Fast fertig';

  @override
  String get errorUnableToStart => 'Start nicht möglich';

  @override
  String get errorUnexpected => 'Ein unerwarteter Fehler ist aufgetreten';

  @override
  String get poweredByTrufi => 'Powered by Trufi Association';
}
