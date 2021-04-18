
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
  String get aboutOpenSource => '';

  @override
  String get alertLocationServicesDeniedMessage => 'Celularniyki GPS ñisqayuqchu? Chantapis qhaway Ubicación ñisqa jap’ichisqa kananta.';

  @override
  String get alertLocationServicesDeniedTitle => 'Kay kiti mana tarikunchu';

  @override
  String get appReviewDialogButtonAccept => '';

  @override
  String get appReviewDialogButtonDecline => '';

  @override
  String get appReviewDialogContent => '';

  @override
  String get appReviewDialogTitle => '';

  @override
  String get chooseLocationPageSubtitle => 'Ñit\'iy mapapi';

  @override
  String get chooseLocationPageTitle => 'Mapapi juk kitita riqsichiy';

  @override
  String get commonCancel => 'Mana';

  @override
  String get commonDestination => 'Mayman';

  @override
  String get commonError => 'Pantay';

  @override
  String get commonFailLoading => 'Mana aticunchu tariyta datusta';

  @override
  String get commonGoOffline => 'Offline';

  @override
  String get commonGoOnline => 'Online';

  @override
  String get commonNoInternet => 'Mana internet kanchu';

  @override
  String get commonOK => 'Ari';

  @override
  String get commonOrigin => 'Maymanta';

  @override
  String get commonSave => '';

  @override
  String get commonUnknownError => 'Mana yachacunchu ima pantay kasqanta chay';

  @override
  String description(Object cityName) {
    return 'Trufis, microspi, buspi ima qhuchapampapi aswan sumaq ch’usanapaq.';
  }

  @override
  String get donate => '';

  @override
  String get errorAmbiguousDestination => 'Ñan wakichiqqa chayana kitiykimanta mana ridsinchu. Kay kitikunamanta chikllay manaqa chayana kitita sut’ita qillqay.';

  @override
  String get errorAmbiguousOrigin => 'Ñan wakichiqqa qallariy kitiykiqa mana riqsinchu. Kay kitikunamanta chikllay manaqa chayana kitita sut’ita qillqay.';

  @override
  String get errorAmbiguousOriginDestination => 'Qallariy chanta chayana kitikunata sumaqta akllay, aswan sut’i kay. Kay kitikunamanta chikllay manaqa chayana kitita sut’ita qillqay. Un destino más exacto.';

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
  String get followOnFacebook => '';

  @override
  String get followOnInstagram => '';

  @override
  String get followOnTwitter => '';

  @override
  String instructionDistanceKm(Object value) {
    return '${value} km';
  }

  @override
  String instructionDistanceMeters(Object value) {
    return '${value} m';
  }

  @override
  String instructionDurationMinutes(Object value) {
    return '${value} min';
  }

  @override
  String instructionJunction(Object street1, Object street2) {
    return '';
  }

  @override
  String instructionRide(Object vehicle, Object distance, Object duration, Object location) {
    return 'Jap’iy ${vehicle} ${duration} (${distance})\n${location} kama';
  }

  @override
  String get instructionVehicleBus => 'Bus';

  @override
  String get instructionVehicleCar => 'Coche';

  @override
  String get instructionVehicleGondola => 'Góndola';

  @override
  String get instructionVehicleLightRail => '';

  @override
  String get instructionVehicleMicro => 'Micro';

  @override
  String get instructionVehicleMinibus => 'Minibus';

  @override
  String get instructionVehicleTrufi => 'Trufi';

  @override
  String instructionWalk(Object distance, Object duration, Object location) {
    return 'Kaymanta puriy ${duration} (${distance}) achaykama\n${location} Puriy';
  }

  @override
  String get mapTypeLabel => '';

  @override
  String get mapTypeSatelliteCaption => '';

  @override
  String get mapTypeStreetsCaption => '';

  @override
  String get mapTypeTerrainCaption => '';

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
  String get menuShareApp => '';

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
  String get readOurBlog => '';

  @override
  String get savedPlacesEnterNameTitle => '';

  @override
  String get savedPlacesRemoveLabel => '';

  @override
  String get savedPlacesSelectIconTitle => '';

  @override
  String get savedPlacesSetIconLabel => '';

  @override
  String get savedPlacesSetNameLabel => '';

  @override
  String get savedPlacesSetPositionLabel => '';

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
  String shareAppText(Object url, Object appTitle, Object cityName) {
    return '';
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
  String version(Object version) {
    return 'Versión ${version}';
  }
}
