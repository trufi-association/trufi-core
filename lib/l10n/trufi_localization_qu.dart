
// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'trufi_localization.dart';

// ignore_for_file: unnecessary_brace_in_string_interps

/// The translations for Quechua (`qu`).
class TrufiLocalizationQu extends TrufiLocalization {
  TrufiLocalizationQu([String locale = 'qu']) : super(locale);

  @override
  String get aboutContent => 'Bolivia suyumantapacha waq jawa suyukunawan jukchasqa kayku, munayku chanta kallpanchayku ima transporte publico ñisqata. Kay thatkichiy ruwasqa kachkan Qhuchapampa jap’iypi, ukhupi jawaman ima, aswan sasata ch’usanaykipaq.';

  @override
  String get aboutLicenses => 'Licencias';

  @override
  String get aboutOpenSource => 'This app is released as open source on GitHub. Feel free to contribute or bring it to your own city.';

  @override
  String get alertLocationServicesDeniedMessage => 'Celularniyki GPS ñisqayuqchu? Chantapis qhaway Ubicación ñisqa jap’ichisqa kananta.';

  @override
  String get alertLocationServicesDeniedTitle => 'Kay kiti mana tarikunchu';

  @override
  String get appReviewDialogButtonAccept => 'Write review';

  @override
  String get appReviewDialogButtonDecline => 'Not now';

  @override
  String get appReviewDialogContent => 'Support us with a review on the Google Play Store.';

  @override
  String get appReviewDialogTitle => 'Enjoying Trufi?';

  @override
  String get carParkCloseCapacityMessage => 'This car park is close to capacity. Please allow additional time for you journey.';

  @override
  String get carParkExcludeFull => 'Exclude full car parks';

  @override
  String get chooseLocationPageSubtitle => 'Ñit\'iy mapapi';

  @override
  String get chooseLocationPageTitle => 'Mapapi juk kitita riqsichiy';

  @override
  String get commonArrival => 'Arrival';

  @override
  String get commonBikesAvailable => 'Show on map';

  @override
  String get commonCall => 'Show on map';

  @override
  String get commonCancel => 'Mana';

  @override
  String get commonCitybikes => 'Citybikes';

  @override
  String get commonConfirmLocation => 'Show on map';

  @override
  String get commonCustomPlaces => 'Custom places';

  @override
  String get commonDeparture => 'Departure';

  @override
  String get commonDestination => 'Mayman';

  @override
  String get commonError => 'Pantay';

  @override
  String get commonFailLoading => 'Mana aticunchu tariyta datusta';

  @override
  String get commonFavoritePlaces => 'Favorite places';

  @override
  String get commonFromStation => 'Show on map';

  @override
  String get commonFromStop => 'Show on map';

  @override
  String get commonGoOffline => 'Offline';

  @override
  String get commonGoOnline => 'Online';

  @override
  String get commonItineraryNoTransitLegs => 'Show on map';

  @override
  String get commonLeavesAt => 'Show on map';

  @override
  String get commonLeavingNow => 'Leaving now';

  @override
  String get commonLoading => 'Show on map';

  @override
  String get commonMapSettings => 'Show on map';

  @override
  String get commonMoreInformartion => 'Show on map';

  @override
  String get commonNoInternet => 'Mana internet kanchu';

  @override
  String get commonNow => 'Show on map';

  @override
  String get commonOK => 'Ari';

  @override
  String get commonOnDemandTaxi => 'Show on map';

  @override
  String get commonOrigin => 'Maymanta';

  @override
  String get commonPlatform => 'Show on map';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSettings => 'Settings';

  @override
  String get commonShowMap => 'Show on map';

  @override
  String get commonTomorrow => 'Show on map';

  @override
  String get commonTrack => 'Show on map';

  @override
  String get commonUnknownError => 'Mana yachacunchu ima pantay kasqanta chay';

  @override
  String get commonUnkownPlace => 'Show on map';

  @override
  String get commonWait => 'Wait';

  @override
  String get commonWalk => 'Walk';

  @override
  String get copyrightsPriceProvider => 'Fare information provided by Nahverkehrsgesellschaft Baden-Württemberg mbH (NVBW). No liability for the correctness of the information.';

  @override
  String defaultLocationAdd(Object defaultLocation) {
    return 'Versión {version}';
  }

  @override
  String get defaultLocationHome => 'Home';

