
// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'trufi_localization.dart';

// ignore_for_file: unnecessary_brace_in_string_interps

/// The translations for Ewe (`ee`).
class TrufiLocalizationEe extends TrufiLocalization {
  TrufiLocalizationEe([String locale = 'ee']) : super(locale);

  @override
  String get aboutContent => 'mitso Bolivia kple dukorvovome eye morlor hahomorzozor. mido dorworfea be morzorzor nanor  borboe na Cochabamba kple efe gologuiawo.';

  @override
  String get aboutLicenses => 'nuse';

  @override
  String get aboutOpenSource => 'na dorworfea na tedenu wo. dorworfea le github';

  @override
  String get alertLocationServicesDeniedMessage => 'kpor egbor be GPS le wo morfoka dzi';

  @override
  String get alertLocationServicesDeniedTitle => 'tefe meli o';

  @override
  String get appReviewDialogButtonAccept => 'nlor susud3d3';

  @override
  String get appReviewDialogButtonDecline => 'menye fifia o';

  @override
  String get appReviewDialogContent => 'nlor susudede ade nami';

  @override
  String get appReviewDialogTitle => 'trufi de vi nawoa';

  @override
  String get carParkCloseCapacityMessage => 'Dieser Parkplatz ist fast ausgebucht. Bitte planen Sie zusätzliche Zeit für Ihre Anfahrt ein.';

  @override
  String get carParkExcludeFull => 'Dieser Parkplatz ist fast ausgebucht. Bitte planen Sie zusätzliche Zeit für Ihre Anfahrt ein.';

  @override
  String get chooseLocationPageSubtitle => 'keke mortata la.';

  @override
  String get chooseLocationPageTitle => 'tsor tefe deka';

  @override
  String get commonArrival => 'Arrival';

  @override
  String get commonBikesAvailable => 'Show on map';

  @override
  String get commonCall => 'Show on map';

  @override
  String get commonCancel => 'tutu';

  @override
  String get commonCitybikes => 'Citybikes';

  @override
  String get commonConfirmLocation => 'Show on map';

  @override
  String get commonCustomPlaces => 'Custom places';

  @override
  String get commonDeparture => 'Departure';

  @override
  String get commonDestination => 'afisi yim nele';

  @override
  String get commonError => 'aforku';

  @override
  String get commonFailLoading => 'data meva o';

  @override
  String get commonFavoritePlaces => 'Favorite places';

  @override
  String get commonFromStation => 'Show on map';

  @override
  String get commonFromStop => 'Show on map';

  @override
  String get commonGoOffline => 'dzo le ka dzi';

  @override
  String get commonGoOnline => 'va ka dzi';

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
  String get commonNoInternet => 'ka meli o';

  @override
  String get commonNow => 'Show on map';

  @override
  String get commonOK => 'enyo';

  @override
  String get commonOnDemandTaxi => 'Show on map';

  @override
  String get commonOrigin => 'afisi netso';

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
  String get commonUnknownError => 'aforku manyamanya';

  @override
  String get commonUnkownPlace => 'Show on map';

  @override
  String get commonWait => 'Wait';

  @override
  String get commonWalk => 'Walk';

  @override
  String defaultLocationAdd(Object defaultLocation) {
    return 'nutinya';
  }

  @override
  String get defaultLocationHome => 'Home';

  @override
  String get defaultLocationWork => 'Work';

  @override
  String departureBikeStation(Object departureStop, Object departureTime) {
    return 'morwo kple dorworfea nudorwolawo\nzu miadometor deka';
  }

  @override
  String description(Object cityName) {
    return 'morzorzor adoduia le Chombamba yenye lori did kple lori sue wo';
  }

  @override
  String get donate => 'naanu';

  @override
  String get errorAmbiguousDestination => 'morzorzordzikporla la meya afisi yim nele o. tsor le esiawo dome alo nlor bubu';

  @override
  String get errorAmbiguousOrigin => 'morzorzordzikporla la menya afisi yim nele o. tsor esiawo dome tor deka alo de afisi yim nele la gorme nyuie';

  @override
  String get errorAmbiguousOriginDestination => 'gormesese melina afisi neyine kple afisi netso o.tso esiawo dome tor deka alo de afisi yim nele la gorme nyuie';

  @override
  String get errorCancelledByUser => 'Canceled by user';

  @override
  String get errorEmailFeedback => 'Could not open mail feedback app, the URL or email is incorrect';

  @override
  String get errorNoBarrierFree => 'bafakeke matenu ayi afisi netso kple afisi neyina o';

  @override
  String get errorNoTransitTimes => 'Morzor xeyixi meli o. Nkeke si nedo la vayi alo ele etsor me alo wu melina xeyixi si netia la o.';

  @override
  String get errorOutOfBoundary => 'morzorzor la matenu ayi o. morzorzorla mele mofiatata dzi o';

  @override
  String get errorPathNotFound => 'morzorzor la matenu adzedzi o. afisi netso alo afisineyina be le dzadze o';

  @override
  String get errorServerCanNotHandleRequest => 'nane gble tso wi biabialanu,dorworfea mese egorme o';

  @override
  String get errorServerTimeout => 'morzorzordzikporla fe dorworwor mele tsortsorm o.gawoe ake.';

  @override
  String get errorServerUnavailable => 'morzorzordzikporla meli o.woe emegbe';

  @override
  String get errorTrivialDistance => 'afisi netso la tso kpuie nutor';

  @override
  String get errorUnknownDestination => 'afisi neyina la mele nyanyame o,doe do ake';

  @override
  String get errorUnknownOrigin => 'afisi netso la mele nyanya me o,doe do ake';

  @override
  String get errorUnknownOriginDestination => 'afisi netso kple afisi neyina la meli o. gbugbor na dorwo do';

