// In trufi_core package - trufi_localizations_config.dart
class TrufiLocalizationsConfig {
  const TrufiLocalizationsConfig({
    this.overrideDistanceMeters,
    this.overrideDistanceKm,
    this.overrideSelectedOnMap,
    this.overrideDefaultLocationHome,
    this.overrideDefaultLocationWork,
    this.overrideDefaultLocationAdd,
    this.overrideDefaultLocationSetLocation,
    this.overrideYourPlacesMenu,
    this.overrideFeedbackMenu,
    this.overrideFeedbackTitle,
    this.overrideFeedbackContent,
    this.overrideAboutUsMenu,
    this.overrideAboutUsVersion,
    this.overrideAboutUsLicenses,
    this.overrideAboutUsOpenSource,
  });
  final String Function(String distance, String defaultValue)?
  overrideDistanceMeters;
  final String Function(String distance, String defaultValue)?
  overrideDistanceKm;
  final String Function(String defaultValue)? overrideSelectedOnMap;
  final String Function(String defaultValue)? overrideDefaultLocationHome;
  final String Function(String defaultValue)? overrideDefaultLocationWork;
  final String Function(String location, String defaultValue)?
  overrideDefaultLocationAdd;
  final String Function(String defaultValue)?
  overrideDefaultLocationSetLocation;
  final String Function(String defaultValue)? overrideYourPlacesMenu;
  final String Function(String defaultValue)? overrideFeedbackMenu;
  final String Function(String defaultValue)? overrideFeedbackTitle;
  final String Function(String defaultValue)? overrideFeedbackContent;
  final String Function(String defaultValue)? overrideAboutUsMenu;
  final String Function(String version, String defaultValue)?
  overrideAboutUsVersion;
  final String Function(String defaultValue)? overrideAboutUsLicenses;
  final String Function(String defaultValue)? overrideAboutUsOpenSource;
}
