// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'about_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AboutLocalizationsEs extends AboutLocalizations {
  AboutLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get aboutCollapseContent =>
      'Trufi Association es una ONG internacional que promueve el acceso más fácil al transporte público. Nuestras aplicaciones ayudan a todos a encontrar la mejor manera de ir del punto A al punto B dentro de sus ciudades.\n\nEn muchas ciudades no hay mapas oficiales, rutas, aplicaciones o horarios. Por eso recopilamos la información disponible y, a veces, incluso mapeamos rutas desde cero trabajando con personas locales que conocen la ciudad. Un sistema de transporte fácil de usar contribuye a una mayor sostenibilidad, un aire más limpio y una mejor calidad de vida.';

  @override
  String get aboutCollapseContentFoot =>
      'Necesitamos cartógrafos, desarrolladores, planificadores, evaluadores y muchas otras manos.';

  @override
  String get aboutCollapseTitle => 'Más sobre Trufi Association';

  @override
  String aboutContent(String appName, String city) {
    return '¿Necesitas llegar a algún lugar y no sabes qué Trufi o autobús tomar?\n¡La $appName lo hace fácil!\n\nTrufi Association es un equipo de Bolivia y de todo el mundo. Amamos La Llajta y el transporte público, por eso desarrollamos esta aplicación para hacer más accesible el transporte público. Nuestro objetivo es proporcionarte una herramienta práctica que te permita moverte de forma segura.\n\nNos esforzamos por mejorar constantemente la $appName para brindarte siempre información precisa y útil. Sabemos que el sistema de transporte en $city está en constante cambio por diversas razones, por lo que es posible que algunas rutas no estén completamente actualizadas.\n\nPara hacer de la $appName una herramienta eficaz, confiamos en tu colaboración. Si conoces cambios en algunas rutas o paradas, te pedimos que compartas esta información con nosotros. Tu contribución no solo ayuda a mantener la aplicación actualizada, sino que también beneficia a otros usuarios que dependen de la $appName.\n\n¡Gracias por usar la $appName para moverte por $city. Esperamos que disfrutes tu tiempo con nosotros!';
  }

  @override
  String get aboutLicenses => 'Licencias';

  @override
  String get aboutOpenSource =>
      'Esta aplicación se publica como código abierto en GitHub. Damos la bienvenida a contribuciones al código o al desarrollo de una aplicación para tu propia ciudad.';

  @override
  String get menuAbout => 'Acerca de';

  @override
  String tagline(String city) {
    return 'Transporte público en $city';
  }

  @override
  String get trufiWebsite => 'Sitio web de Trufi Association';

  @override
  String version(String version) {
    return 'Versión $version';
  }

  @override
  String get volunteerTrufi => 'Voluntario para Trufi';
}
