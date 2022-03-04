


import 'trufi_base_localizations.dart';

/// The translations for Italian (`it`).
class TrufiBaseLocalizationIt extends TrufiBaseLocalization {
  TrufiBaseLocalizationIt([String locale = 'it']) : super(locale);

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
  String get commonConfirmLocation => 'Show on map';

  @override
  String get commonDestination => 'Destinazione';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonError => 'Errore';

  @override
  String get commonFromStation => 'Show on map';

  @override
  String get commonFromStop => 'Show on map';

  @override
  String get commonItineraryNoTransitLegs => 'Show on map';

  @override
  String get commonLeavesAt => 'Leaves';

  @override
  String get commonLoading => 'Show on map';

  @override
  String get commonNoInternet => 'Nessuna connessione internet.';

  @override
  String get commonNoResults => 'Nessun risultato';

  @override
  String get commonOK => 'OK';

  @override
  String get commonOrigin => 'Partenza';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonSave => 'Save';

  @override
  String get commonTomorrow => 'Show on map';

  @override
  String get commonUnknownError => 'Errore sconosciuto';

  @override
  String get commonUnkownPlace => 'Show on map';

  @override
  String get commonWait => 'Wait';

  @override
  String get commonWalk => 'Walk';

  @override
  String get commonYourLocation => 'La tua posizione';

  @override
  String get errorAmbiguousDestination => 'L\'organizzatore di viaggio è indeciso sul luogo di arrivo. Per piacere scegli tra le opzioni seguenti o sii più specifico.';

  @override
  String get errorAmbiguousOrigin => 'L\'organizzatore di viaggio è indeciso sul luogo di partenza. Per piacere scegli tra le opzioni seguenti o sii più specifico.';

  @override
  String get errorAmbiguousOriginDestination => 'Partenza e destinazione sono ambigue. Per piacere scegli tra le opzioni seguenti o sii più specifico.';

  @override
  String get errorNoBarrierFree => 'Partenza e destinazione non accessibili in sedia a rotelle.';

  @override
  String get errorNoConnectServer => 'No connect with server.';

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
  String get followOnFacebook => 'Follow us on Facebook';

  @override
  String get followOnInstagram => 'Follow us on Instagram';

  @override
  String get followOnTwitter => 'Follow us on Twitter';

  @override
  String instructionDistanceKm(Object value) {
    return '$value km';
  }

  @override
  String instructionDistanceMeters(Object value) {
    return '$value m';
  }

  @override
  String instructionDurationHours(Object value) {
    return '$value min';
  }

  @override
  String instructionDurationMinutes(Object value) {
    return '$value min';
  }

  @override
  String get instructionVehicleBike => 'Autobus';

  @override
  String get instructionVehicleBus => 'Autobus';

  @override
  String get instructionVehicleCar => 'Auto';

  @override
  String get instructionVehicleCarpool => 'Autobus';

  @override
  String get instructionVehicleCommuterTrain => 'Autobus';

  @override
  String get instructionVehicleGondola => 'Gondola';

  @override
  String get instructionVehicleLightRail => 'Light Rail Train';

  @override
  String get instructionVehicleMetro => 'Autobus';

  @override
  String get instructionVehicleMicro => 'Micro';

  @override
  String get instructionVehicleMinibus => 'Minibus';

  @override
  String get instructionVehicleTrufi => 'Trufi';

  @override
  String get instructionVehicleWalk => 'Walk';

  @override
  String get menuConnections => 'Route planner';

  @override
  String get menuSocialMedia => 'Social media';

  @override
  String get menuTransportList => 'Mostra itinerari';

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
  String get searchFailLoadingPlan => 'Caricamento itinerario fallito.';

  @override
  String get searchHintDestination => 'Scegli la destinazione';

  @override
  String get searchHintOrigin => 'Scegli un punto di partenza';

  @override
  String get searchPleaseSelectDestination => 'Seleziona destinazione';

  @override
  String get searchPleaseSelectOrigin => 'Seleziona partenza';

  @override
  String shareAppText(Object url, Object appTitle, Object cityName) {
    return 'Download $appTitle, the public transport app for $cityName, at $url';
  }

  @override
  String get themeModeDark => 'Dark Theme';

  @override
  String get themeModeLight => 'Light theme';

  @override
  String get themeModeSystem => 'System Default';
}
