
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'saved_places_localizations_de.dart';
import 'saved_places_localizations_en.dart';
import 'saved_places_localizations_es.dart';
import 'saved_places_localizations_fr.dart';
import 'saved_places_localizations_it.dart';
import 'saved_places_localizations_pt.dart';

/// Callers can lookup localized strings with an instance of SavedPlacesLocalization returned
/// by `SavedPlacesLocalization.of(context)`.
///
/// Applications need to include `SavedPlacesLocalization.delegate()` in their app's
/// localizationDelegates list, and the locales they support in the app's
/// supportedLocales list. For example:
///
/// ```
/// import 'translations/saved_places_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: SavedPlacesLocalization.localizationsDelegates,
///   supportedLocales: SavedPlacesLocalization.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # rest of dependencies
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
/// be consistent with the languages listed in the SavedPlacesLocalization.supportedLocales
/// property.
abstract class SavedPlacesLocalization {
  SavedPlacesLocalization(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static SavedPlacesLocalization of(BuildContext context) {
    return Localizations.of<SavedPlacesLocalization>(context, SavedPlacesLocalization)!;
  }

  static const LocalizationsDelegate<SavedPlacesLocalization> delegate = _SavedPlacesLocalizationDelegate();

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
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt')
  ];

  /// No description provided for @chooseNowLabel.
  ///
  /// In pt, this message translates to:
  /// **'Choose now'**
  String get chooseNowLabel;

  /// Search option that allows to choose a point on the map
  ///
  /// In pt, this message translates to:
  /// **'Choose on map'**
  String get chooseOnMap;

  /// General CustomPlaces label
  ///
  /// In pt, this message translates to:
  /// **'Custom places'**
  String get commonCustomPlaces;

  /// General Favorite places label
  ///
  /// In pt, this message translates to:
  /// **'Favorite places'**
  String get commonFavoritePlaces;

  /// The name Add for {defaultLocation}
  ///
  /// In pt, this message translates to:
  /// **'Versão {defaultLocation}'**
  String defaultLocationAdd(Object defaultLocation);

  /// The default location name Home
  ///
  /// In pt, this message translates to:
  /// **'Home'**
  String get defaultLocationHome;

  /// The default location name Work
  ///
  /// In pt, this message translates to:
  /// **'Work'**
  String get defaultLocationWork;

  /// No description provided for @iconlabel.
  ///
  /// In pt, this message translates to:
  /// **'Icon'**
  String get iconlabel;

  /// Junction name of two streets
  ///
  /// In pt, this message translates to:
  /// **'Esvaziar'**
  String instructionJunction(Object street1, Object street2);

  /// A menu item that shows the saved places
  ///
  /// In pt, this message translates to:
  /// **'Your places'**
  String get menuYourPlaces;

  /// No description provided for @nameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @savedPlacesEditLabel.
  ///
  /// In pt, this message translates to:
  /// **'Edit place'**
  String get savedPlacesEditLabel;

  /// No description provided for @savedPlacesEnterNameTitle.
  ///
  /// In pt, this message translates to:
  /// **'Enter name'**
  String get savedPlacesEnterNameTitle;

  /// No description provided for @savedPlacesEnterNameValidation.
  ///
  /// In pt, this message translates to:
  /// **'The name cannot be empty'**
  String get savedPlacesEnterNameValidation;

  /// No description provided for @savedPlacesRemoveLabel.
  ///
  /// In pt, this message translates to:
  /// **'Remove place'**
  String get savedPlacesRemoveLabel;

  /// No description provided for @savedPlacesSelectIconTitle.
  ///
  /// In pt, this message translates to:
  /// **'Select symbol'**
  String get savedPlacesSelectIconTitle;

  /// No description provided for @savedPlacesSetIconLabel.
  ///
  /// In pt, this message translates to:
  /// **'Change symbol'**
  String get savedPlacesSetIconLabel;

  /// No description provided for @savedPlacesSetNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Edit name'**
  String get savedPlacesSetNameLabel;

  /// No description provided for @savedPlacesSetPositionLabel.
  ///
  /// In pt, this message translates to:
  /// **'Edit position'**
  String get savedPlacesSetPositionLabel;

  /// Search section title for locations marked as favorites
  ///
  /// In pt, this message translates to:
  /// **'Favoritas'**
  String get searchTitleFavorites;

  /// Search section title for recent location
  ///
  /// In pt, this message translates to:
  /// **'Recente'**
  String get searchTitleRecent;

  /// Search section title for results found for the provided search term
  ///
  /// In pt, this message translates to:
  /// **'Procurar Resultados'**
  String get searchTitleResults;

  /// No description provided for @selectedOnMap.
  ///
  /// In pt, this message translates to:
  /// **'Selected on the map'**
  String get selectedOnMap;
}

class _SavedPlacesLocalizationDelegate extends LocalizationsDelegate<SavedPlacesLocalization> {
  const _SavedPlacesLocalizationDelegate();

  @override
  Future<SavedPlacesLocalization> load(Locale locale) {
    return SynchronousFuture<SavedPlacesLocalization>(lookupSavedPlacesLocalization(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'fr', 'it', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_SavedPlacesLocalizationDelegate old) => false;
}

SavedPlacesLocalization lookupSavedPlacesLocalization(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return SavedPlacesLocalizationDe();
    case 'en': return SavedPlacesLocalizationEn();
    case 'es': return SavedPlacesLocalizationEs();
    case 'fr': return SavedPlacesLocalizationFr();
    case 'it': return SavedPlacesLocalizationIt();
    case 'pt': return SavedPlacesLocalizationPt();
  }

  throw FlutterError(
    'SavedPlacesLocalization.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
