


import 'about_localizations.dart';

/// The translations for Italian (`it`).
class AboutLocalizationIt extends AboutLocalization {
  AboutLocalizationIt([String locale = 'it']) : super(locale);

  @override
  String get aboutCollapseContent => 'Trufi Association is an international NGO that promotes easier access to public transport. Our apps help everyone find the best way to get from point A to point B within their cities.\n\nIn many cities there are no official maps, routes, apps or timetables. So we compile the available information, and sometimes even map routes from scratch working with local people who know the city.  An easy-to-use transportation system contributes to greater sustainability, cleaner air and a better quality of life.';

  @override
  String get aboutCollapseContentFoot => 'We need mappers, developers, planners, testers, and many other hands.';

  @override
  String get aboutCollapseTitle => 'More About Trufi Association';

  @override
  String aboutContent(Object appName) {
    return 'Need to go somewhere and don\'t know which trufi or bus to take?\nThe $appName makes it easy!\n\nTrufi Association is a team from Bolivia and beyond. We love La Llajta and public transportation, and we want to make it easier to use for everyone. So we developed this app. We hope you enjoy it.';
  }

  @override
  String get aboutLicenses => 'Licenze';

  @override
  String get aboutOpenSource => 'This app is released as open source on GitHub. Feel free to contribute to the code, or bring an app to your own city.';

  @override
  String get menuAbout => 'About us';

  @override
  String tagline(Object city) {
    return 'Trasporto pubblico a $city';
  }

  @override
  String get trufiWebsite => 'Trufi Association Website';

  @override
  String version(Object version) {
    return 'Versione $version';
  }

  @override
  String get volunteerTrufi => 'Volunteer For Trufi';
}
