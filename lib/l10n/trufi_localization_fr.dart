
// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'trufi_localization.dart';

// ignore_for_file: unnecessary_brace_in_string_interps

/// The translations for French (`fr`).
class TrufiLocalizationFr extends TrufiLocalization {
  TrufiLocalizationFr([String locale = 'fr']) : super(locale);

  @override
  String get aboutContent => 'Nous sommes une équipe bolivienne et internationale de personnes qui aiment et soutiennent les transports en commun. Nous avons développé cette application pour faciliter l\'utilisation du système de transport en commun à Cochabamba et dans les environs.';

  @override
  String get aboutLicenses => 'Licences';

  @override
  String get aboutOpenSource => 'Cette application est publiée en open source sur GitHub. N\'hésitez pas à contribuer ou à l\'apporter dans votre propre ville.';

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
  String get bikeRentalBikeStation => 'Bike station';

  @override
  String get bikeRentalFetchRentalBike => 'Fetch a rental bike:';

  @override
  String get bikeRentalNetworkFreeFloating => 'Destination is not a designated drop-off area. Rental cannot be completed here. Please check terms & conditions for additional fees.';

  @override
  String get carParkCloseCapacityMessage => 'This car park is close to capacity. Please allow additional time for you journey.';

  @override
  String get carParkExcludeFull => 'Exclude full car parks';

  @override
  String get chooseLocationPageSubtitle => 'Agrandir et déplacer la carte pour centrer le marqueur';

  @override
  String get chooseLocationPageTitle => 'Choisissez un point sur le plan';

  @override
  String get commonArrival => 'Arrival';

  @override
  String get commonBikesAvailable => 'Show on map';

  @override
  String get commonCall => 'Show on map';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonCitybikes => 'Citybikes';

  @override
  String get commonConfirmLocation => 'Show on map';

  @override
  String get commonCustomPlaces => 'Custom places';

  @override
  String get commonDeparture => 'Departure';

  @override
  String get commonDestination => 'Destination';

  @override
  String get commonDetails => 'Walk';

  @override
  String get commonError => 'Erreur';

  @override
  String get commonFailLoading => 'Échec du chargement des données';

  @override
  String get commonFavoritePlaces => 'Favorite places';

  @override
  String get commonFromStation => 'Show on map';

  @override
  String get commonFromStop => 'Show on map';

  @override
  String get commonGoOffline => 'Se déconnecter';

  @override
  String get commonGoOnline => 'Se connecter';

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
  String get commonNoInternet => 'Pas de connexion Internet.';

  @override
  String get commonNow => 'Show on map';

  @override
  String get commonOK => 'OK';

  @override
  String get commonOnDemandTaxi => 'Show on map';

