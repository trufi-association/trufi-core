


import 'about_localizations.dart';

/// The translations for Portuguese (`pt`).
class AboutLocalizationPt extends AboutLocalization {
  AboutLocalizationPt([String locale = 'pt']) : super(locale);

  @override
  String get aboutCollapseContent => 'Estimado usuario del transporte público, Trufi App Cochabamba es una aplicación que mejora tu experiencia de viaje en trufis y micros, y así te ayuda a moverte por la ciudad de Cochabamba.\n\n¿Necesitas ir a algún lado y no sabes qué trufi o micro tomar?\n\n¡Con Trufi App facilito es!\n\nTrufi Association es una ONG internacional que promueve un acceso más fácil al transporte público. En muchas ciudades no existen mapas, aplicaciones ni horarios oficiales. Nosotros los completamos, y a veces incluso trazamos rutas desde cero. Nuestras aplicaciones ayudan a todo el mundo a encontrar la mejor manera de ir de un punto A al punto B dentro de sus ciudades. Un sistema de transporte bien diseñado contribuye a una mayor sostenibilidad, un aire más limpio y una mejor calidad de vida.\n\nAmamos la Llajta y el transporte público, por eso Trufi  Association creó esta aplicación para que los cochalos y cualquier otro usuario puedan transportarse fácilmente por Cochabamba.\n';

  @override
  String get aboutCollapseTitle => '¡Somos el grupo más genial del mundo! ¿Alguna otra pregunta?';

  @override
  String get aboutContent => 'Somos uma equipe boliviana e internacional de pessoas que amam e apoiam o transporte público.\n\nNós desenvolvemos este aplicativo para facilitar o uso do sistema de transporte em Cochabamba e arredores.';

  @override
  String get aboutLicenses => 'Licenças';

  @override
  String get aboutOpenSource => 'Este aplicativo é lançado como código aberto no GitHub. Sinta-se livre para contribuir ou trazê-lo para sua própria cidade.';

  @override
  String get menuAbout => 'Sobre';

  @override
  String tagline(Object city) {
    return 'Transporte público em Cochabamba';
  }

  @override
  String version(Object version) {
    return 'Versão $version';
  }
}
