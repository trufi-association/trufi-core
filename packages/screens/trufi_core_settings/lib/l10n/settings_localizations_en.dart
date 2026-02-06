// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'settings_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SettingsLocalizationsEn extends SettingsLocalizations {
  SettingsLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get onboardingTitle => 'Welcome!';

  @override
  String get onboardingSubtitle => 'Let\'s set up your preferences';

  @override
  String get onboardingLanguageTitle => 'Choose your language';

  @override
  String get onboardingThemeTitle => 'Choose your theme';

  @override
  String get onboardingThemeLight => 'Light';

  @override
  String get onboardingThemeDark => 'Dark';

  @override
  String get onboardingThemeSystem => 'System';

  @override
  String get onboardingMapTitle => 'Choose your map style';

  @override
  String get onboardingRoutingTitle => 'Choose your routing engine';

  @override
  String get onboardingComplete => 'Get Started';

  @override
  String get privacyConsentTitle => 'Help Improve Trufi';

  @override
  String get privacyConsentSubtitle =>
      'Help us improve the app by sharing anonymous usage data';

  @override
  String get privacyConsentInfoTitle => 'What we collect';

  @override
  String get privacyConsentInfoLogs =>
      'Error logs to help us fix bugs and crashes';

  @override
  String get privacyConsentInfoRoutes =>
      'Route searches to improve transit data quality';

  @override
  String get privacyConsentInfoAnonymous => 'All data is completely anonymous';

  @override
  String get privacyConsentAccept => 'Accept & Continue';

  @override
  String get privacyConsentDecline => 'No Thanks';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsSelectLanguage => 'Select your preferred language:';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsSelectTheme => 'Select your preferred theme:';

  @override
  String get settingsThemeLight => 'Light Mode';

  @override
  String get settingsThemeDark => 'Dark Mode';

  @override
  String get settingsThemeSystem => 'System Default';

  @override
  String get settingsMap => 'Map';

  @override
  String get settingsSelectMapType => 'Select your preferred map type:';

  @override
  String get settingsRouting => 'Routing';

  @override
  String get settingsSelectRoutingEngine =>
      'Select your preferred routing engine:';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsPrivacySubtitle => 'Help improve the app';

  @override
  String get settingsPrivacyShareData => 'Share anonymous usage data';

  @override
  String get settingsPrivacyShareDataDescription =>
      'Help us fix bugs and improve transit data';

  @override
  String get engineOnlineName => 'Online';

  @override
  String get engineOnlineDescription =>
      'OpenTripPlanner 2.8. Real-time routing with detailed walking directions.';

  @override
  String get engineOfflineName => 'Offline';

  @override
  String get engineOfflineDescription =>
      'GTFS-based routing inspired by GuíaCochala. Works without internet.';

  @override
  String get limitationRequiresInternet => 'Requires internet';

  @override
  String get limitationSlower => 'Slower response';

  @override
  String get limitationNoWalkingRoute => 'No walking route on map';
}
