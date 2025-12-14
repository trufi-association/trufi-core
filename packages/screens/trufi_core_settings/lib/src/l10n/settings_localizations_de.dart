// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'settings_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class SettingsLocalizationsDe extends SettingsLocalizations {
  SettingsLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsSelectLanguage => 'Wählen Sie Ihre bevorzugte Sprache:';

  @override
  String get settingsTheme => 'Design';

  @override
  String get settingsThemeLight => 'Heller Modus';

  @override
  String get settingsThemeDark => 'Dunkler Modus';

  @override
  String get settingsThemeSystem => 'Systemstandard';

  @override
  String get settingsSelectTheme => 'Wählen Sie Ihr bevorzugtes Design:';

  @override
  String get settingsMap => 'Karte';

  @override
  String get settingsSelectMapType => 'Wählen Sie Ihren bevorzugten Kartentyp:';
}
