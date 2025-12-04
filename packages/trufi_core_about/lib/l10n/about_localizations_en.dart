// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'about_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AboutLocalizationsEn extends AboutLocalizations {
  AboutLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get aboutCollapseContent =>
      'Trufi Association is an international NGO that promotes easier access to public transport. Our apps help everyone find the best way to get from point A to point B within their cities.\n\nIn many cities there are no official maps, routes, apps or timetables. So we compile the available information, and sometimes even map routes from scratch working with local people who know the city.  An easy-to-use transportation system contributes to greater sustainability, cleaner air and a better quality of life.';

  @override
  String get aboutCollapseContentFoot =>
      'We need mappers, developers, planners, testers, and many other hands.';

  @override
  String get aboutCollapseTitle => 'More About Trufi Association';

  @override
  String aboutContent(String appName, String city) {
    return 'Need to get somewhere and don\'t know which Trufi or bus to take?\nThe $appName makes it easy!\n\nTrufi Association is a team from Bolivia and around the world. We love La Llajta and public transportation, so we developed this application to make public transit more accessible. Our goal is to provide you with a practical tool that allows you to move around safely.\n\nWe strive to constantly improve the $appName to always provide you with accurate and useful information. We know that the transportation system in $city is constantly changing for various reasons, so it\'s possible that some routes may not be completely up to date.\n\nTo make the $appName an effective tool, we rely on your collaboration. If you know of changes to some routes or stops, we ask you to share this information with us. Your contribution not only helps keep the app up to date, but also benefits other users who rely on the $appName.\n\nThank you for using the $appName to get around $city. We hope you enjoy your time with us!';
  }

  @override
  String get aboutLicenses => 'Licenses';

  @override
  String get aboutOpenSource =>
      'This app is released as open source on GitHub. We welcome contributions to the code or development of an app for your own city.';

  @override
  String get menuAbout => 'About Us';

  @override
  String tagline(String city) {
    return 'Public transport in $city';
  }

  @override
  String get trufiWebsite => 'Trufi Association Website';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get volunteerTrufi => 'Volunteer For Trufi';
}
