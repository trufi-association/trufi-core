import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'trufi_base_localizations_de.dart';
import 'trufi_base_localizations_en.dart';
import 'trufi_base_localizations_es.dart';
import 'trufi_base_localizations_fr.dart';
import 'trufi_base_localizations_it.dart';
import 'trufi_base_localizations_pt.dart';

/// Callers can lookup localized strings with an instance of TrufiBaseLocalization
/// returned by `TrufiBaseLocalization.of(context)`.
///
/// Applications need to include `TrufiBaseLocalization.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'translations/trufi_base_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: TrufiBaseLocalization.localizationsDelegates,
///   supportedLocales: TrufiBaseLocalization.supportedLocales,
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
/// be consistent with the languages listed in the TrufiBaseLocalization.supportedLocales
/// property.
abstract class TrufiBaseLocalization {
  TrufiBaseLocalization(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static TrufiBaseLocalization of(BuildContext context) {
    return Localizations.of<TrufiBaseLocalization>(context, TrufiBaseLocalization)!;
  }

  static const LocalizationsDelegate<TrufiBaseLocalization> delegate = _TrufiBaseLocalizationDelegate();

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

  /// Text of dialog that explains that access to location services was denied
  ///
  /// In pt, this message translates to:
  /// **'Certifique-se de que seu dispositivo tenha GPS e que as configurações de localização estejam ativadas.'**
  String get alertLocationServicesDeniedMessage;

  /// Title of dialog that explains that access to location services was denied
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma localização'**
  String get alertLocationServicesDeniedTitle;

  /// Accept button of the App Review Dialog used on Android
  ///
  /// In pt, this message translates to:
  /// **'Escrever avaliação'**
  String get appReviewDialogButtonAccept;

  /// Decline button of the App Review Dialog used on Android
  ///
  /// In pt, this message translates to:
  /// **'Agora não'**
  String get appReviewDialogButtonDecline;

  /// Content of the App Review Dialog used on Android
  ///
  /// In pt, this message translates to:
  /// **'Apoie-nos com uma análise na Loja do Google Play.'**
  String get appReviewDialogContent;

  /// Title of the App Review Dialog used on Android
  ///
  /// In pt, this message translates to:
  /// **'Gostando da Trufi?'**
  String get appReviewDialogTitle;

  /// Page subtitle when choosing a location on the map
  ///
  /// In pt, this message translates to:
  /// **'Amplia e move o mapa para centralizar o marcador'**
  String get chooseLocationPageSubtitle;

  /// Page title when choosing a location on the map
  ///
  /// In pt, this message translates to:
  /// **'Escolha um ponto no mapa'**
  String get chooseLocationPageTitle;

  /// Cancel button label
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// General Confirm location label
  ///
  /// In pt, this message translates to:
  /// **'Confirmar localização'**
  String get commonConfirmLocation;

  /// Destination field label
  ///
  /// In pt, this message translates to:
  /// **'Endereço de destino'**
  String get commonDestination;

  /// General Edit label
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get commonEdit;

  /// Message when an error has occured
  ///
  /// In pt, this message translates to:
  /// **'Erro'**
  String get commonError;

  /// General from station  label
  ///
  /// In pt, this message translates to:
  /// **'Da estação'**
  String get commonFromStation;

  /// General from stop  label
  ///
  /// In pt, this message translates to:
  /// **'Da parada'**
  String get commonFromStop;

  /// General Leave when it suits you label
  ///
  /// In pt, this message translates to:
  /// **'Saia quando for melhor para você'**
  String get commonItineraryNoTransitLegs;

  /// General Leaves at  label
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get commonLeavesAt;

  /// General Loading label
  ///
  /// In pt, this message translates to:
  /// **'Carregando...'**
  String get commonLoading;

  /// Message when internet connection is lost
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão de internet'**
  String get commonNoInternet;

  /// Message that is displayed when no results were found for the search term that was provided
  ///
  /// In pt, this message translates to:
  /// **'Sem resultados'**
  String get commonNoResults;

  /// OK button label
  ///
  /// In pt, this message translates to:
  /// **'OK'**
  String get commonOK;

  /// Origin field label
  ///
  /// In pt, this message translates to:
  /// **'Origem'**
  String get commonOrigin;

  /// General Remove label
  ///
  /// In pt, this message translates to:
  /// **'Remover'**
  String get commonRemove;

  /// General Save label
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get commonSave;

  /// General Tomorrow label
  ///
  /// In pt, this message translates to:
  /// **'Amanhã'**
  String get commonTomorrow;

  /// Message when an unknown error has occured
  ///
  /// In pt, this message translates to:
  /// **'Erro desconhecido'**
  String get commonUnknownError;

  /// General Unkown place label
  ///
  /// In pt, this message translates to:
  /// **'Local desconhecido'**
  String get commonUnkownPlace;

  /// General wait label
  ///
  /// In pt, this message translates to:
  /// **'Aguarde'**
  String get commonWait;

  /// General Walk label
  ///
  /// In pt, this message translates to:
  /// **'Caminhe'**
  String get commonWalk;

  /// Search option that allows to use the current user location
  ///
  /// In pt, this message translates to:
  /// **'Sua localização'**
  String get commonYourLocation;

  /// Message that is displayed when a trip could not be planned, because the specified destination is ambiguous
  ///
  /// In pt, this message translates to:
  /// **'O planejador de viagens não tem certeza do local para o qual deseja ir. Selecione uma das opções a seguir ou seja mais específico.'**
  String get errorAmbiguousDestination;

  /// Message that is displayed when a trip could not be planned, because the specified origin is ambiguous
  ///
  /// In pt, this message translates to:
  /// **'O planejador de viagens não tem certeza do local de onde você deseja começar sua viagem. Selecione uma das opções a seguir ou seja mais específico.'**
  String get errorAmbiguousOrigin;

  /// Message that is displayed when a trip could not be planned, because the specified origin and destination are ambiguous
  ///
  /// In pt, this message translates to:
  /// **'Tanto a origem quanto o destino são ambíguos. Selecione entre as seguintes opções ou seja mais específico.'**
  String get errorAmbiguousOriginDestination;

  /// Message that is displayed when a trip could not be planned, because both origin and destination are not wheelchair accessible
  ///
  /// In pt, this message translates to:
  /// **'Tanto a origem quanto o destino não são acessíveis para pessoa em cadeira de rodas.'**
  String get errorNoBarrierFree;

  /// Message when internet connection is lost
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão com o servidor.'**
  String get errorNoConnectServer;

  /// Message that is displayed when a trip could not be planned, because there were no valid transit times available for the requested time
  ///
  /// In pt, this message translates to:
  /// **'Não há horários de trânsito disponíveis. A data pode ser anterior à atual ou muito longe no futuro ou pode não haver serviço de trânsito para sua viagem no momento escolhido.'**
  String get errorNoTransitTimes;

  /// Message that is displayed when a trip could not be planned, because it would be outside of map data boundaries
  ///
  /// In pt, this message translates to:
  /// **'Essa viagem não é possível. Você pode estar tentando planejar uma viagem fora do limite de dados do mapa.'**
  String get errorOutOfBoundary;

  /// Message that is displayed when a trip could not be planned, because the start or end point is not safely accessible
  ///
  /// In pt, this message translates to:
  /// **'Essa viagem não é possível. Seu ponto de partida ou de chegada pode não ser acessível com segurança (por exemplo, você pode estar partindo de uma rua residencial conectada apenas a uma rodovia).'**
  String get errorPathNotFound;

  /// Message that is displayed when a trip could not be planned, because the request had errors
  ///
  /// In pt, this message translates to:
  /// **'A solicitação tem erros que o servidor não pode ou não foi capaz de processar.'**
  String get errorServerCanNotHandleRequest;

  /// Message that is displayed when a trip could not be planned, because the server is taking too long to respond
  ///
  /// In pt, this message translates to:
  /// **'O planejador de viagens está demorando muito para processar sua solicitação. Por favor, tente novamente mais tarde.'**
  String get errorServerTimeout;

  /// Message that is displayed when the trip planning server was not available
  ///
  /// In pt, this message translates to:
  /// **'Sentimos muito. O planeador de viagens está temporariamente indisponível. Por favor, tente novamente mais tarde.'**
  String get errorServerUnavailable;

  /// Message that is displayed when a trip could not be planned, because origin and destination are too close to each other
  ///
  /// In pt, this message translates to:
  /// **'Origem é desconhecida. Você pode ser um pouco mais descritivo?'**
  String get errorTrivialDistance;

  /// Message that is displayed when a trip could not be planned, because the destination was not found
  ///
  /// In pt, this message translates to:
  /// **'O destino é desconhecido. Você pode ser um pouco mais descritivo?'**
  String get errorUnknownDestination;

  /// Message that is displayed when a trip could not be planned, because the origin was not found
  ///
  /// In pt, this message translates to:
  /// **'A origem é desconhecida. Você pode ser um pouco mais descritivo?'**
  String get errorUnknownOrigin;

  /// Message that is displayed when a trip could not be planned, because both origin and destination were not found
  ///
  /// In pt, this message translates to:
  /// **'Tanto a origem quanto o destino são desconhecidos. Você pode ser um pouco mais descritivo?'**
  String get errorUnknownOriginDestination;

  /// Follow us on (socialMedia)
  ///
  /// In pt, this message translates to:
  /// **'Siga-nos no {value}'**
  String followOnSocialMedia(Object value);

  /// Itinerary leg distance (km)
  ///
  /// In pt, this message translates to:
  /// **'{value} km'**
  String instructionDistanceKm(Object value);

  /// Itinerary leg distance (m)
  ///
  /// In pt, this message translates to:
  /// **'{value} m'**
  String instructionDistanceMeters(Object value);

  /// Itinerary leg duration in hours
  ///
  /// In pt, this message translates to:
  /// **'{value} h'**
  String instructionDurationHours(Object value);

  /// Itinerary leg duration
  ///
  /// In pt, this message translates to:
  /// **'{value} min'**
  String instructionDurationMinutes(Object value);

  /// Vehicle name (Bike)
  ///
  /// In pt, this message translates to:
  /// **'Bicicleta'**
  String get instructionVehicleBike;

  /// Vehicle name (Bus)
  ///
  /// In pt, this message translates to:
  /// **'Ônibus'**
  String get instructionVehicleBus;

  /// Vehicle name (Car)
  ///
  /// In pt, this message translates to:
  /// **'Carro'**
  String get instructionVehicleCar;

  /// Vehicle name (Carpool)
  ///
  /// In pt, this message translates to:
  /// **'Carona'**
  String get instructionVehicleCarpool;

  /// Vehicle name (Commuter train)
  ///
  /// In pt, this message translates to:
  /// **'Trem suburbano'**
  String get instructionVehicleCommuterTrain;

  /// Vehicle name (Gondola)
  ///
  /// In pt, this message translates to:
  /// **'Gôndola'**
  String get instructionVehicleGondola;

  /// Vehicle name (Light Rail Train)
  ///
  /// In pt, this message translates to:
  /// **'(VLT) Veículo Leve sobre trilhos'**
  String get instructionVehicleLightRail;

  /// Vehicle name (Metro)
  ///
  /// In pt, this message translates to:
  /// **'Metrô'**
  String get instructionVehicleMetro;

  /// Vehicle name (Micro)
  ///
  /// In pt, this message translates to:
  /// **'Micro ônibus'**
  String get instructionVehicleMicro;

  /// Vehicle name (Minibus)
  ///
  /// In pt, this message translates to:
  /// **'Minibus'**
  String get instructionVehicleMinibus;

  /// Vehicle name (Trufi)
  ///
  /// In pt, this message translates to:
  /// **'Trufi'**
  String get instructionVehicleTrufi;

  /// No description provided for @instructionVehicleWalk.
  ///
  /// In pt, this message translates to:
  /// **'A pé'**
  String get instructionVehicleWalk;

  /// Menu item that shows the map/planned trip
  ///
  /// In pt, this message translates to:
  /// **'Route planner'**
  String get menuConnections;

  /// No description provided for @menuSocialMedia.
  ///
  /// In pt, this message translates to:
  /// **'Social media'**
  String get menuSocialMedia;

  /// Menu item that shows the bus list page
  ///
  /// In pt, this message translates to:
  /// **'Mostrar rotas'**
  String get menuTransportList;

  /// Message when no route could be found after a route search
  ///
  /// In pt, this message translates to:
  /// **'Desculpe, não conseguimos encontrar uma rota. O que você quer fazer?'**
  String get noRouteError;

  /// Button label to try another destination when no route could be found
  ///
  /// In pt, this message translates to:
  /// **'Tente outro destino'**
  String get noRouteErrorActionCancel;

  /// Button label to report a missing route when no route could be found
  ///
  /// In pt, this message translates to:
  /// **'Relatar uma rota ausente'**
  String get noRouteErrorActionReportMissingRoute;

  /// Button label to show the car route when no route could be found
  ///
  /// In pt, this message translates to:
  /// **'Mostrar rota de carro'**
  String get noRouteErrorActionShowCarRoute;

  /// No description provided for @notShowAgain.
  ///
  /// In pt, this message translates to:
  /// **'Não mostre novamente'**
  String get notShowAgain;

  /// Website menu item
  ///
  /// In pt, this message translates to:
  /// **'Leia nosso blog'**
  String get readOurBlog;

  /// Message that is displayed when the response of the trip planning request could not be received
  ///
  /// In pt, this message translates to:
  /// **'Falha ao carregar o plano'**
  String get searchFailLoadingPlan;

  /// Placeholder text for the destination field (in search state)
  ///
  /// In pt, this message translates to:
  /// **'Escolha o destino'**
  String get searchHintDestination;

  /// Placeholder text for the origin field (in search state)
  ///
  /// In pt, this message translates to:
  /// **'Escolha a origem'**
  String get searchHintOrigin;

  /// Placeholder text for the destination field (in map-visible state)
  ///
  /// In pt, this message translates to:
  /// **'Selecione o destino'**
  String get searchPleaseSelectDestination;

  /// Placeholder text for the origin field (in map-visible state)
  ///
  /// In pt, this message translates to:
  /// **'Selecione a origem'**
  String get searchPleaseSelectOrigin;

  /// Text with URL that is used when sharing the app.
  ///
  /// In pt, this message translates to:
  /// **'Baixe {appTitle}, o aplicativo de transporte público para {cityName}, em {url}'**
  String shareAppText(Object url, Object appTitle, Object cityName);

  /// General Show on map tilers label
  ///
  /// In pt, this message translates to:
  /// **'Show on map'**
  String get commonShowMap;

  /// General Map Settings label
  ///
  /// In pt, this message translates to:
  /// **'Map Settings'**
  String get commonMapSettings;

  /// Label for the Map types
  ///
  /// In pt, this message translates to:
  /// **'Map Type'**
  String get mapTypeLabel;

  /// No description provided for @selectYourPointInterest.
  ///
  /// In pt, this message translates to:
  /// **'Pontos de Interesse'**
  String get selectYourPointInterest;

  /// No description provided for @themeModeDark.
  ///
  /// In pt, this message translates to:
  /// **'Tema escuro'**
  String get themeModeDark;

  /// No description provided for @themeModeLight.
  ///
  /// In pt, this message translates to:
  /// **'Tema claro'**
  String get themeModeLight;

  /// No description provided for @themeModeSystem.
  ///
  /// In pt, this message translates to:
  /// **'Sistema padrão'**
  String get themeModeSystem;
}

class _TrufiBaseLocalizationDelegate extends LocalizationsDelegate<TrufiBaseLocalization> {
  const _TrufiBaseLocalizationDelegate();

  @override
  Future<TrufiBaseLocalization> load(Locale locale) {
    return SynchronousFuture<TrufiBaseLocalization>(lookupTrufiBaseLocalization(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'fr', 'it', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_TrufiBaseLocalizationDelegate old) => false;
}

TrufiBaseLocalization lookupTrufiBaseLocalization(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return TrufiBaseLocalizationDe();
    case 'en': return TrufiBaseLocalizationEn();
    case 'es': return TrufiBaseLocalizationEs();
    case 'fr': return TrufiBaseLocalizationFr();
    case 'it': return TrufiBaseLocalizationIt();
    case 'pt': return TrufiBaseLocalizationPt();
  }

  throw FlutterError(
    'TrufiBaseLocalization.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
