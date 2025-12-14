// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'settings_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SettingsLocalizationsEn extends SettingsLocalizations {
  SettingsLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsSelectLanguage => 'Select your preferred language:';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeLight => 'Light Mode';

  @override
  String get settingsThemeDark => 'Dark Mode';

  @override
  String get settingsThemeSystem => 'System Default';

  @override
  String get settingsSelectTheme => 'Select your preferred theme:';

  @override
  String get settingsMap => 'Map';

  @override
  String get settingsSelectMapType => 'Select your preferred map type:';
}
