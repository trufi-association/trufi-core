// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String instruction_distance_meters(String distance) {
    return '$distance m';
  }

  @override
  String instruction_distance_km(String distance) {
    return '$distance km';
  }

  @override
  String get selected_on_map => 'Seleccionado en el mapa';

  @override
  String get default_location_home => 'Casa';

  @override
  String get default_location_work => 'Trabajo';

  @override
  String default_location_add(String location) {
    return 'Establecer ubicación de $location';
  }

  @override
  String get default_location_setLocation => 'Establecer ubicación';

  @override
  String get yourPlaces_menu => 'Tus Lugares';

  @override
  String get feedback_menu => 'Enviar Comentarios';

  @override
  String get feedback_title => 'Por favor envíanos un correo electrónico';

  @override
  String get feedback_content =>
      '¿Tienes sugerencias para nuestra aplicación o encontraste algún error en los datos? ¡Nos encantaría saber de ti! Asegúrate de agregar tu dirección de correo electrónico o teléfono para que podamos responderte.';

  @override
  String get aboutUs_menu => 'Acerca de este servicio';

  @override
  String aboutUs_version(String version) {
    return 'Versión $version';
  }

  @override
  String get aboutUs_licenses => 'Licencias';

  @override
  String get aboutUs_openSource =>
      'Esta aplicación se publica como código abierto en GitHub. Siéntete libre de contribuir al código o llevar una aplicación a tu propia ciudad.';
}
