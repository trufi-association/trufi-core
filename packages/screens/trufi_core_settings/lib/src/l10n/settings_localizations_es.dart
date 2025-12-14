// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'settings_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class SettingsLocalizationsEs extends SettingsLocalizations {
  SettingsLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsSelectLanguage => 'Selecciona tu idioma preferido:';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeLight => 'Modo Claro';

  @override
  String get settingsThemeDark => 'Modo Oscuro';

  @override
  String get settingsThemeSystem => 'Predeterminado del Sistema';

  @override
  String get settingsSelectTheme => 'Selecciona tu tema preferido:';

  @override
  String get settingsMap => 'Mapa';

  @override
  String get settingsSelectMapType => 'Selecciona tu tipo de mapa preferido:';
}
