import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:trufi_core/localization/app_localization_delegate.dart';

enum LocalizationKey {
  instructionDistanceMeters,
  instructionDistanceKm,
  selectedOnMap,
  defaultLocationHome,
  defaultLocationWork,
  defaultLocationAdd,
  defaultLocationSetLocation,
  // Your Places page
  yourPlacesMenu,

  // Feedback page
  feedbackMenu,
  feedbackTitle,
  feedbackContent,
  // About Us page
  aboutUsMenu,
  aboutUsVersion,
  aboutUsLicenses,
  aboutUsOpenSource,
}

extension LocalizationKeyExtension on LocalizationKey {
  static final _valueMap = {
    'instruction.distance.meters': LocalizationKey.instructionDistanceMeters,
    'instruction.distance.km': LocalizationKey.instructionDistanceKm,
    'selected_on_map': LocalizationKey.selectedOnMap,
    'default_location_home': LocalizationKey.defaultLocationHome,
    'default_location_work': LocalizationKey.defaultLocationWork,
    'default_location_add': LocalizationKey.defaultLocationAdd,
    'default_location_setLocation': LocalizationKey.defaultLocationSetLocation,
    // Your Places page
    'yourPlaces.menu': LocalizationKey.yourPlacesMenu,
    // Feedback page
    'feedback.menu': LocalizationKey.feedbackMenu,
    'feedback.title': LocalizationKey.feedbackTitle,
    'feedback.content': LocalizationKey.feedbackContent,
    // About Us page
    'aboutUs.menu': LocalizationKey.aboutUsMenu,
    'aboutUs.version': LocalizationKey.aboutUsVersion,
    'aboutUs.licenses': LocalizationKey.aboutUsLicenses,
    'aboutUs.openSource': LocalizationKey.aboutUsOpenSource,
  };

  String get key =>
      _valueMap.entries.firstWhere((entry) => entry.value == this).key;

  static LocalizationKey? fromValue(String value) => _valueMap[value];
}

class AppLocalization {
  AppLocalization(this.locale);

  static const textError = 'Translate Error';
  static const textNoTranslation = 'No translation available';
  final Locale locale;

  static AppLocalization of(BuildContext context) =>
      Localizations.of<AppLocalization>(context, AppLocalization)!;

  static Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    const AppLocalizationDelegate(),
  ];

  late Map<String, String?> _localizedValues;

  Future<void> loadLanguage() async {
    try {
      final content = <String, dynamic>{
        'instruction.distance.meters': '\$1 m',
        'instruction.distance.km': '\$1 km',
        'selected_on_map': 'Selected on the map',
        'default_location_home': 'Home',
        'default_location_work': 'Work',
        'default_location_add': 'Set \$1 location',
        'default_location_setLocation': 'Set location',
        // Your Places page
        'yourPlaces.menu': 'Your Places',
        // Feedback page
        'feedback.menu': 'Send Feedback',
        'feedback.title': 'Please e-mail us',
        'feedback.content':
            'Do you have suggestions for our app or found some errors in the data? We would love to hear from you! Please make sure to add your email address or telephone, so we can respond to you.',
        // About Us page
        'aboutUs.menu': 'About this service',
        'aboutUs.version': 'Version \$1',
        'aboutUs.licenses': 'Licenses',
        'aboutUs.openSource':
            'This app is released as open source on GitHub. Feel free to contribute to the code, or bring an app to your own city.',
      };
      _localizedValues = content.map((key, value) {
        final valueString = value.toString().trim();
        return MapEntry(key, valueString.isEmpty ? key : valueString);
      });
    } catch (_) {
      _localizedValues = {};
    }
  }

  String translateWithParams(String localizationKey) {
    final errorCodeSplit = localizationKey.split(':');
    final errorCodeKey = errorCodeSplit.first;
    final params = errorCodeSplit.last.split(',');
    final translated = _localizedValues[errorCodeKey] ?? localizationKey;
    var response = translated;
    for (var i = 0; i < params.length; i++) {
      response = response.replaceAll('\$${i + 1}', params[i]);
    }
    return response;
  }

  String translate(LocalizationKey? localizationKey) {
    if (localizationKey == null) return '';
    return _localizedValues[localizationKey.key] ?? localizationKey.key;
  }

  String? translateOrNull(LocalizationKey? localizationKey) {
    if (localizationKey == null) return null;
    final value = _localizedValues[localizationKey.key];
    if (localizationKey.key == value) return null;
    return (value?.isEmpty ?? true) ? null : value;
  }

  String translateWithKey(String localizationKey) =>
      _localizedValues[localizationKey] ?? localizationKey;
}
