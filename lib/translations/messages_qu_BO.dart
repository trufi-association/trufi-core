// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a qu_BO locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

// ignore: unnecessary_new
final messages = new MessageLookup();

// ignore: unused_element
final _keepAnalysisHappy = Intl.defaultLocale;

// ignore: non_constant_identifier_names
typedef MessageIfAbsent(String message_str, List args);

class MessageLookup extends MessageLookupByLibrary {
  get localeName => 'qu_BO';

  String lookupMessage(
      String message_str, String locale, String name, List args, String meaning,
      {MessageIfAbsent ifAbsent}) {
    String failedLookup(String message_str, List args) {
      // If there's no message_str, then we are an internal lookup, e.g. an
      // embedded plural, and shouldn't fail.
      if (message_str == null) return null;
      // ignore: unnecessary_new
      throw new UnsupportedError(
          "No translation found for message '$name',\n"
          "  original text '$message_str'");
    }
    return super.lookupMessage(message_str, locale, name, args, meaning,
        ifAbsent: ifAbsent ?? failedLookup);
  }

  static m0(value) => "${value} km";

  static m1(value) => "${value} m";

  static m2(value) => "${value} min";

  static m3(vehicle, duration, distance, location) => "Jap’iy ${vehicle} ${duration} (${distance})\n${location} kama";

  static m4(duration, distance, location) => "Kaymanta puriy ${duration} (${distance}) achaykama\n${location} Puriy";

  static m5(representatives) => "Umalliqkuna: ${representatives}";

  static m6(routeContributors, osmContributors) => "Rutas yanapaqkuna: ${routeContributors} chanta tukuy pikunachus musuq rutas Open Street Map chayniqman apachimuqkunaman, ${osmContributors}.\nRiqsirichimuwayku Open Street Map qutupi llamk’ayta munanki chayqa!";

  static m7(teamMembers) => "Yanapaqkuna: ${teamMembers}";

  static m8(translators) => "Tiqraqkuna: ${translators}";

