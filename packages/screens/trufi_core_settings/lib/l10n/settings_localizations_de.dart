// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'settings_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class SettingsLocalizationsDe extends SettingsLocalizations {
  SettingsLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get onboardingTitle => 'Willkommen!';

  @override
  String get onboardingSubtitle => 'Lass uns deine Einstellungen festlegen';

  @override
  String get onboardingLanguageTitle => 'Wahle deine Sprache';

  @override
  String get onboardingThemeTitle => 'Wahle dein Design';

  @override
  String get onboardingThemeLight => 'Hell';

  @override
  String get onboardingThemeDark => 'Dunkel';

  @override
  String get onboardingThemeSystem => 'System';

  @override
  String get onboardingMapTitle => 'Wahle deinen Kartenstil';

  @override
  String get onboardingRoutingTitle => 'Wahle deine Routenplanung';

  @override
  String get onboardingComplete => 'Los geht\'s';

  @override
  String get privacyConsentTitle => 'Hilf uns, Trufi zu verbessern';

  @override
  String get privacyConsentSubtitle =>
      'Hilf uns, die App zu verbessern, indem du anonyme Nutzungsdaten teilst';

  @override
  String get privacyConsentInfoTitle => 'Was wir sammeln';

  @override
  String get privacyConsentInfoLogs =>
      'Fehlerprotokolle, um Absturze und Bugs zu beheben';

  @override
  String get privacyConsentInfoRoutes =>
      'Routensuchen zur Verbesserung der Nahverkehrsdaten';

  @override
  String get privacyConsentInfoAnonymous =>
      'Alle Daten sind vollstandig anonym';

  @override
  String get privacyConsentAccept => 'Akzeptieren und fortfahren';

  @override
  String get privacyConsentDecline => 'Nein, danke';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsSelectLanguage => 'Wahlen Sie Ihre bevorzugte Sprache:';

  @override
  String get settingsTheme => 'Design';

  @override
  String get settingsSelectTheme => 'Wahlen Sie Ihr bevorzugtes Design:';

  @override
  String get settingsThemeLight => 'Heller Modus';

  @override
  String get settingsThemeDark => 'Dunkler Modus';

  @override
  String get settingsThemeSystem => 'Systemstandard';

  @override
  String get settingsMap => 'Karte';

  @override
  String get settingsSelectMapType => 'Wahlen Sie Ihren bevorzugten Kartentyp:';

  @override
  String get settingsRouting => 'Routenplanung';

  @override
  String get settingsSelectRoutingEngine =>
      'Wahlen Sie Ihre bevorzugte Routenplanung:';

  @override
  String get settingsPrivacy => 'Datenschutz';

  @override
  String get settingsPrivacySubtitle => 'Hilf uns, die App zu verbessern';

  @override
  String get settingsPrivacyShareData => 'Anonyme Nutzungsdaten teilen';

  @override
  String get settingsPrivacyShareDataDescription =>
      'Hilf uns, Fehler zu beheben und Nahverkehrsdaten zu verbessern';

  @override
  String get engineOnlineName => 'Online';

  @override
  String get engineOnlineDescription =>
      'OpenTripPlanner 2.8. Echtzeit-Routing mit detaillierten Fußweganweisungen.';

  @override
  String get engineOfflineName => 'Offline';

  @override
  String get engineOfflineDescription =>
      'GTFS-basiertes Routing, inspiriert von GuíaCochala. Funktioniert ohne Internet.';

  @override
  String get limitationRequiresInternet => 'Erfordert Internet';

  @override
  String get limitationSlower => 'Langsamere Antwort';

  @override
  String get limitationNoWalkingRoute => 'Keine Fußweg-Route auf Karte';
}
