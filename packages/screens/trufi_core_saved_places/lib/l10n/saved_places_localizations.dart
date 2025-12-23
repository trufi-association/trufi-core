import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'saved_places_localizations_de.dart';
import 'saved_places_localizations_en.dart';
import 'saved_places_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of SavedPlacesLocalizations
/// returned by `SavedPlacesLocalizations.of(context)`.
///
/// Applications need to include `SavedPlacesLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/saved_places_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: SavedPlacesLocalizations.localizationsDelegates,
///   supportedLocales: SavedPlacesLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the SavedPlacesLocalizations.supportedLocales
/// property.
abstract class SavedPlacesLocalizations {
  SavedPlacesLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static SavedPlacesLocalizations of(BuildContext context) {
    return Localizations.of<SavedPlacesLocalizations>(
      context,
      SavedPlacesLocalizations,
    )!;
  }

  static const LocalizationsDelegate<SavedPlacesLocalizations> delegate =
      _SavedPlacesLocalizationsDelegate();

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

  /// No description provided for @menuSavedPlaces.
  ///
  /// In en, this message translates to:
  /// **'Your Places'**
  String get menuSavedPlaces;

  /// No description provided for @yourPlaces.
  ///
  /// In en, this message translates to:
  /// **'Your Places'**
  String get yourPlaces;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @work.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get work;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @customPlaces.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get customPlaces;

  /// No description provided for @recentPlaces.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recentPlaces;

  /// No description provided for @defaultPlaces.
  ///
  /// In en, this message translates to:
  /// **'Default Places'**
  String get defaultPlaces;

  /// No description provided for @setHome.
  ///
  /// In en, this message translates to:
  /// **'Set home address'**
  String get setHome;

  /// No description provided for @setWork.
  ///
  /// In en, this message translates to:
  /// **'Set work address'**
  String get setWork;

  /// No description provided for @editPlace.
  ///
  /// In en, this message translates to:
  /// **'Edit place'**
  String get editPlace;

  /// No description provided for @removePlace.
  ///
  /// In en, this message translates to:
  /// **'Remove place'**
  String get removePlace;

  /// No description provided for @removePlaceConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this place?'**
  String get removePlaceConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get enterName;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @selectIcon.
  ///
  /// In en, this message translates to:
  /// **'Select Icon'**
  String get selectIcon;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearHistory;

  /// No description provided for @noPlacesSaved.
  ///
  /// In en, this message translates to:
  /// **'No places saved yet'**
  String get noPlacesSaved;

  /// No description provided for @addPlace.
  ///
  /// In en, this message translates to:
  /// **'Add Place'**
  String get addPlace;

  /// No description provided for @chooseOnMap.
  ///
  /// In en, this message translates to:
  /// **'Choose on map'**
  String get chooseOnMap;

  /// No description provided for @searchLocation.
  ///
  /// In en, this message translates to:
  /// **'Search location'**
  String get searchLocation;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @noLocationSelected.
  ///
  /// In en, this message translates to:
  /// **'No location selected'**
  String get noLocationSelected;

  /// No description provided for @locationRequired.
  ///
  /// In en, this message translates to:
  /// **'Location is required'**
  String get locationRequired;

  /// No description provided for @locationSelected.
  ///
  /// In en, this message translates to:
  /// **'Location selected'**
  String get locationSelected;

  /// No description provided for @tapToSelectLocation.
  ///
  /// In en, this message translates to:
  /// **'Tap to select on map'**
  String get tapToSelectLocation;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;
}

class _SavedPlacesLocalizationsDelegate
    extends LocalizationsDelegate<SavedPlacesLocalizations> {
  const _SavedPlacesLocalizationsDelegate();

  @override
  Future<SavedPlacesLocalizations> load(Locale locale) {
    return SynchronousFuture<SavedPlacesLocalizations>(
      lookupSavedPlacesLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_SavedPlacesLocalizationsDelegate old) => false;
}

SavedPlacesLocalizations lookupSavedPlacesLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return SavedPlacesLocalizationsDe();
    case 'en':
      return SavedPlacesLocalizationsEn();
    case 'es':
      return SavedPlacesLocalizationsEs();
  }

  throw FlutterError(
    'SavedPlacesLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
