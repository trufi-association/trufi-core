
// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'trufi_localization.dart';

// ignore_for_file: unnecessary_brace_in_string_interps

/// The translations for Italian (`it`).
class TrufiLocalizationIt extends TrufiLocalization {
  TrufiLocalizationIt([String locale = 'it']) : super(locale);

  @override
  String get aboutContent => 'Siamo un team boliviano e internazionale di persone che amano e supportano il trasporto pubblico. Abbiamo sviluppato questa app per semplificare l\'uso dei trasporti pubblici a Cochabamba e nelle aree circostanti.';

  @override
  String get aboutLicenses => 'Licenze';

  @override
  String get aboutOpenSource => 'Questa applicazione viene rilasciata come open source su GitHub. Sentitevi liberi di contribuire o di portarlo nella vostra città.';

  @override
  String get alertLocationServicesDeniedMessage => 'Assicurati che il tuo device abbia un GPS e geolocalizzazione attivati.';

  @override
  String get alertLocationServicesDeniedTitle => 'Nessuna posizione';

  @override
  String get appReviewDialogButtonAccept => 'Write review';

  @override
  String get appReviewDialogButtonDecline => 'Not now';

  @override
  String get appReviewDialogContent => 'Support us with a review on the Google Play Store.';

  @override
  String get appReviewDialogTitle => 'Enjoying Trufi?';

  @override
  String get chooseLocationPageSubtitle => 'Pan & zoom spilli segna mappa';

  @override
  String get chooseLocationPageTitle => 'Scegli un punto';

  @override
  String get commonCancel => 'Cancella';

  @override
  String get commonDestination => 'Destinazione';

  @override
  String get commonError => 'Errore';

  @override
  String get commonFailLoading => 'Caricamento dati fallito';

  @override
  String get commonGoOffline => 'Vai offline';

  @override
  String get commonGoOnline => 'Vai online';

  @override
  String get commonNoInternet => 'Nessuna connessione internet.';

  @override
  String get commonOK => 'OK';

  @override
  String get commonOrigin => 'Partenza';

  @override
  String get commonSave => 'Save';

  @override
  String get commonUnknownError => 'Errore sconosciuto';

  @override
  String description(Object cityName) {
    return 'Il miglior modo di viaggiare con trufis, micros e autobus attraverso Cochabamba';
  }

  @override
  String get donate => 'Donate';

  @override
  String get errorAmbiguousDestination => 'L\'organizzatore di viaggio è indeciso sul luogo di arrivo. Per piacere scegli tra le opzioni seguenti o sii più specifico.';

  @override
  String get errorAmbiguousOrigin => 'L\'organizzatore di viaggio è indeciso sul luogo di partenza. Per piacere scegli tra le opzioni seguenti o sii più specifico.';

  @override
  String get errorAmbiguousOriginDestination => 'Partenza e destinazione sono ambigue. Per piacere scegli tra le opzioni seguenti o sii più specifico.';

  @override
  String get errorNoBarrierFree => 'Partenza e destinazione non accessibili in sedia a rotelle.';

  @override
  String get errorNoTransitTimes => 'Orari di transito non disponibili. La data può essere passata o troppo lontana nel futuro oppure potrebbero non esserci trasporti per il tuo viaggio nell\'orario scelto.';

  @override
  String get errorOutOfBoundary => 'Viaggio impossibile. Forse stai pianificando un viaggio fuori dai confini della mappa.';

  @override
  String get errorPathNotFound => 'Viaggio impossibile. Il tuo punto di partenza o di arrivo potrebbe non essere accessibile in sicurezza (ad esempio potresti star partendo da una strada residenziale connessa solo con autostrade).';

  @override
  String get errorServerCanNotHandleRequest => 'La richiesta presenta errori che il server non vuole o non può processare.';

  @override
  String get errorServerTimeout => 'L\'organizzatore di viaggio sta impiegando troppo tempo per processare la tua richiesta. Per piacere prova di nuovo più tardi.';

  @override
  String get errorServerUnavailable => 'Ci dispiace. L\'organizzatore di viaggio è temporaneamente non disponibile. Prova più tardi.';

  @override
  String get errorTrivialDistance => 'La partenza si trova ad una distanza insignificante dall\'arrivo.';

  @override
  String get errorUnknownDestination => 'Destinazione sconosciuta. Puoi darci qualche indicazione in più?';

  @override
  String get errorUnknownOrigin => 'Partenza sconosciuta. Puoi darci qualche indicazione in più?';

  @override
  String get errorUnknownOriginDestination => 'Partenza e destinazione sconosciute. Puoi darci qualche indicazione in più?';

