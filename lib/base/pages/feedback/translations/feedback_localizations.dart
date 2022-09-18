import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'feedback_localizations_am.dart';
import 'feedback_localizations_de.dart';
import 'feedback_localizations_en.dart';
import 'feedback_localizations_es.dart';
import 'feedback_localizations_fr.dart';
import 'feedback_localizations_it.dart';
import 'feedback_localizations_pt.dart';

/// Callers can lookup localized strings with an instance of FeedbackLocalization
/// returned by `FeedbackLocalization.of(context)`.
///
/// Applications need to include `FeedbackLocalization.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'translations/feedback_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: FeedbackLocalization.localizationsDelegates,
///   supportedLocales: FeedbackLocalization.supportedLocales,
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
/// be consistent with the languages listed in the FeedbackLocalization.supportedLocales
/// property.
abstract class FeedbackLocalization {
  FeedbackLocalization(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static FeedbackLocalization of(BuildContext context) {
    return Localizations.of<FeedbackLocalization>(context, FeedbackLocalization)!;
  }

  static const LocalizationsDelegate<FeedbackLocalization> delegate = _FeedbackLocalizationDelegate();

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
    Locale('am'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt')
  ];

  /// Menu item that shows the feedback page
  ///
  /// In am, this message translates to:
  /// **'ግብረ - መልስ ላክ'**
  String get menuFeedback;

  /// Title displayed on the feedback page
  ///
  /// In am, this message translates to:
  /// **'ኢሜል ይላኩልን'**
  String get feedbackTitle;

  /// Text displayed on the feedback page
  ///
  /// In am, this message translates to:
  /// **'ለመተግበሪያችን ጥቆማዎች አለዎት ወይም መተግበሪያ ውስጥ አንዳንድ ስህተቶች ከአገኙ? እኛ ከእርስዎ መስማት ደስ ይለናል! እኛ መልስ እንድንሰጥዎ የኢሜል አድራሻዎን ወይንም ስልክዎን ማከልዎን ያረጋግጡ ፡፡'**
  String get feedbackContent;
}

class _FeedbackLocalizationDelegate extends LocalizationsDelegate<FeedbackLocalization> {
  const _FeedbackLocalizationDelegate();

  @override
  Future<FeedbackLocalization> load(Locale locale) {
    return SynchronousFuture<FeedbackLocalization>(lookupFeedbackLocalization(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['am', 'de', 'en', 'es', 'fr', 'it', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_FeedbackLocalizationDelegate old) => false;
}

FeedbackLocalization lookupFeedbackLocalization(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am': return FeedbackLocalizationAm();
    case 'de': return FeedbackLocalizationDe();
    case 'en': return FeedbackLocalizationEn();
    case 'es': return FeedbackLocalizationEs();
    case 'fr': return FeedbackLocalizationFr();
    case 'it': return FeedbackLocalizationIt();
    case 'pt': return FeedbackLocalizationPt();
  }

  throw FlutterError(
    'FeedbackLocalization.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
