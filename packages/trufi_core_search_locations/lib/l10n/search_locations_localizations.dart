import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'search_locations_localizations_de.dart';
import 'search_locations_localizations_en.dart';
import 'search_locations_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of SearchLocationsLocalizations
/// returned by `SearchLocationsLocalizations.of(context)`.
///
/// Applications need to include `SearchLocationsLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/search_locations_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: SearchLocationsLocalizations.localizationsDelegates,
///   supportedLocales: SearchLocationsLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the SearchLocationsLocalizations.supportedLocales
/// property.
abstract class SearchLocationsLocalizations {
  SearchLocationsLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static SearchLocationsLocalizations of(BuildContext context) {
    return Localizations.of<SearchLocationsLocalizations>(
      context,
      SearchLocationsLocalizations,
    )!;
  }

  static const LocalizationsDelegate<SearchLocationsLocalizations> delegate =
      _SearchLocationsLocalizationsDelegate();

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

  /// Default hint text for the origin field in the search location bar
  ///
  /// In en, this message translates to:
  /// **'Select origin'**
  String get selectOrigin;

  /// Default hint text for the destination field in the search location bar
  ///
  /// In en, this message translates to:
  /// **'Select destination'**
  String get selectDestination;

  /// Default hint text for the origin search field on the location search screen
  ///
  /// In en, this message translates to:
  /// **'Search origin...'**
  String get searchOrigin;

  /// Default hint text for the destination search field on the location search screen
  ///
  /// In en, this message translates to:
  /// **'Search destination...'**
  String get searchDestination;

  /// Label for the quick action that uses the device's current location
  ///
  /// In en, this message translates to:
  /// **'Your Location'**
  String get yourLocation;

  /// Label for the quick action that opens the map picker
  ///
  /// In en, this message translates to:
  /// **'Choose on Map'**
  String get chooseOnMap;

  /// Uppercase section title above the saved places list
  ///
  /// In en, this message translates to:
  /// **'YOUR PLACES'**
  String get yourPlaces;

  /// Uppercase section title above the search results list
  ///
  /// In en, this message translates to:
  /// **'SEARCH RESULTS'**
  String get searchResults;

  /// Message shown when a search returns no results
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// Section title while picking one corner of a street in the drill-down flow. {street} is the street name.
  ///
  /// In en, this message translates to:
  /// **'Corners of {street}'**
  String cornersOf(String street);

  /// Tooltip/semantics of the trailing button on a street result that opens its corners list
  ///
  /// In en, this message translates to:
  /// **'See corners'**
  String get seeCorners;
}

class _SearchLocationsLocalizationsDelegate
    extends LocalizationsDelegate<SearchLocationsLocalizations> {
  const _SearchLocationsLocalizationsDelegate();

  @override
  Future<SearchLocationsLocalizations> load(Locale locale) {
    return SynchronousFuture<SearchLocationsLocalizations>(
      lookupSearchLocationsLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_SearchLocationsLocalizationsDelegate old) => false;
}

SearchLocationsLocalizations lookupSearchLocationsLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return SearchLocationsLocalizationsDe();
    case 'en':
      return SearchLocationsLocalizationsEn();
    case 'es':
      return SearchLocationsLocalizationsEs();
  }

  throw FlutterError(
    'SearchLocationsLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
