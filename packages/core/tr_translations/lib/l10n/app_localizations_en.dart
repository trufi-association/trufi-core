// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String instruction_distance_meters(String distance) {
    return '$distance m';
  }

  @override
  String instruction_distance_km(String distance) {
    return '$distance km';
  }

  @override
  String get selected_on_map => 'Selected on the map';

  @override
  String get default_location_home => 'Home';

  @override
  String get default_location_work => 'Work';

  @override
  String default_location_add(String location) {
    return 'Set $location location';
  }

  @override
  String get default_location_setLocation => 'Set location';

  @override
  String get yourPlaces_menu => 'Your Places';

  @override
  String get feedback_menu => 'Send Feedback';

  @override
  String get feedback_title => 'Please e-mail us';

  @override
  String get feedback_content =>
      'Do you have suggestions for our app or found some errors in the data? We would love to hear from you! Please make sure to add your email address or telephone, so we can respond to you.';

  @override
  String get aboutUs_menu => 'About this service';

  @override
  String aboutUs_version(String version) {
    return 'Version $version';
  }

  @override
  String get aboutUs_licenses => 'Licenses';

  @override
  String get aboutUs_openSource =>
      'This app is released as open source on GitHub. Feel free to contribute to the code, or bring an app to your own city.';
}
