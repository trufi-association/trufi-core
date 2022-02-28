


import 'about_localizations.dart';

/// The translations for German (`de`).
class AboutLocalizationDe extends AboutLocalization {
  AboutLocalizationDe([String locale = 'de']) : super(locale);

  @override
  String aboutCollapseContent(Object appName, Object city) {
    return 'The $appName for $city enhances your travel experience on trufis and buses, and helps to move around $city.\n\nNeed to go somewhere and don\'t know which trufi or bus to take?\nWith Trufi App it\'s easy! \n\nTrufi Association is an international NGO that promotes easier access to public transport. In many cities there are no official maps, apps or timetables. We complete them, and sometimes even draw routes from scratch. Our apps help everyone find the best way to get from point A to point B within their cities. A well-designed transportation system contributes to greater sustainability, cleaner air and a better quality of life.\n\nWe love La Llajta and public transportation, that\'s why Trufi Association created this app to make it easy for $city commuters and anyone else to get around $city.\n\nPlease help us make $appName better by volunteering with us. We need mappers, developers, planners, testers, and many other hands. Please contact our team via email feedback@trufi.app.\n';
  }

  @override
  String get aboutCollapseTitle => 'We are the coolest group ever! Any other questions?';

  @override
  String get aboutContent => 'Wir sind ein bolivianisches und internationales Team, das den öffentlichen Nahverkehr liebt und unterstützen möchte. Wir haben diese App entwickelt, um den Menschen die Verwendung des öffentlichen Nahverkehrs in Cochabamba und der näheren Umgebung zu erleichtern.';

  @override
  String get aboutLicenses => 'Lizenzen';

  @override
  String get aboutOpenSource => 'Diese App ist Open Source und auf GitHub verfügbar. Zögere nicht, einen Beitrag zu leisten oder bringe sie in Deine Stadt!';

  @override
  String get menuAbout => 'Über';

  @override
  String tagline(Object city) {
    return 'Öffentliche Verkehrsmittel in $city';
  }

  @override
  String version(Object version) {
    return 'Version $version';
  }
}
