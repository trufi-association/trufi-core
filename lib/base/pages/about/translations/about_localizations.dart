import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'about_localizations_de.dart';
import 'about_localizations_en.dart';
import 'about_localizations_es.dart';
import 'about_localizations_fr.dart';
import 'about_localizations_it.dart';
import 'about_localizations_pt.dart';

/// Callers can lookup localized strings with an instance of AboutLocalization
/// returned by `AboutLocalization.of(context)`.
///
/// Applications need to include `AboutLocalization.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'translations/about_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AboutLocalization.localizationsDelegates,
///   supportedLocales: AboutLocalization.supportedLocales,
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
/// be consistent with the languages listed in the AboutLocalization.supportedLocales
/// property.
abstract class AboutLocalization {
  AboutLocalization(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AboutLocalization of(BuildContext context) {
    return Localizations.of<AboutLocalization>(context, AboutLocalization)!;
  }

  static const LocalizationsDelegate<AboutLocalization> delegate = _AboutLocalizationDelegate();

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

  /// A short marketing sentence that describes the app
  ///
  /// In pt, this message translates to:
  /// **'A Trufi Association é uma ONG internacional que promove acesso mais fácil ao transporte público. Nossos aplicativos ajudam as pessoas a encontrar a melhor maneira de ir do ponto A ao ponto B dentro de suas cidades.\n\nEm muitas cidades não há mapas, rotas, aplicativos ou horários oficiais. Por isso, compilamos as informações disponíveis e, às vezes, também mapeamos rotas do zero, trabalhando com pessoas locais que conhecem a cidade. Um sistema de transporte fácil de usar contribui para maior sustentabilidade, ar mais limpo e melhor qualidade de vida.'**
  String get aboutCollapseContent;

  /// No description provided for @aboutCollapseContentFoot.
  ///
  /// In pt, this message translates to:
  /// **'Torne-se parte dos nosso time de voluntários! Nós precisamos de pessoas para fazer o mapeamento, de desenvolvedores, de planejadores, pessoas que nos ajudem a fazer testes e outras muitas mãos!'**
  String get aboutCollapseContentFoot;

  /// No description provided for @aboutCollapseTitle.
  ///
  /// In pt, this message translates to:
  /// **'Mais sobre a Trufi Association'**
  String get aboutCollapseTitle;

  /// Text displayed on the about page
  ///
  /// In pt, this message translates to:
  /// **'Precisa ir a algum lugar e não sabe qual trufi ou ônibus pegar?\nO aplicativo Trufi facilita isso!\nA Trufi Association é uma equipe da Bolívia e de outros países. Adoramos La Llajta e o transporte público, por isso desenvolvemos este aplicativo para facilitar o transporte. Nosso objetivo é fornecer uma ferramenta prática que lhe permita navegar com confiança.\nEstamos comprometidos com a melhoria contínua do {appName} para oferecer a você informações cada vez mais precisas e úteis. Sabemos que o sistema de transporte em {city} passa por mudanças devido a diferentes motivos, portanto, é possível que algumas rotas não estejam completamente atualizadas.\nPara tornar o {appName} uma ferramenta eficaz, contamos com a colaboração de nossos usuários. Se tiver conhecimento de alterações em algumas rotas ou paradas, recomendamos que compartilhe essas informações conosco. Sua contribuição não apenas ajudará a manter o aplicativo atualizado, mas também beneficiará outros usuários que dependem do {appName}.\nObrigado por escolher o {appName} para se locomover em {city}, esperamos que aproveite sua experiência conosco!'**
  String aboutContent(Object appName, Object city);

  /// Button label to show licenses
  ///
  /// In pt, this message translates to:
  /// **'Licenças'**
  String get aboutLicenses;

  /// A note about open source
  ///
  /// In pt, this message translates to:
  /// **'Este aplicativo é lançado como código aberto no GitHub. Sinta-se à vontade para contribuir com o código ou trazer um aplicativo para sua própria cidade.'**
  String get aboutOpenSource;

  /// Menu item that shows the about page
  ///
  /// In pt, this message translates to:
  /// **'Sobre Nós'**
  String get menuAbout;

  /// A short marketing sentence that describes the app
  ///
  /// In pt, this message translates to:
  /// **'Transporte público em {city}'**
  String tagline(Object city);

  /// No description provided for @trufiWebsite.
  ///
  /// In pt, this message translates to:
  /// **'Website da Trufi Association'**
  String get trufiWebsite;

  /// The application's version
  ///
  /// In pt, this message translates to:
  /// **'Versão {version}'**
  String version(Object version);

  /// No description provided for @volunteerTrufi.
  ///
  /// In pt, this message translates to:
  /// **'Torne-se um voluntário da Trufi'**
  String get volunteerTrufi;
}

class _AboutLocalizationDelegate extends LocalizationsDelegate<AboutLocalization> {
  const _AboutLocalizationDelegate();

  @override
  Future<AboutLocalization> load(Locale locale) {
    return SynchronousFuture<AboutLocalization>(lookupAboutLocalization(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'fr', 'it', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AboutLocalizationDelegate old) => false;
}

AboutLocalization lookupAboutLocalization(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AboutLocalizationDe();
    case 'en': return AboutLocalizationEn();
    case 'es': return AboutLocalizationEs();
    case 'fr': return AboutLocalizationFr();
    case 'it': return AboutLocalizationIt();
    case 'pt': return AboutLocalizationPt();
  }

  throw FlutterError(
    'AboutLocalization.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
