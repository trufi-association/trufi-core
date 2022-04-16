


import 'trufi_base_localizations.dart';

/// The translations for French (`fr`).
class TrufiBaseLocalizationFr extends TrufiBaseLocalization {
  TrufiBaseLocalizationFr([String locale = 'fr']) : super(locale);

  @override
  String get alertLocationServicesDeniedMessage => 'Assurez-vous que votre appareil dispose d\'un GPS et que les paramètres de localisation sont activés.';

  @override
  String get alertLocationServicesDeniedTitle => 'Pas d\'emplacement';

  @override
  String get appReviewDialogButtonAccept => 'Write review';

  @override
  String get appReviewDialogButtonDecline => 'Not now';

  @override
  String get appReviewDialogContent => 'Support us with a review on the Google Play Store.';

  @override
  String get appReviewDialogTitle => 'Enjoying Trufi?';

  @override
  String get chooseLocationPageSubtitle => 'Agrandir et déplacer la carte pour centrer le marqueur';

  @override
  String get chooseLocationPageTitle => 'Choisissez un point sur le plan';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonConfirmLocation => 'Show on map';

  @override
  String get commonDestination => 'Destination';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonError => 'Erreur';

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
  String get commonNoInternet => 'Pas de connexion Internet.';

  @override
  String get commonNoResults => 'Aucun résultat';

  @override
  String get commonOK => 'OK';

  @override
  String get commonOrigin => 'Origine';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonSave => 'Save';

  @override
  String get commonTomorrow => 'Show on map';

  @override
  String get commonUnknownError => 'Erreur inconnue';

  @override
  String get commonUnkownPlace => 'Show on map';

  @override
  String get commonWait => 'Wait';

  @override
  String get commonWalk => 'Walk';

  @override
  String get commonYourLocation => 'Votre emplacement';

  @override
  String get errorAmbiguousDestination => 'Le planificateur de trajet ne sait pas trop à quelle destination vous souhaitez aller. Veuillez choisir parmi les options suivantes ou être plus précis.';

  @override
  String get errorAmbiguousOrigin => 'Le planificateur de trajet n\'est pas sûr du lieu de départ. Veuillez choisir parmi les options suivantes ou être plus précis.';

  @override
  String get errorAmbiguousOriginDestination => 'L\'origine et la destination sont ambiguës. Veuillez choisir parmi les options suivantes ou être plus précis.';

  @override
  String get errorNoBarrierFree => 'L\'origine et la destination ne sont pas accessibles en fauteuil roulant.';

  @override
  String get errorNoConnectServer => 'No connect with server.';

  @override
  String get errorNoTransitTimes => 'Pas de temps de transit disponible. La date peut-être dépassée ou trop tard dans le futur ou il peut ne pas y avoir de service de transit pour votre trajet au moment que vous l\'avez choisi.';

  @override
  String get errorOutOfBoundary => 'Le trajet n\'est pas possible. Vous essayez peut-être de planifier un trajet en dehors des limites de données cartographiques.';

  @override
  String get errorPathNotFound => 'Le trajet n\'est pas possible. Votre point de départ ou d\'arrivée peut ne pas être accessible en toute sécurité (par exemple, vous démarrez peut-être dans une rue résidentielle reliée uniquement à une autoroute).';

  @override
  String get errorServerCanNotHandleRequest => 'La demande contient des erreurs que le serveur ne veut pas ou ne peut pas traiter.';

  @override
  String get errorServerTimeout => 'Le planificateur de trajet prend beaucoup trop de temps pour traiter votre demande. Veuillez réessayer plus tard.';

  @override
  String get errorServerUnavailable => 'Nous sommes désolés. Le planificateur de trajet est temporairement indisponible. Veuillez réessayer plus tard.';

  @override
  String get errorTrivialDistance => 'L\'origine est à une distance insignifiante de la destination.';

  @override
  String get errorUnknownDestination => 'La destination est inconnue. Pouvez-vous être un peu plus descriptif?';

  @override
  String get errorUnknownOrigin => 'L\'origine est inconnue. Pouvez-vous être un peu plus descriptif?';

  @override
  String get errorUnknownOriginDestination => 'L\'origine et la destination sont inconnues. Pouvez-vous être un peu plus descriptif?';

  @override
  String get followOnFacebook => 'Follow us on Facebook';

  @override
  String get followOnInstagram => 'Follow us on Instagram';

  @override
  String get followOnTwitter => 'Follow us on Twitter';

  @override
  String instructionDistanceKm(Object value) {
    return '$value km.';
  }

  @override
  String instructionDistanceMeters(Object value) {
    return '$value m.';
  }

  @override
  String instructionDurationHours(Object value) {
    return '$value min.';
  }

  @override
  String instructionDurationMinutes(Object value) {
    return '$value min.';
  }

  @override
  String get instructionVehicleBike => 'Bus';

  @override
  String get instructionVehicleBus => 'Bus';

  @override
  String get instructionVehicleCar => 'Voiture';

  @override
  String get instructionVehicleCarpool => 'Bus';

  @override
  String get instructionVehicleCommuterTrain => 'Bus';

  @override
  String get instructionVehicleGondola => 'Gondole';

  @override
  String get instructionVehicleLightRail => 'Light Rail Train';

  @override
  String get instructionVehicleMetro => 'Bus';

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
  String get menuTransportList => 'Afficher les itinéraires';

  @override
  String get noRouteError => 'Désolé, nous n\'avons pas pu trouver d\'itinéraire. Que voulez-vous faire?';

  @override
  String get noRouteErrorActionCancel => 'Essayer une autre destination';

  @override
  String get noRouteErrorActionReportMissingRoute => 'Signaler un itinéraire manquant';

  @override
  String get noRouteErrorActionShowCarRoute => 'Afficher l\'itinéraire en voiture';

  @override
  String get readOurBlog => 'Read our blog';

  @override
  String get searchFailLoadingPlan => 'Échec du chargement du plan.';

  @override
  String get searchHintDestination => 'Choisissez une destination';

  @override
  String get searchHintOrigin => 'Choisissez le point de départ';

  @override
  String get searchPleaseSelectDestination => 'Sélectionnez la destination';

  @override
  String get searchPleaseSelectOrigin => 'Sélectionnez un point de départ';

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