  @override
  String get feedbackContent => 'Hai suggerimenti per la nostra app o hai trovato errori nei dati? Ci piacerebbe avere tue notizie! Ricordati di inserire il tuo indirizzo e-mail o telefono, così potremo risponderti.';

  @override
  String get feedbackTitle => 'Inviaci un\'E-mail';

  @override
  String get followOnFacebook => 'Follow us on Facebook';

  @override
  String get followOnInstagram => 'Follow us on Instagram';

  @override
  String get followOnTwitter => 'Follow us on Twitter';

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
    return '${street1} and ${street2}';
  }

  @override
  String instructionRide(Object vehicle, Object distance, Object duration, Object location) {
    return 'Bicicletta ${vehicle} per ${duration} (${distance}) verso\n${location}';
  }

  @override
  String get instructionVehicleBus => 'Autobus';

  @override
  String get instructionVehicleCar => 'Auto';

  @override
  String get instructionVehicleGondola => 'Gondola';

  @override
  String get instructionVehicleLightRail => 'Light Rail Train';

  @override
  String get instructionVehicleMicro => 'Micro';

  @override
  String get instructionVehicleMinibus => 'Minibus';

  @override
  String get instructionVehicleTrufi => 'Trufi';

  @override
  String instructionWalk(Object distance, Object duration, Object location) {
    return 'A piedi ${duration} (${distance}) verso\n${location}';
  }

  @override
  String get mapTypeLabel => 'Map Type';

  @override
  String get mapTypeSatelliteCaption => 'Satellite';

  @override
  String get mapTypeStreetsCaption => 'Streets';

  @override
  String get mapTypeTerrainCaption => 'Terrain';

  @override
  String get menuAbout => 'A proposito';

  @override
  String get menuAppReview => 'Valuta l\'app';

  @override
  String get menuConnections => 'Mostra itinerari';

  @override
  String get menuFeedback => 'Invia Feedback';

  @override
  String get menuOnline => 'Online';

  @override
  String get menuShareApp => 'Share the app';

  @override
  String get menuTeam => 'Squadra';

  @override
  String get menuYourPlaces => 'I tuoi posti';

  @override
  String get noRouteError => 'Scusa, non siamo riusciti a trovare un itinerario. Che cosa vuoi fare?';

  @override
  String get noRouteErrorActionCancel => 'Prova un\'altra destinazione';

  @override
  String get noRouteErrorActionReportMissingRoute => 'Segnala una strada mancante';

  @override
  String get noRouteErrorActionShowCarRoute => 'Mostra strada in auto';

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
  String get searchFailLoadingPlan => 'Caricamento itinerario fallito.';

  @override
  String get searchHintDestination => 'Scegli la destinazione';

  @override
  String get searchHintOrigin => 'Scegli un punto di partenza';

  @override
  String get searchItemChooseOnMap => 'Scegli sulla mappa';

  @override
  String get searchItemNoResults => 'Nessun risultato';

  @override
  String get searchItemYourLocation => 'La tua posizione';

  @override
  String get searchMapMarker => 'Punta sulla Mappa';

  @override
  String get searchPleaseSelectDestination => 'Seleziona destinazione';

  @override
  String get searchPleaseSelectOrigin => 'Seleziona partenza';

  @override
  String get searchTitleFavorites => 'Preferiti';

  @override
  String get searchTitlePlaces => 'Luoghi';

  @override
  String get searchTitleRecent => 'Recenti';

  @override
  String get searchTitleResults => 'Cerca Risultati';

  @override
  String shareAppText(Object url, Object appTitle, Object cityName) {
    return 'Download ${appTitle}, the public transport app for ${cityName}, at ${url}';
  }

  @override
  String tagline(Object city) {
    return 'Trasporto pubblico a Cochabamba';
  }

  @override
  String get teamContent => 'Siamo un team internazionale chiamato Trufi Association che ha creato questa app con l\'aiuto di molti volontari! Vuoi migliorare l\'app Trufi ed essere parte del nostro team? Vi preghiamo di contattarci tramite:';

  @override
  String teamSectionRepresentatives(Object representatives) {
    return 'Rappresentanti: ${representatives}';
  }

  @override
  String teamSectionRoutes(Object osmContributors, Object routeContributors) {
    return 'Rotte: ${routeContributors} e tutti gli utenti che hanno caricato rotte su OpenStreetMap, come ${osmContributors} . Contattaci se vuoi unirti alla comunità OpenStreetMap!';
  }

  @override
  String teamSectionTeam(Object teamMembers) {
    return 'Team: ${teamMembers}';
  }

  @override
  String teamSectionTranslations(Object translators) {
    return 'Traduzioni: ${translators}';
  }

  @override
  String get title => 'Trufi App';

  @override
  String version(Object version) {
    return 'Versione ${version}';
  }
}
