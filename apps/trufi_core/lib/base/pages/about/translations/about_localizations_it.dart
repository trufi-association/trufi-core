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
  String aboutContent(Object appName, Object city) {
    return 'Need to go somewhere and don\'t know which trufi or bus to take?\nThe $appName makes it easy!\n\nTrufi Association is a team from Bolivia and beyond. We love La Llajta and public transportation, that\'s why we developed this application to make transportation easy. Our goal is to provide you with a practical tool that allows you to navigate with confidence.\n\nWe are committed to the continuous improvement of $appName to offer you more and more accurate and useful information. We know that the transportation system in $city undergoes changes due to different reasons, so it is possible that some routes are not completely up to date.\n\nTo make $appName an effective tool, we rely on the collaboration of our users. If you are aware of changes in some routes or stops, we encourage you to share this information with us. Your contribution will not only help keep the app up to date, but will also benefit other users who rely on $appName.\n\nThank you for choosing $appName to move around $city, we hope you enjoy your experience with us!';
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