  @override
  String get defaultLocationWork => 'Work';

  @override
  String departureBikeStation(Object departureStop, Object departureTime) {
    return 'Rutas yanapaqkuna: {routeContributors} chanta tukuy pikunachus musuq rutas Open Street Map chayniqman apachimuqkunaman, {osmContributors}.\nRiqsirichimuwayku Open Street Map qutupi llamk’ayta munanki chayqa!';
  }

  @override
  String description(Object cityName) {
    return 'Trufis, microspi, buspi ima qhuchapampapi aswan sumaq ch’usanapaq.';
  }

  @override
  String get donate => 'Donate';

  @override
  String get errorAmbiguousDestination => 'Ñan wakichiqqa chayana kitiykimanta mana ridsinchu. Kay kitikunamanta chikllay manaqa chayana kitita sut’ita qillqay.';

  @override
  String get errorAmbiguousOrigin => 'Ñan wakichiqqa qallariy kitiykiqa mana riqsinchu. Kay kitikunamanta chikllay manaqa chayana kitita sut’ita qillqay.';

  @override
  String get errorAmbiguousOriginDestination => 'Qallariy chanta chayana kitikunata sumaqta akllay, aswan sut’i kay. Kay kitikunamanta chikllay manaqa chayana kitita sut’ita qillqay. Un destino más exacto.';

  @override
  String get errorCancelledByUser => 'Canceled by user';

  @override
  String get errorEmailFeedback => 'Could not open mail feedback app, the URL or email is incorrect';

  @override
  String get errorNoBarrierFree => 'Qallariy chanta chayana kitikunata mana chukuna tinkuypalluqchu.';

  @override
  String get errorNoTransitTimes => 'Mana llamk’aq phani kanchu. Ichas mana kay p’unchawpi ruwakuyta atikunmanchu, manaqa mana ñan kanmanchu ch’usanaykipaq.';

  @override
  String get errorOutOfBoundary => 'Kay ch’usana kitiqa mana ruwakuyta atinchu. Manachu kay llaqtapi mana kasqanta kitita machkhanki?';

  @override
  String get errorPathNotFound => 'Kay ch’usana kitiqa mana ruwakuyta atikunchu mana ñan tarikusqanrayku, akllay qallariy chanta chayana kititaqa allin riqsisqa ñankunapi.';

  @override
  String get errorServerCanNotHandleRequest => 'Mañasqayki kitiqa mana tariyta atikunchu.';

  @override
  String get errorServerTimeout => 'Kiti mask’aqqa anchata unaykachkan. Watiqmanta juk ratumanta mask’ay.';

  @override
  String get errorServerUnavailable => 'Qhispichiwasqayku. Kunan pacha, ñan mask’aqqa mana llamk’achkanku. Watiqmanta mask’ay juk ratumanta.';

  @override
  String get errorTrivialDistance => 'Qallariy chanta chayana kitkunaqa ancha qaylla kachkanku.';

  @override
  String get errorUnknownDestination => 'Chayana kitiqa mana riqsisqachu. Aswan sut’ita riqsichiy.';

  @override
  String get errorUnknownOrigin => 'Qallariy kitiqa mana riqsisqachu. Aswan sut’ita riqsichiy.';

  @override
  String get errorUnknownOriginDestination => 'Qallariy chanta chayana kitikunaqa mana riqsisqachu kanku. Kitiykita aswan sut’ita riqsichiy.';

  @override
  String get feedbackContent => 'Imayna riqch’asunki Trufi App? Mayk’aqpis pantaykunata tarirqankichu? Riqsiyta munayku! Correo electrónico chanta yupaykita ima riqsirichiwayku sumaqta yanaparisunaykupaq.';

  @override
  String get feedbackTitle => 'Correo electrónico ñiqta yuyasqasniykita apachimuwayku!';

  @override
  String get followOnFacebook => 'Follow us on Facebook';

  @override
  String get followOnInstagram => 'Follow us on Instagram';

  @override
  String get followOnTwitter => 'Follow us on Twitter';

  @override
  String get infoMessageDestinationOutsideService => 'No route suggestions were found because the destination is outside the service area.';

  @override
  String get infoMessageNoRouteMsg => 'Unfortunately, no route suggestions were found.';

  @override
  String get infoMessageNoRouteMsgWithChanges => 'Unfortunately, no route suggestions were found. Please check your search settings or try changing the origin or destination.';

