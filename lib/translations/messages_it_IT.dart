// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a it_IT locale. All the
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
  get localeName => 'it_IT';

  static m0(value) => "${value} km";

  static m1(value) => "${value} m";

  static m2(value) => "${value} min";

  static m3(street1, street2) => "${street1} & ${street2}";

  static m4(vehicle, duration, distance, location) => "Bicicletta ${vehicle} per ${duration} (${distance}) verso\n${location}";

  static m5(duration, distance, location) => "A piedi ${duration} (${distance}) verso\n${location}";

  static m7(representatives) => "Rappresentanti: ${representatives}";

  static m8(routeContributors, osmContributors) => "Rotte: ${routeContributors} e tutti gli utenti che hanno caricato rotte su OpenStreetMap, come ${osmContributors} . Contattaci se vuoi unirti alla comunità OpenStreetMap!";

  static m9(teamMembers) => "Team: ${teamMembers}";

  static m10(translators) => "Traduzioni: ${translators}";

  static m11(version) => "Versione ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "aboutContent" : MessageLookupByLibrary.simpleMessage("Siamo un team boliviano e internazionale di persone che amano e supportano il trasporto pubblico. Abbiamo sviluppato questa app per semplificare l\'uso dei trasporti pubblici a Cochabamba e nelle aree circostanti."),
    "aboutLicenses" : MessageLookupByLibrary.simpleMessage("Licenze"),
    "aboutOpenSource" : MessageLookupByLibrary.simpleMessage("This app is released as open source on GitHub. Feel free to contribute or bring it to your own city."),
    "alertLocationServicesDeniedMessage" : MessageLookupByLibrary.simpleMessage("Assicurati che il tuo device abbia un GPS e geolocalizzazione attivati."),
    "alertLocationServicesDeniedTitle" : MessageLookupByLibrary.simpleMessage("Nessuna posizione"),
    "chooseLocationPageSubtitle" : MessageLookupByLibrary.simpleMessage("Pan & zoom spilli segna mappa"),
    "chooseLocationPageTitle" : MessageLookupByLibrary.simpleMessage("Scegli un punto"),
    "commonCancel" : MessageLookupByLibrary.simpleMessage("Cancella"),
    "commonDestination" : MessageLookupByLibrary.simpleMessage("Destinazione"),
    "commonError" : MessageLookupByLibrary.simpleMessage("Errore"),
    "commonFailLoading" : MessageLookupByLibrary.simpleMessage("Caricamento dati fallito"),
    "commonGoOffline" : MessageLookupByLibrary.simpleMessage("Vai offline"),
    "commonGoOnline" : MessageLookupByLibrary.simpleMessage("Vai online"),
    "commonNoInternet" : MessageLookupByLibrary.simpleMessage("Nessuna connessione internet."),
    "commonOK" : MessageLookupByLibrary.simpleMessage("OK"),
    "commonOrigin" : MessageLookupByLibrary.simpleMessage("Partenza"),
    "commonUnknownError" : MessageLookupByLibrary.simpleMessage("Errore sconosciuto"),
    "description" : MessageLookupByLibrary.simpleMessage("Il miglior modo di viaggiare con trufis, micros e autobus attraverso Cochabamba"),
    "errorAmbiguousDestination" : MessageLookupByLibrary.simpleMessage("L\'organizzatore di viaggio è indeciso sul luogo di arrivo. Per piacere scegli tra le opzioni seguenti o sii più specifico."),
    "errorAmbiguousOrigin" : MessageLookupByLibrary.simpleMessage("L\'organizzatore di viaggio è indeciso sul luogo di partenza. Per piacere scegli tra le opzioni seguenti o sii più specifico."),
    "errorAmbiguousOriginDestination" : MessageLookupByLibrary.simpleMessage("Partenza e destinazione sono ambigue. Per piacere scegli tra le opzioni seguenti o sii più specifico."),
    "errorNoBarrierFree" : MessageLookupByLibrary.simpleMessage("Partenza e destinazione non accessibili in sedia a rotelle."),
    "errorNoTransitTimes" : MessageLookupByLibrary.simpleMessage("Orari di transito non disponibili. La data può essere passata o troppo lontana nel futuro oppure potrebbero non esserci trasporti per il tuo viaggio nell\'orario scelto."),
    "errorOutOfBoundary" : MessageLookupByLibrary.simpleMessage("Viaggio impossibile. Forse stai pianificando un viaggio fuori dai confini della mappa."),
    "errorPathNotFound" : MessageLookupByLibrary.simpleMessage("Viaggio impossibile. Il tuo punto di partenza o di arrivo potrebbe non essere accessibile in sicurezza (ad esempio potresti star partendo da una strada residenziale connessa solo con autostrade)."),
    "errorServerCanNotHandleRequest" : MessageLookupByLibrary.simpleMessage("La richiesta presenta errori che il server non vuole o non può processare."),
    "errorServerTimeout" : MessageLookupByLibrary.simpleMessage("L\'organizzatore di viaggio sta impiegando troppo tempo per processare la tua richiesta. Per piacere prova di nuovo più tardi."),
    "errorServerUnavailable" : MessageLookupByLibrary.simpleMessage("Ci dispiace. L\'organizzatore di viaggio è temporaneamente non disponibile. Prova più tardi."),
    "errorTrivialDistance" : MessageLookupByLibrary.simpleMessage("La partenza si trova ad una distanza insignificante dall\'arrivo."),
    "errorUnknownDestination" : MessageLookupByLibrary.simpleMessage("Destinazione sconosciuta. Puoi darci qualche indicazione in più?"),
    "errorUnknownOrigin" : MessageLookupByLibrary.simpleMessage("Partenza sconosciuta. Puoi darci qualche indicazione in più?"),
    "errorUnknownOriginDestination" : MessageLookupByLibrary.simpleMessage("Partenza e destinazione sconosciute. Puoi darci qualche indicazione in più?"),
    "feedbackContent" : MessageLookupByLibrary.simpleMessage("Hai suggerimenti per la nostra app o hai trovato errori nei dati? Ci piacerebbe avere tue notizie! Ricordati di inserire il tuo indirizzo e-mail o telefono, così potremo risponderti."),
    "feedbackTitle" : MessageLookupByLibrary.simpleMessage("Inviaci un\'E-mail"),
    "instructionDistanceKm" : m0,
    "instructionDistanceMeters" : m1,
    "instructionDurationMinutes" : m2,
    "instructionJunction" : m3,
    "instructionRide" : m4,
    "instructionVehicleBus" : MessageLookupByLibrary.simpleMessage("Autobus"),
    "instructionVehicleCar" : MessageLookupByLibrary.simpleMessage("Auto"),
    "instructionVehicleGondola" : MessageLookupByLibrary.simpleMessage("Gondola"),
    "instructionVehicleMicro" : MessageLookupByLibrary.simpleMessage("Micro"),
    "instructionVehicleMinibus" : MessageLookupByLibrary.simpleMessage("Minibus"),
    "instructionVehicleTrufi" : MessageLookupByLibrary.simpleMessage("Trufi"),
    "instructionWalk" : m5,
    "menuAbout" : MessageLookupByLibrary.simpleMessage("A proposito"),
    "menuAppReview" : MessageLookupByLibrary.simpleMessage("Valuta l\'app"),
    "menuConnections" : MessageLookupByLibrary.simpleMessage("Mostra itinerari"),
    "menuFeedback" : MessageLookupByLibrary.simpleMessage("Invia Feedback"),
    "menuOnline" : MessageLookupByLibrary.simpleMessage("Online"),
    "menuTeam" : MessageLookupByLibrary.simpleMessage("Squadra"),
    "noRouteError" : MessageLookupByLibrary.simpleMessage("Scusa, non siamo riusciti a trovare un itinerario. Che cosa vuoi fare?"),
    "noRouteErrorActionCancel" : MessageLookupByLibrary.simpleMessage("Prova un\'altra destinazione"),
    "noRouteErrorActionReportMissingRoute" : MessageLookupByLibrary.simpleMessage("Segnala una strada mancante"),
    "noRouteErrorActionShowCarRoute" : MessageLookupByLibrary.simpleMessage("Mostra strada in auto"),
    "searchFailLoadingPlan" : MessageLookupByLibrary.simpleMessage("Caricamento itinerario fallito."),
    "searchHintDestination" : MessageLookupByLibrary.simpleMessage("Scegli la destinazione"),
    "searchHintOrigin" : MessageLookupByLibrary.simpleMessage("Scegli un punto di partenza"),
    "searchItemChooseOnMap" : MessageLookupByLibrary.simpleMessage("Scegli sulla mappa"),
    "searchItemNoResults" : MessageLookupByLibrary.simpleMessage("Nessun risultato"),
    "searchItemYourLocation" : MessageLookupByLibrary.simpleMessage("La tua posizione"),
    "searchMapMarker" : MessageLookupByLibrary.simpleMessage("Punta sulla Mappa"),
    "searchPleaseSelectDestination" : MessageLookupByLibrary.simpleMessage("Seleziona destinazione"),
    "searchPleaseSelectOrigin" : MessageLookupByLibrary.simpleMessage("Seleziona partenza"),
    "searchTitleFavorites" : MessageLookupByLibrary.simpleMessage("Preferiti"),
    "searchTitlePlaces" : MessageLookupByLibrary.simpleMessage("Luoghi"),
    "searchTitleRecent" : MessageLookupByLibrary.simpleMessage("Recenti"),
    "searchTitleResults" : MessageLookupByLibrary.simpleMessage("Cerca Risultati"),
    "tagline" : MessageLookupByLibrary.simpleMessage("Trasporto pubblico a Cochabamba"),
    "teamContent" : MessageLookupByLibrary.simpleMessage("Siamo un team internazionale chiamato Trufi Association che ha creato questa app con l\'aiuto di molti volontari! Vuoi migliorare l\'app Trufi ed essere parte del nostro team? Vi preghiamo di contattarci tramite:"),
    "teamSectionRepresentatives" : m7,
    "teamSectionRoutes" : m8,
    "teamSectionTeam" : m9,
    "teamSectionTranslations" : m10,
    "title" : MessageLookupByLibrary.simpleMessage("Trufi App"),
    "version" : m11
  };
}
