// In trufi_core package - trufi_localizations.dart
import 'package:tr_translations/l10n/app_localizations.dart';
import 'package:tr_translations/trufi_localizations_config.dart'; // Your generated file

class TrufiLocalizations {
  TrufiLocalizations(this._appLocalizations, [this._config]);
  final AppLocalizations _appLocalizations;
  final TrufiLocalizationsConfig? _config;

  String get localeName => _appLocalizations.localeName;

  String instructionDistanceMeters(String distance) {
    final defaultValue = _appLocalizations.instruction_distance_meters(
      distance,
    );
    return _config?.overrideDistanceMeters?.call(distance, defaultValue) ??
        defaultValue;
  }

  String instructionDistanceKm(String distance) {
    final defaultValue = _appLocalizations.instruction_distance_km(distance);
    return _config?.overrideDistanceKm?.call(distance, defaultValue) ??
        defaultValue;
  }

  String get selectedOnMap {
    final defaultValue = _appLocalizations.selected_on_map;
    return _config?.overrideSelectedOnMap?.call(defaultValue) ?? defaultValue;
  }

  String get defaultLocationHome {
    final defaultValue = _appLocalizations.default_location_home;
    return _config?.overrideDefaultLocationHome?.call(defaultValue) ??
        defaultValue;
  }

  String get defaultLocationWork {
    final defaultValue = _appLocalizations.default_location_work;
    return _config?.overrideDefaultLocationWork?.call(defaultValue) ??
        defaultValue;
  }

  String defaultLocationAdd(String location) {
    final defaultValue = _appLocalizations.default_location_add(location);
    return _config?.overrideDefaultLocationAdd?.call(location, defaultValue) ??
        defaultValue;
  }

  String get defaultLocationSetLocation {
    final defaultValue = _appLocalizations.default_location_setLocation;
    return _config?.overrideDefaultLocationSetLocation?.call(defaultValue) ??
        defaultValue;
  }

  String get yourPlacesMenu {
    final defaultValue = _appLocalizations.yourPlaces_menu;
    return _config?.overrideYourPlacesMenu?.call(defaultValue) ?? defaultValue;
  }

  String get feedbackMenu {
    final defaultValue = _appLocalizations.feedback_menu;
    return _config?.overrideFeedbackMenu?.call(defaultValue) ?? defaultValue;
  }

  String get feedbackTitle {
    final defaultValue = _appLocalizations.feedback_title;
    return _config?.overrideFeedbackTitle?.call(defaultValue) ?? defaultValue;
  }

  String get feedbackContent {
    final defaultValue = _appLocalizations.feedback_content;
    return _config?.overrideFeedbackContent?.call(defaultValue) ?? defaultValue;
  }

  String get aboutUsMenu {
    final defaultValue = _appLocalizations.aboutUs_menu;
    return _config?.overrideAboutUsMenu?.call(defaultValue) ?? defaultValue;
  }

  String aboutUsVersion(String version) {
    final defaultValue = _appLocalizations.aboutUs_version(version);
    return _config?.overrideAboutUsVersion?.call(version, defaultValue) ??
        defaultValue;
  }

  String get aboutUsLicenses {
    final defaultValue = _appLocalizations.aboutUs_licenses;
    return _config?.overrideAboutUsLicenses?.call(defaultValue) ?? defaultValue;
  }

  String get aboutUsOpenSource {
    final defaultValue = _appLocalizations.aboutUs_openSource;
    return _config?.overrideAboutUsOpenSource?.call(defaultValue) ??
        defaultValue;
  }
}
