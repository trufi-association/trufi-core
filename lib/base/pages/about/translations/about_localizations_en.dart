


import 'about_localizations.dart';

/// The translations for English (`en`).
class AboutLocalizationEn extends AboutLocalization {
  AboutLocalizationEn([String locale = 'en']) : super(locale);

  @override
  String get aboutCollapseContent => 'The Trufi app for Cochabamba enhances your travel experience on trufis and buses, and helps to move around Cochabamba.\n\nNeed to go somewhere and don\'t know which trufi or bus to take?\n\nWith Trufi App it\'s easy!\n\nTrufi Association is an international NGO that promotes easier access to public transport. Official maps, apps, and schedules don\'t exist in many cities. We fill in the gaps - and sometimes even map routes from scratch. Our apps help everyone find the best way to get from Point A to Point B within their cities. Well-designed mobility contributes to greater sustainability, cleaner air and better quality of life.\nIn many cities there are no official maps, apps or timetables. We complete them, and sometimes even draw routes from scratch. Our apps help everyone find the best way to get from point A to point B within their cities. A well-designed transportation system contributes to greater sustainability, cleaner air and a better quality of life.\n\nWe love La Llajta and public transportation, that\'s why Trufi Association created this app to make it easy for Cochabamba commuters and anyone else to get around Cochabamba.\n\nPlease help us make Trufi App better by volunteering with us. We need mappers, developers, planners, testers, and many other hands. Please contact our team via email feedback@trufi.app.\n';

  @override
  String get aboutCollapseTitle => 'We are the coolest group ever! Any other questions?';

  @override
  String get aboutContent => 'We are a Bolivian and international team of people that love and support public transport. We have developed this app to make it easy for people to use the transport system in Cochabamba and the surrounding area.';

  @override
  String get aboutLicenses => 'Licenses';

  @override
  String get aboutOpenSource => 'This app is released as open source on GitHub. Feel free to contribute or bring it to your own city.';

  @override
  String get menuAbout => 'About';

  @override
  String tagline(Object city) {
    return 'Public transportation in $city';
  }

  @override
  String version(Object version) {
    return 'Version $version';
  }
}
