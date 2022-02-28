


import 'about_localizations.dart';

/// The translations for Portuguese (`pt`).
class AboutLocalizationPt extends AboutLocalization {
  AboutLocalizationPt([String locale = 'pt']) : super(locale);

  @override
  String aboutCollapseContent(Object appName, Object city) {
    return 'The $appName for $city enhances your travel experience on trufis and buses, and helps to move around $city.\n\nNeed to go somewhere and don\'t know which trufi or bus to take?\nWith Trufi App it\'s easy! \n\nTrufi Association is an international NGO that promotes easier access to public transport. In many cities there are no official maps, apps or timetables. We complete them, and sometimes even draw routes from scratch. Our apps help everyone find the best way to get from point A to point B within their cities. A well-designed transportation system contributes to greater sustainability, cleaner air and a better quality of life.\n\nWe love La Llajta and public transportation, that\'s why Trufi Association created this app to make it easy for $city commuters and anyone else to get around $city.\n\nPlease help us make $appName better by volunteering with us. We need mappers, developers, planners, testers, and many other hands. Please contact our team via email feedback@trufi.app.\n';
  }

  @override
  String get aboutCollapseTitle => 'We are the coolest group ever! Any other questions?';

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
    return 'Transporte público em $city';
  }

  @override
  String version(Object version) {
    return 'Versão $version';
  }
}
