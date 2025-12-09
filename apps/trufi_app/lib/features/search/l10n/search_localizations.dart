import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'search_localizations_de.dart';
import 'search_localizations_en.dart';
import 'search_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of SearchLocalizations
/// returned by `SearchLocalizations.of(context)`.
///
/// Applications need to include `SearchLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/search_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: SearchLocalizations.localizationsDelegates,
///   supportedLocales: SearchLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the SearchLocalizations.supportedLocales
/// property.
abstract class SearchLocalizations {
  SearchLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static SearchLocalizations of(BuildContext context) {
    return Localizations.of<SearchLocalizations>(context, SearchLocalizations)!;
  }

  static const LocalizationsDelegate<SearchLocalizations> delegate = _SearchLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es')
  ];

  /// Search screen title
  ///
  /// In en, this message translates to:
  /// **'Search Location'**
  String get searchTitle;

  /// Origin field label
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get searchOrigin;

  /// Destination field label
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get searchDestination;

  /// My location button
  ///
  /// In en, this message translates to:
  /// **'My Location'**
  String get searchMyLocation;

  /// Choose on map button
  ///
  /// In en, this message translates to:
  /// **'Choose on map'**
  String get searchChooseOnMap;

  /// Swap origin/destination button
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get searchSwap;

  /// No search results message
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get searchNoResults;

  /// Searching indicator
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searchSearching;
}

class _SearchLocalizationsDelegate extends LocalizationsDelegate<SearchLocalizations> {
  const _SearchLocalizationsDelegate();

  @override
  Future<SearchLocalizations> load(Locale locale) {
    return SynchronousFuture<SearchLocalizations>(lookupSearchLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_SearchLocalizationsDelegate old) => false;
}

SearchLocalizations lookupSearchLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return SearchLocalizationsDe();
    case 'en': return SearchLocalizationsEn();
    case 'es': return SearchLocalizationsEs();
  }

  throw FlutterError(
    'SearchLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
