import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'maps_localizations_de.dart';
import 'maps_localizations_en.dart';
import 'maps_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of MapsLocalizations
/// returned by `MapsLocalizations.of(context)`.
///
/// Applications need to include `MapsLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/maps_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: MapsLocalizations.localizationsDelegates,
///   supportedLocales: MapsLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the MapsLocalizations.supportedLocales
/// property.
abstract class MapsLocalizations {
  MapsLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static MapsLocalizations of(BuildContext context) {
    return Localizations.of<MapsLocalizations>(context, MapsLocalizations)!;
  }

  static const LocalizationsDelegate<MapsLocalizations> delegate =
      _MapsLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
  ];

  /// Label for the online maps segment in the online/offline toggle
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// Label for the offline maps segment in the online/offline toggle
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// Default title for the map type settings screen header
  ///
  /// In en, this message translates to:
  /// **'Map Settings'**
  String get mapSettings;

  /// Default section title above the map type list
  ///
  /// In en, this message translates to:
  /// **'Map Type'**
  String get mapType;

  /// Subtitle under the map type section title
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred map style'**
  String get chooseMapStyle;

  /// Default tooltip for the map type button
  ///
  /// In en, this message translates to:
  /// **'Change map type'**
  String get changeMapType;

  /// Default title for the choose-on-map screen
  ///
  /// In en, this message translates to:
  /// **'Choose on Map'**
  String get chooseOnMap;

  /// Default label for the confirm button on the choose-on-map screen
  ///
  /// In en, this message translates to:
  /// **'Confirm Location'**
  String get confirmLocation;

  /// Default display name for the offline map engine
  ///
  /// In en, this message translates to:
  /// **'Offline Map'**
  String get offlineMapName;

  /// Default description for the offline map engine
  ///
  /// In en, this message translates to:
  /// **'Fully offline map'**
  String get offlineMapDescription;

  /// Error title shown when the offline map fails to load
  ///
  /// In en, this message translates to:
  /// **'Error loading offline map'**
  String get errorLoadingOfflineMap;

  /// Label for the retry button after an offline map load failure
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Default description for the MapLibre vector map engine
  ///
  /// In en, this message translates to:
  /// **'Vector map with modern styling and better performance'**
  String get vectorMapDescription;

  /// Description for the default light (Liberty) map style
  ///
  /// In en, this message translates to:
  /// **'Light vector map'**
  String get lightVectorMapDescription;

  /// Description for the default dark map style
  ///
  /// In en, this message translates to:
  /// **'Dark vector map'**
  String get darkVectorMapDescription;

  /// Description for a map style in the map type selector
  ///
  /// In en, this message translates to:
  /// **'Standard map'**
  String get mapStyleStandardDescription;

  /// Description for a map style in the map type selector
  ///
  /// In en, this message translates to:
  /// **'Light map'**
  String get mapStyleLightDescription;

  /// Description for a map style in the map type selector
  ///
  /// In en, this message translates to:
  /// **'Dark map'**
  String get mapStyleDarkDescription;

  /// Description for a map style in the map type selector
  ///
  /// In en, this message translates to:
  /// **'Colorful map'**
  String get mapStyleColorfulDescription;
}

class _MapsLocalizationsDelegate
    extends LocalizationsDelegate<MapsLocalizations> {
  const _MapsLocalizationsDelegate();

  @override
  Future<MapsLocalizations> load(Locale locale) {
    return SynchronousFuture<MapsLocalizations>(
      lookupMapsLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_MapsLocalizationsDelegate old) => false;
}

MapsLocalizations lookupMapsLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return MapsLocalizationsDe();
    case 'en':
      return MapsLocalizationsEn();
    case 'es':
      return MapsLocalizationsEs();
  }

  throw FlutterError(
    'MapsLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
