
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
  String get appReviewDialogButtonAccept => '';

  @override
  String get appReviewDialogButtonDecline => '';

  @override
  String get appReviewDialogContent => '';

  @override
  String get appReviewDialogTitle => '';

  @override
  String get chooseLocationPageSubtitle => 'Agrandir et déplacer la carte pour centrer le marqueur';

  @override
  String get chooseLocationPageTitle => 'Choisissez un point sur le plan';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonDestination => 'Destination';

  @override
  String get commonError => 'Erreur';

  @override
  String get commonFailLoading => 'Échec du chargement des données';

  @override
  String get commonGoOffline => 'Se déconnecter';

  @override
  String get commonGoOnline => 'Se connecter';

  @override
  String get commonNoInternet => 'Pas de connexion Internet.';

  @override
  String get commonOK => 'OK';

  @override
  String get commonOrigin => 'Origine';

  @override
  String get commonSave => '';

  @override
  String get commonUnknownError => 'Erreur inconnue';

  @override
  String description(Object cityName) {
    return 'La meilleure façon de se déplacer en trufis, micros et bus dans Cochabamba.';
  }

  @override
  String get donate => '';

  @override
  String get errorAmbiguousDestination => 'Le planificateur de trajet ne sait pas trop à quelle destination vous souhaitez aller. Veuillez choisir parmi les options suivantes ou être plus précis.';

  @override
  String get errorAmbiguousOrigin => 'Le planificateur de trajet n\'est pas sûr du lieu de départ. Veuillez choisir parmi les options suivantes ou être plus précis.';

  @override
  String get errorAmbiguousOriginDestination => 'L\'origine et la destination sont ambiguës. Veuillez choisir parmi les options suivantes ou être plus précis.';

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
  String get followOnFacebook => '';

  @override
  String get followOnInstagram => '';

  @override
  String get followOnTwitter => '';

  @override
  String instructionDistanceKm(Object value) {
    return '${value} km.';
  }

  @override
  String instructionDistanceMeters(Object value) {
    return '${value} m.';
  }

  @override
  String instructionDurationMinutes(Object value) {
    return '${value} min.';
  }

  @override
  String instructionJunction(Object street1, Object street2) {
    return '';
  }

  @override
  String instructionRide(Object vehicle, Object distance, Object duration, Object location) {
    return 'En ${vehicle} pendant ${duration} (${distance}) vers\\n${location}';
  }

  @override
  String get instructionVehicleBus => 'Bus';

  @override
  String get instructionVehicleCar => 'Voiture';

  @override
  String get instructionVehicleGondola => 'Gondole';

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
    return 'Marcher ${duration} (${distance}) vers\\n${location}';
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
  String get menuAbout => 'À propos';

  @override
  String get menuAppReview => 'Évaluer l\'application';

  @override
  String get menuConnections => 'Afficher les itinéraires';

  @override
  String get menuFeedback => 'Envoyer un commentaire';

  @override
  String get menuOnline => 'En ligne';

  @override
  String get menuShareApp => '';

  @override
  String get menuTeam => 'Équipe';

  @override
  String get menuYourPlaces => '';

  @override
  String get noRouteError => 'Désolé, nous n\'avons pas pu trouver d\'itinéraire. Que voulez-vous faire?';

  @override
  String get noRouteErrorActionCancel => 'Essayer une autre destination';

  @override
  String get noRouteErrorActionReportMissingRoute => 'Signaler un itinéraire manquant';

  @override
  String get noRouteErrorActionShowCarRoute => 'Afficher l\'itinéraire en voiture';

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
  String shareAppText(Object url) {
    return '';
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
    return 'Itinéraires: ${routeContributors} et tous les utilisateurs ayant chargé des itinéraires dans OpenStreetMap, tels que ${osmContributors}.\\nContactez-nous si vous souhaitez rejoindre la communauté OpenStreetMap!';
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
  String version(Object version) {
    return 'Version ${version}';
  }
}