  @override
  String get commonOrigin => 'Origine';

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
  String get commonUnknownError => 'Erreur inconnue';

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
    return 'Version {version}';
  }

  @override
  String get defaultLocationHome => 'Home';

  @override
  String get defaultLocationWork => 'Work';

  @override
  String departureBikeStation(Object departureStop, Object departureTime) {
    return 'Itinéraires: {routeContributors} et tous les utilisateurs ayant chargé des itinéraires dans OpenStreetMap, tels que {osmContributors}.\nContactez-nous si vous souhaitez rejoindre la communauté OpenStreetMap!';
  }

  @override
  String description(Object cityName) {
    return 'La meilleure façon de se déplacer en trufis, micros et bus dans Cochabamba.';
  }

  @override
  String get donate => 'Donate';

  @override
  String get errorAmbiguousDestination => 'Le planificateur de trajet ne sait pas trop à quelle destination vous souhaitez aller. Veuillez choisir parmi les options suivantes ou être plus précis.';

  @override
  String get errorAmbiguousOrigin => 'Le planificateur de trajet n\'est pas sûr du lieu de départ. Veuillez choisir parmi les options suivantes ou être plus précis.';

  @override
  String get errorAmbiguousOriginDestination => 'L\'origine et la destination sont ambiguës. Veuillez choisir parmi les options suivantes ou être plus précis.';

  @override
  String get errorCancelledByUser => 'Canceled by user';

  @override
  String get errorEmailFeedback => 'Could not open mail feedback app, the URL or email is incorrect';

  @override
  String get errorNoBarrierFree => 'L\'origine et la destination ne sont pas accessibles en fauteuil roulant.';

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
  String get feedbackContent => 'Avez-vous des suggestions pour notre application ou avez-vous trouvé des erreurs dans les données? Nous aimerions le savoir! Assurez-vous d\'ajouter votre adresse électronique ou votre numéro de téléphone pour que nous puissions vous répondre.';

  @override
  String get feedbackTitle => 'Envoyez-nous un e-mail';

  @override
  String get fetchMoreItinerariesEarlierDepartures => 'Earlier departures';

  @override
  String get fetchMoreItinerariesLaterDeparturesTitle => 'Later departures';

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
  String get infoMessageOnlyCyclingRoutes => 'Your search returned only cycling routes.';

  @override
  String get infoMessageOnlyWalkingCyclingRoutes => 'Your search returned only walking and cycling routes.';

  @override
  String get infoMessageOnlyWalkingRoutes => 'Your search returned only walking routes.';

  @override
  String get infoMessageOriginOutsideService => 'No route suggestions were found because the origin is outside the service area.';

  @override
  String get infoMessageUseNationalServicePrefix => 'We recommend you try the national journey planner,';

  @override
  String instructionDistanceKm(Object value) {
    return '${value} km.';
  }

  @override
  String instructionDistanceMeters(Object value) {
    return '${value} m.';
  }

  @override
  String instructionDurationHours(Object value) {
    return '${value} min.';
  }

  @override
  String instructionDurationMinutes(Object value) {
    return '${value} min.';
  }

  @override
  String instructionJunction(Object street1, Object street2) {
    return '${street1} and ${street2}';
  }

  @override
  String instructionRide(Object vehicle, Object distance, Object duration, Object location) {
    return 'En ${vehicle} pendant ${duration} (${distance}) vers\n${location}';
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
  String get instructionVehicleOnCar => 'Voiture';

  @override
  String get instructionVehicleSharing => 'Bus';

  @override
  String get instructionVehicleSharingCarSharing => 'Bus';

  @override
  String get instructionVehicleSharingRegioRad => 'Bus';

  @override
  String get instructionVehicleSharingTaxi => 'Bus';

  @override
  String get instructionVehicleTaxi => 'Voiture';

  @override
  String get instructionVehicleTrufi => 'Trufi';

  @override
  String instructionWalk(Object distance, Object duration, Object location) {
    return 'Marcher ${duration} (${distance}) vers\n${location}';
  }

  @override
  String get itineraryBuyTicket => 'Buy tickets';

  @override
  String get itineraryMissingPrice => 'No price information';

  @override
  String get itineraryPriceOnlyPublicTransport => 'Price only valid for public transport part of the journey.';

  @override
  String get itinerarySummaryBikeAndPublicRailSubwayTitle => 'Take your bike with you on the train or to metro';

  @override
  String get itinerarySummaryBikeParkTitle => 'Leave your bike at a Park & Ride';

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
  String get menuAbout => 'À propos';

  @override
  String get menuAppReview => 'Évaluer l\'application';

  @override
  String get menuConnections => 'Afficher les itinéraires';

  @override
  String get listofBusses => 'Liste des bus';

  @override
  String get menuFeedback => 'Envoyer un commentaire';

  @override
  String get menuOnline => 'En ligne';

  @override
  String get menuShareApp => 'Share the app';

  @override
  String get menuTeam => 'Équipe';

  @override
  String get menuYourPlaces => 'Vos lieux';

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
  String get searchFailLoadingPlan => 'Échec du chargement du plan.';

  @override
  String get searchHintDestination => 'Choisissez une destination';

  @override
  String get searchHintOrigin => 'Choisissez le point de départ';

  @override
  String get searchItemChooseOnMap => 'Choisissez sur la carte';

  @override
  String get searchItemNoResults => 'Aucun résultat';

  @override
  String get searchItemYourLocation => 'Votre emplacement';

  @override
  String get searchMapMarker => 'Position dans le plan';

  @override
  String get searchPleaseSelectDestination => 'Sélectionnez la destination';

  @override
  String get searchPleaseSelectOrigin => 'Sélectionnez un point de départ';

  @override
  String get searchTitleFavorites => 'Favoris';

  @override
  String get searchTitlePlaces => 'Endroits';

  @override
  String get searchTitleRecent => 'Récent';

  @override
  String get searchTitleResults => 'Résultats de la recherche';

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
    return 'Transports en commun à Cochabamba';
  }

  @override
  String get teamContent => 'Nous sommes une équipe internationale appelée Trufi Association qui a créé cette application avec l\'aide de nombreux bénévoles! Voulez-vous améliorer l\'application Trufi et faire partie de notre équipe? Merci de nous contacter via:';

  @override
  String teamSectionRepresentatives(Object representatives) {
    return 'Représentants: ${representatives}';
  }

  @override
  String teamSectionRoutes(Object osmContributors, Object routeContributors) {
    return 'Itinéraires: ${routeContributors} et tous les utilisateurs ayant chargé des itinéraires dans OpenStreetMap, tels que ${osmContributors}.\nContactez-nous si vous souhaitez rejoindre la communauté OpenStreetMap!';
  }

  @override
  String teamSectionTeam(Object teamMembers) {
    return 'Équipe: ${teamMembers}';
  }

  @override
  String teamSectionTranslations(Object translators) {
    return 'Traductions: ${translators}';
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
    return 'Version ${version}';
  }
}
