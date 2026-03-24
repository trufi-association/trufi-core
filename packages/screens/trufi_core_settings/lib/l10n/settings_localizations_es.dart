// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'settings_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class SettingsLocalizationsEs extends SettingsLocalizations {
  SettingsLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get onboardingTitle => '¡Bienvenido!';

  @override
  String get onboardingSubtitle => 'Vamos a configurar tus preferencias';

  @override
  String get onboardingLanguageTitle => 'Elige tu idioma';

  @override
  String get onboardingThemeTitle => 'Elige tu tema';

  @override
  String get onboardingThemeLight => 'Claro';

  @override
  String get onboardingThemeDark => 'Oscuro';

  @override
  String get onboardingThemeSystem => 'Sistema';

  @override
  String get onboardingMapTitle => 'Elige tu estilo de mapa';

  @override
  String get onboardingRoutingTitle => 'Elige tu motor de enrutamiento';

  @override
  String get onboardingComplete => 'Comenzar';

  @override
  String get privacyConsentTitle => 'Ayuda a mejorar la app';

  @override
  String get privacyConsentSubtitle =>
      'Ayúdanos a mejorar la app compartiendo datos de uso anónimos';

  @override
  String get privacyConsentInfoTitle => 'Qué recopilamos';

  @override
  String get privacyConsentInfoLogs =>
      'Registros de errores para ayudarnos a corregir fallos';

  @override
  String get privacyConsentInfoRoutes =>
      'Búsquedas de rutas para mejorar los datos de transporte';

  @override
  String get privacyConsentInfoAnonymous =>
      'Todos los datos son completamente anónimos';

  @override
  String get privacyConsentAccept => 'Aceptar y continuar';

  @override
  String get privacyConsentDecline => 'No, gracias';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsSelectLanguage => 'Selecciona tu idioma preferido:';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsSelectTheme => 'Selecciona tu tema preferido:';

  @override
  String get settingsThemeLight => 'Modo Claro';

  @override
  String get settingsThemeDark => 'Modo Oscuro';

  @override
  String get settingsThemeSystem => 'Predeterminado del Sistema';

  @override
  String get settingsMap => 'Mapa';

  @override
  String get settingsSelectMapType => 'Selecciona tu tipo de mapa preferido:';

  @override
  String get settingsRouting => 'Enrutamiento';

  @override
  String get settingsSelectRoutingEngine =>
      'Selecciona tu motor de enrutamiento preferido:';

  @override
  String get settingsPrivacy => 'Privacidad';

  @override
  String get settingsPrivacySubtitle => 'Ayuda a mejorar la app';

  @override
  String get settingsPrivacyShareData => 'Compartir datos de uso anónimos';

  @override
  String get settingsPrivacyShareDataDescription =>
      'Ayúdanos a corregir errores y mejorar los datos de transporte';

  @override
  String get engineOnlineName => 'En línea';

  @override
  String get engineOnlineDescription =>
      'OpenTripPlanner 2.8. Rutas en tiempo real con indicaciones detalladas de caminata.';

  @override
  String get engineOfflineName => 'Sin conexión';

  @override
  String get engineOfflineDescription =>
      'Enrutamiento basado en GTFS. Funciona sin internet.';

  @override
  String get limitationRequiresInternet => 'Requiere internet';

  @override
  String get limitationSlower => 'Respuesta más lenta';

  @override
  String get limitationNoWalkingRoute => 'Sin ruta de caminata en mapa';
}
