


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
  String aboutContent(Object appName) {
    return '¿Necesitas ir a algún lado y no sabes qué trufi o micro tomar?\n¡Con $appName facilito es!\n\nTrufi Association es un equipo conformado por voluntarios de Bolivia y otros países. Amamos La Llajta y el transporte público, por eso desarrollamos esta aplicación para que transportarse sea fácil y una experiencia única para todos. Esperamos que lo disfruten.';
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