  @override
  String get infoMessageNoRouteOriginNearDestination => 'No route suggestions were found because the origin and destination are the same.';

  @override
  String get infoMessageNoRouteOriginSameAsDestination => 'No route suggestions were found because the origin and destination are very close to each other.';

  @override
  String get infoMessageNoRouteShowingAlternativeOptions => 'No route suggestions were found with the your settings. However, we found the following route options:';

  @override
  String get infoMessageOnlyCyclingRoutes => 'Your search returned only walking and cycling routes.';

  @override
  String get infoMessageOnlyWalkingCyclingRoutes => 'Your search returned only cycling routes.';

  @override
  String get infoMessageOnlyWalkingRoutes => 'Your search returned only walking routes.';

  @override
  String get infoMessageOriginOutsideService => 'No route suggestions were found because the origin is outside the service area.';

  @override
  String instructionDistanceKm(Object value) {
    return '${value} km';
  }

  @override
  String instructionDistanceMeters(Object value) {
    return '${value} m';
  }

  @override
  String instructionDurationHours(Object value) {
    return '${value} min';
  }

  @override
  String instructionDurationMinutes(Object value) {
    return '${value} min';
  }

  @override
  String instructionJunction(Object street1, Object street2) {
    return '${street1} and ${street2}';
  }

  @override
  String instructionRide(Object vehicle, Object distance, Object duration, Object location) {
    return 'Jap’iy ${vehicle} ${duration} (${distance})\n${location} kama';
  }

  @override
  String get instructionVehicleBike => 'Bus';

  @override
  String get instructionVehicleBus => 'Bus';

  @override
  String get instructionVehicleCar => 'Coche';

  @override
  String get instructionVehicleCarpool => 'Bus';

  @override
  String get instructionVehicleCommuterTrain => 'Bus';

  @override
  String get instructionVehicleGondola => 'Góndola';

  @override
  String get instructionVehicleLightRail => 'Light Rail Train';

  @override
  String get instructionVehicleMetro => 'Bus';

  @override
  String get instructionVehicleMicro => 'Micro';

  @override
  String get instructionVehicleMinibus => 'Minibus';

  @override
  String get instructionVehicleOnCar => 'Coche';

  @override
  String get instructionVehicleSharing => 'Bus';

  @override
  String get instructionVehicleSharingCarSharing => 'Bus';

  @override
  String get instructionVehicleSharingRegioRad => 'Bus';

  @override
  String get instructionVehicleSharingTaxi => 'Bus';

  @override
  String get instructionVehicleTaxi => 'Coche';

  @override
  String get instructionVehicleTrufi => 'Trufi';

  @override
  String instructionWalk(Object distance, Object duration, Object location) {
    return 'Kaymanta puriy ${duration} (${distance}) achaykama\n${location} Puriy';
  }

  @override
  String get itineraryBuyTicket => 'Buy tickets';

  @override
  String get itineraryMissingPrice => 'No price information';

  @override
  String get itineraryPriceOnlyPublicTransport => 'Price only valid for public transport part of the journey.';

  @override
  String get itineraryTicketsTitle => 'Required tickets';

  @override
  String get itineraryTicketTitle => 'Required ticket';

  @override
  String get mapTypeLabel => 'Map Type';

  @override
  String get mapTypeSatelliteCaption => 'Satellite';

  @override
  String get mapTypeStreetsCaption => 'Streets';

  @override
  String get mapTypeTerrainCaption => 'Terrain';

  @override
  String get menuAbout => 'Imamanta yachayta munanki?';

  @override
  String get menuAppReview => 'Trufi Appta chaninchay';

  @override
  String get menuConnections => 'Ñankunata rikhuchiy';

  @override
  String get menuFeedback => 'Yuyasqayniykita riqsichiwayku';

  @override
  String get menuOnline => 'Online';

  @override
  String get menuShareApp => 'Share the app';

  @override
  String get menuTeam => 'Ñuqaykumanta';

  @override
  String get menuYourPlaces => 'Tus lugares';

  @override
  String get noRouteError => 'Qhispichiwasqayku. Mana achhaykama ñanta tariyta atikunchu. Imata ruwayta munanki?';

  @override
  String get noRouteErrorActionCancel => 'Waq kitiwan watiqmanta mask\'ay';

