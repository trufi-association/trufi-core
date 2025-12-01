import 'about_localizations.dart';

/// The translations for Spanish Castilian (`es`).
class AboutLocalizationEs extends AboutLocalization {
  AboutLocalizationEs([String locale = 'es']) : super(locale);

  @override
  String get aboutCollapseContent => 'Trufi Association es una ONG internacional que promueve un acceso más fácil al transporte público. Nuestras aplicaciones ayudan a que todos puedan encontrar la mejor manera de ir de un punto A a un punto B dentro de sus ciudades.\n\nEn muchas ciudades no existen mapas, aplicaciones ni horarios oficiales. Nosotros nos encargamos de completarlos, y a veces incluso trazamos rutas desde cero. Un sistema de transporte bien diseñado contribuye a una mayor sostenibilidad, un aire más limpio y una mejor calidad de vida.';

  @override
  String get aboutCollapseContentFoot => 'Forma parte de nuestro equipo de voluntarios. Necesitamos mapeadores, desarrolladores, planificadores, testers y otras manos más.';

  @override
  String get aboutCollapseTitle => 'Más sobre Trufi Association';

  @override
  String aboutContent(Object appName, Object city) {
    return '¿Necesitas ir a algún lado y no sabes qué trufi o micro tomar?\n¡Con $appName facilito es!\n\nTrufi Association es un equipo conformado por voluntarios de Bolivia y otros países. Amamos La Llajta y el transporte público, por eso desarrollamos esta aplicación para que transportarse sea fácil. Nuestro objetivo es brindarte una herramienta práctica que te permita navegar con confianza.\n\nEstamos comprometidos con la mejora continua de $appName para ofrecerte información cada vez más precisa y útil. Sabemos que el sistema de transporte en $city experimenta cambios debido a diversas razones, por ello es posible que algunas rutas no estén completamente actualizadas.\n\nPara hacer de $appName una herramienta aún más efectiva, confiamos en la colaboración de nuestros usuarios. Si conoces cambios en algunas rutas o paradas, te animamos a compartir esta información con nosotros. Tu contribución no solo ayudará a mantener la aplicación al día, sino que también beneficiará a otros usuarios que confían en $appName.\n\nGracias por elegir $appName para moverte en $city. ¡Esperamos que disfrutes la experiencia con nosotros!';
  }

  @override
  String get aboutLicenses => 'Licencias';

  @override
  String get aboutOpenSource => 'Esta aplicación está publicada como código abierto en GitHub. Siéntase libre de contribuir  o utilizarlo para su propia ciudad.';

  @override
  String get menuAbout => 'Sobre nosotros';

  @override
  String tagline(Object city) {
    return 'Transporte público en $city';
  }

  @override
  String get trufiWebsite => 'Sitio web de Trufi Association';

  @override
  String version(Object version) {
    return 'Versión $version';
  }

  @override
  String get volunteerTrufi => 'Voluntariados para Trufi';
}