  @override
  String get feedbackContent => 'dordordo ade li nele dzidzim be miawo tso dorworfea nua.\nnami wo kafomor fe dzesiwo kple wo email';

  @override
  String get feedbackTitle => 'Do email do da mi';

  @override
  String get followOnFacebook => 'kplormido le Facebook';

  @override
  String get followOnInstagram => 'kplormido le instagram';

  @override
  String get followOnTwitter => 'kplormido le Twiter';

  @override
  String instructionDistanceKm(Object value) {
    return 'kilom3ta';
  }

  @override
  String instructionDistanceMeters(Object value) {
    return 'm3ta';
  }

  @override
  String instructionDurationHours(Object value) {
    return 'gafofo';
  }

  @override
  String instructionDurationMinutes(Object value) {
    return 'gafofo';
  }

  @override
  String instructionJunction(Object street1, Object street2) {
    return 'meli o';
  }

  @override
  String instructionRide(Object vehicle, Object distance, Object duration, Object location) {
    return 'za ${vehicle} abe ${duration} ${distance} yi ${location} nkor';
  }

  @override
  String get instructionVehicleBike => 'lori didi';

  @override
  String get instructionVehicleBus => 'lori didi';

  @override
  String get instructionVehicleCar => 'lori';

  @override
  String get instructionVehicleCarpool => 'lori didi';

  @override
  String get instructionVehicleCommuterTrain => 'lori didi';

  @override
  String get instructionVehicleGondola => 'Gondola';

  @override
  String get instructionVehicleLightRail => 'gborlo';

  @override
  String get instructionVehicleMetro => 'lori didi';

  @override
  String get instructionVehicleMicro => 'micro';

  @override
  String get instructionVehicleMinibus => 'lori sue';

  @override
  String get instructionVehicleOnCar => 'lori';

  @override
  String get instructionVehicleSharing => 'lori didi';

  @override
  String get instructionVehicleSharingCarSharing => 'lori didi';

  @override
  String get instructionVehicleSharingRegioRad => 'lori didi';

  @override
  String get instructionVehicleSharingTaxi => 'lori didi';

  @override
  String get instructionVehicleTrufi => 'Trufi';

  @override
  String instructionWalk(Object distance, Object duration, Object location) {
    return 'zor';
  }

  @override
  String get itineraryBuyTicket => 'Tickets kaufen';

  @override
  String get itineraryMissingPrice => 'Keine Preisangabe möglich';

  @override
  String get itineraryPriceOnlyPublicTransport => 'Preisauskunft nur für ÖPNV gültig.';

  @override
  String get itineraryTicketsTitle => 'Benötigte Fahrkarten';

  @override
  String get itineraryTicketTitle => 'Benötigte Fahrkarte';

  @override
  String get mapTypeLabel => 'Map Type';

  @override
  String get mapTypeSatelliteCaption => 'Satellite';

  @override
  String get mapTypeStreetsCaption => 'Streets';

  @override
  String get mapTypeTerrainCaption => 'Terrain';

  @override
  String get menuAbout => 'tso mianu';

  @override
  String get menuAppReview => 'nami numetsotso';

  @override
  String get menuConnections => 'fia mor';

  @override
  String get menuFeedback => 'nami susu';

  @override
  String get menuOnline => 'nor kadzi';

  @override
  String get menuShareApp => 'kaka dorworfea';

  @override
  String get menuTeam => 'haborbor';

  @override
  String get menuYourPlaces => 'Your places';

  @override
  String get noRouteError => 'morla meli o. Nuka na wor';

  @override
  String get noRouteErrorActionCancel => 'tsor afisi neyina bubu';

  @override
  String get noRouteErrorActionReportMissingRoute => 'de gbefa morbubu';

  @override
  String get noRouteErrorActionShowCarRoute => 'fia mor kple lori';

  @override
  String get readOurBlog => 'xle miafe nu';

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
  String get searchFailLoadingPlan => 'mekor dzidzedze o';

  @override
  String get searchHintDestination => 'tsor afisi neyina';

  @override
  String get searchHintOrigin => 'tsor gorme dzefe';

  @override
  String get searchItemChooseOnMap => 'tsor tefea le nutata la dzi';

  @override
  String get searchItemNoResults => 'nudodo adeke o';

  @override
  String get searchItemYourLocation => 'tefe si nele';

  @override
  String get searchMapMarker => 'nutata tanu';

  @override
  String get searchPleaseSelectDestination => 'tsor afisi neyina';

  @override
  String get searchPleaseSelectOrigin => 'tsor afisi ne tso';

  @override
  String get searchTitleFavorites => 'veviwo';

  @override
  String get searchTitlePlaces => 'tefewo';

  @override
  String get searchTitleRecent => 'enyide';

  @override
  String get searchTitleResults => 'di nudodowo';

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
    return 'hahomorzorzor le Cochabamba${url}';
  }

  @override
  String tagline(Object city) {
    return 'hahomorzorzor le Cochabamba';
  }

  @override
  String get teamContent => 'dorworfe siame torwo tso dukorvovome.edzibe yea zu miadome tor deka?yormi le kafomorsia dzi';

  @override
  String teamSectionRepresentatives(Object representatives) {
    return 'tefenorlawo';
  }

  @override
  String teamSectionRoutes(Object osmContributors, Object routeContributors) {
    return 'morwo kple dorworfea nudorwolawo\nzu miadometor deka';
  }

  @override
  String teamSectionTeam(Object teamMembers) {
    return 'haborborme norlawo';
  }

  @override
  String teamSectionTranslations(Object translators) {
    return 'gormedede';
  }

  @override
  String get title => 'Trufi dorworfea';

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
    return 'nutinya';
  }
}