  @override
  String get noRouteErrorActionReportMissingRoute => 'Mana rikhurimuq ñanta riqsichiy';

  @override
  String get noRouteErrorActionShowCarRoute => 'Autopaq kay ñanta rikhuchiy';

  @override
  String get readOurBlog => 'Read our blog';

  @override
  String get savedPlacesEnterNameTitle => 'Enter name';

  @override
  String get savedPlacesRemoveLabel => 'Remove place';

  @override
  String get savedPlacesSelectIconTitle => 'Select symbol';

  @override
  String get savedPlacesSetIconLabel => 'Change symbol';

  @override
  String get savedPlacesSetNameLabel => 'Edit name';

  @override
  String get savedPlacesSetPositionLabel => 'Edit position';

  @override
  String get searchFailLoadingPlan => 'Mana tarikunchu mayninta rinata';

  @override
  String get searchHintDestination => 'Chayana kitita akllay';

  @override
  String get searchHintOrigin => 'Qallariy kitita akllay';

  @override
  String get searchItemChooseOnMap => 'Mapa ñisqapi akllay';

  @override
  String get searchItemNoResults => 'Mana tarikunchu';

  @override
  String get searchItemYourLocation => 'Kaypi kachkankii';

  @override
  String get searchMapMarker => 'Maypi cashani mapapy';

  @override
  String get searchPleaseSelectDestination => 'Chayana kitita akllay';

  @override
  String get searchPleaseSelectOrigin => 'Qallariy kitita akllay';

  @override
  String get searchTitleFavorites => 'Aswan mask\'akuqkuna';

  @override
  String get searchTitlePlaces => 'Kitikuna';

  @override
  String get searchTitleRecent => 'Musuq mask\'anakuna';

  @override
  String get searchTitleResults => 'Mask\'anakuna riqsichiq';

  @override
  String get settingPanelAccessibility => 'Accessibility';

  @override
  String get settingPanelAvoidTransfers => 'Avoid transfers';

  @override
  String get settingPanelAvoidWalking => 'Avoid walking';

  @override
  String get settingPanelBikingSpeed => 'Biking speed';

  @override
  String get settingPanelMyModesTransport => 'My modes of transport';

  @override
  String get settingPanelMyModesTransportBike => 'Bike';

  @override
  String get settingPanelMyModesTransportBikeRide => 'Park and Ride';

  @override
  String get settingPanelMyModesTransportParkRide => 'Park and Ride';

  @override
  String get settingPanelTransportModes => 'Transport modes';

  @override
  String get settingPanelWalkingSpeed => 'Walking speed';

  @override
  String get settingPanelWheelchair => 'Wheelchair';

  @override
  String shareAppText(Object url, Object appTitle, Object cityName) {
    return 'Download ${appTitle}, the public transport app for ${cityName}, at ${url}';
  }

  @override
  String tagline(Object city) {
    return 'Transporte público en Cochabamba';
  }

  @override
  String get teamContent => 'Trufi Association ñisqa kay aplicación Trufi App ñisqata apachimun may chhika yanapaqkunawan. Munankichu Trufi App aswan sumaqman tukunanta? Kayman riqsirichimuwayku:';

  @override
  String teamSectionRepresentatives(Object representatives) {
    return 'Umalliqkuna: ${representatives}';
  }

  @override
  String teamSectionRoutes(Object osmContributors, Object routeContributors) {
    return 'Rutas yanapaqkuna: ${routeContributors} chanta tukuy pikunachus musuq rutas Open Street Map chayniqman apachimuqkunaman, ${osmContributors}.\nRiqsirichimuwayku Open Street Map qutupi llamk’ayta munanki chayqa!';
  }

  @override
  String teamSectionTeam(Object teamMembers) {
    return 'Yanapaqkuna: ${teamMembers}';
  }

  @override
  String teamSectionTranslations(Object translators) {
    return 'Tiqraqkuna: ${translators}';
  }

  @override
  String get title => 'Trufi App';

  @override
  String get typeSpeedAverage => 'Average';

  @override
  String get typeSpeedCalm => 'Calm';

  @override
  String get typeSpeedFast => 'Fast';

  @override
  String get typeSpeedPrompt => 'Prompt';

  @override
  String get typeSpeedSlow => 'Slow';

  @override
  String version(Object version) {
    return 'Versión ${version}';
  }
}