  static m9(version) => "Versión ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "aboutContent" : MessageLookupByLibrary.simpleMessage("Bolivia suyumantapacha waq jawa suyukunawan jukchasqa kayku, munayku chanta kallpanchayku ima transporte publico ñisqata. Kay thatkichiy ruwasqa kachkan Qhuchapampa jap’iypi, ukhupi jawaman ima, aswan sasata ch’usanaykipaq."),
    "aboutLicenses" : MessageLookupByLibrary.simpleMessage("Licencias"),
    "alertLocationServicesDeniedMessage" : MessageLookupByLibrary.simpleMessage("Celularniyki GPS ñisqayuqchu? Chantapis qhaway Ubicación ñisqa jap’ichisqa kananta."),
    "alertLocationServicesDeniedTitle" : MessageLookupByLibrary.simpleMessage("Kay kiti mana tarikunchu"),
    "chooseLocationPageSubtitle" : MessageLookupByLibrary.simpleMessage("Ñit\'iy mapapi"),
    "chooseLocationPageTitle" : MessageLookupByLibrary.simpleMessage("Mapapi juk kitita riqsichiy"),
    "commonCancel" : MessageLookupByLibrary.simpleMessage("Mana"),
    "commonDestination" : MessageLookupByLibrary.simpleMessage("Mayman"),
    "commonError" : MessageLookupByLibrary.simpleMessage("Pantay"),
    "commonFailLoading" : MessageLookupByLibrary.simpleMessage("Mana aticunchu tariyta datusta"),
    "commonGoOffline" : MessageLookupByLibrary.simpleMessage("Offline"),
    "commonGoOnline" : MessageLookupByLibrary.simpleMessage("Online"),
    "commonNoInternet" : MessageLookupByLibrary.simpleMessage("Mana internet kanchu"),
    "commonOK" : MessageLookupByLibrary.simpleMessage("Ari"),
    "commonOrigin" : MessageLookupByLibrary.simpleMessage("Maymanta"),
    "commonUnknownError" : MessageLookupByLibrary.simpleMessage("Mana yachacunchu ima pantay kasqanta chay"),
    "description" : MessageLookupByLibrary.simpleMessage("Trufis, microspi, buspi ima qhuchapampapi aswan sumaq ch’usanapaq."),
    "errorAmbiguousDestination" : MessageLookupByLibrary.simpleMessage("Ñan wakichiqqa chayana kitiykimanta mana ridsinchu. Kay kitikunamanta chikllay manaqa chayana kitita sut’ita qillqay."),
    "errorAmbiguousOrigin" : MessageLookupByLibrary.simpleMessage("Ñan wakichiqqa qallariy kitiykiqa mana riqsinchu. Kay kitikunamanta chikllay manaqa chayana kitita sut’ita qillqay."),
    "errorAmbiguousOriginDestination" : MessageLookupByLibrary.simpleMessage("Qallariy chanta chayana kitikunata sumaqta akllay, aswan sut’i kay. Kay kitikunamanta chikllay manaqa chayana kitita sut’ita qillqay. Un destino más exacto."),
    "errorNoBarrierFree" : MessageLookupByLibrary.simpleMessage("Qallariy chanta chayana kitikunata mana chukuna tinkuypalluqchu."),
    "errorNoTransitTimes" : MessageLookupByLibrary.simpleMessage("Mana llamk’aq phani kanchu. Ichas mana kay p’unchawpi ruwakuyta atikunmanchu, manaqa mana ñan kanmanchu ch’usanaykipaq."),
    "errorOutOfBoundary" : MessageLookupByLibrary.simpleMessage("Kay ch’usana kitiqa mana ruwakuyta atinchu. Manachu kay llaqtapi mana kasqanta kitita machkhanki?"),
    "errorPathNotFound" : MessageLookupByLibrary.simpleMessage("Kay ch’usana kitiqa mana ruwakuyta atikunchu mana ñan tarikusqanrayku, akllay qallariy chanta chayana kititaqa allin riqsisqa ñankunapi."),
    "errorServerCanNotHandleRequest" : MessageLookupByLibrary.simpleMessage("Mañasqayki kitiqa mana tariyta atikunchu."),
    "errorServerTimeout" : MessageLookupByLibrary.simpleMessage("Kiti mask’aqqa anchata unaykachkan. Watiqmanta juk ratumanta mask’ay."),
    "errorServerUnavailable" : MessageLookupByLibrary.simpleMessage("Qhispichiwasqayku. Kunan pacha, ñan mask’aqqa mana llamk’achkanku. Watiqmanta mask’ay juk ratumanta."),
    "errorTrivialDistance" : MessageLookupByLibrary.simpleMessage("Qallariy chanta chayana kitkunaqa ancha qaylla kachkanku."),
    "errorUnknownDestination" : MessageLookupByLibrary.simpleMessage("Chayana kitiqa mana riqsisqachu. Aswan sut’ita riqsichiy."),
    "errorUnknownOrigin" : MessageLookupByLibrary.simpleMessage("Qallariy kitiqa mana riqsisqachu. Aswan sut’ita riqsichiy."),
    "errorUnknownOriginDestination" : MessageLookupByLibrary.simpleMessage("Qallariy chanta chayana kitikunaqa mana riqsisqachu kanku. Kitiykita aswan sut’ita riqsichiy."),
    "feedbackContent" : MessageLookupByLibrary.simpleMessage("Imayna riqch’asunki Trufi App? Mayk’aqpis pantaykunata tarirqankichu? Riqsiyta munayku! Correo electrónico chanta yupaykita ima riqsirichiwayku sumaqta yanaparisunaykupaq."),
    "feedbackTitle" : MessageLookupByLibrary.simpleMessage("Correo electrónico ñiqta yuyasqasniykita apachimuwayku!"),
    "instructionDistanceKm" : m0,
    "instructionDistanceMeters" : m1,
    "instructionDurationMinutes" : m2,
    "instructionRide" : m3,
    "instructionVehicleBus" : MessageLookupByLibrary.simpleMessage("Bus"),
    "instructionVehicleCar" : MessageLookupByLibrary.simpleMessage("Coche"),
    "instructionVehicleGondola" : MessageLookupByLibrary.simpleMessage("Góndola"),
    "instructionVehicleMicro" : MessageLookupByLibrary.simpleMessage("Micro"),
    "instructionVehicleMinibus" : MessageLookupByLibrary.simpleMessage("Minibus"),
    "instructionVehicleTrufi" : MessageLookupByLibrary.simpleMessage("Trufi"),
    "instructionWalk" : m4,
    "menuAbout" : MessageLookupByLibrary.simpleMessage("Imamanta yachayta munanki?"),
    "menuAppReview" : MessageLookupByLibrary.simpleMessage("Trufi Appta chaninchay"),
    "menuConnections" : MessageLookupByLibrary.simpleMessage("Ñankunata rikhuchiy"),
    "menuFeedback" : MessageLookupByLibrary.simpleMessage("Yuyasqayniykita riqsichiwayku"),
    "menuOnline" : MessageLookupByLibrary.simpleMessage("Online"),
    "menuTeam" : MessageLookupByLibrary.simpleMessage("Ñuqaykumanta"),
    "noRouteError" : MessageLookupByLibrary.simpleMessage("Qhispichiwasqayku. Mana achhaykama ñanta tariyta atikunchu. Imata ruwayta munanki?"),
    "noRouteErrorActionCancel" : MessageLookupByLibrary.simpleMessage("Waq kitiwan watiqmanta mask\'ay"),
    "noRouteErrorActionReportMissingRoute" : MessageLookupByLibrary.simpleMessage("Mana rikhurimuq ñanta riqsichiy"),
    "noRouteErrorActionShowCarRoute" : MessageLookupByLibrary.simpleMessage("Autopaq kay ñanta rikhuchiy"),
    "searchFailLoadingPlan" : MessageLookupByLibrary.simpleMessage("Mana tarikunchu mayninta rinata"),
    "searchHintDestination" : MessageLookupByLibrary.simpleMessage("Chayana kitita akllay"),
    "searchHintOrigin" : MessageLookupByLibrary.simpleMessage("Qallariy kitita akllay"),
    "searchItemChooseOnMap" : MessageLookupByLibrary.simpleMessage("Mapa ñisqapi akllay"),
    "searchItemNoResults" : MessageLookupByLibrary.simpleMessage("Mana tarikunchu"),
    "searchItemYourLocation" : MessageLookupByLibrary.simpleMessage("Kaypi kachkankii"),
    "searchMapMarker" : MessageLookupByLibrary.simpleMessage("Maypi cashani mapapy"),
    "searchPleaseSelectDestination" : MessageLookupByLibrary.simpleMessage("Chayana kitita akllay"),
    "searchPleaseSelectOrigin" : MessageLookupByLibrary.simpleMessage("Qallariy kitita akllay"),
    "searchTitleFavorites" : MessageLookupByLibrary.simpleMessage("Aswan mask\'akuqkuna"),
    "searchTitlePlaces" : MessageLookupByLibrary.simpleMessage("Kitikuna"),
    "searchTitleRecent" : MessageLookupByLibrary.simpleMessage("Musuq mask\'anakuna"),
    "searchTitleResults" : MessageLookupByLibrary.simpleMessage("Mask\'anakuna riqsichiq"),
    "tagline" : MessageLookupByLibrary.simpleMessage("Transporte público en Accra"),
    "teamContent" : MessageLookupByLibrary.simpleMessage("Trufi Association ñisqa kay aplicación Trufi App ñisqata apachimun may chhika yanapaqkunawan. Munankichu Trufi App aswan sumaqman tukunanta? Kayman riqsirichimuwayku:"),
    "teamSectionRepresentatives" : m5,
    "teamSectionRoutes" : m6,
    "teamSectionTeam" : m7,
    "teamSectionTranslations" : m8,
    "title" : MessageLookupByLibrary.simpleMessage("Trufi App"),
    "version" : m9
  };
}
