// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr_FR locale. All the
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
  get localeName => 'fr_FR';

  static m0(value) => "${value} km.";

  static m1(value) => "${value} m.";

  static m2(value) => "${value} min.";

  static m3(street1, street2) => "${street1} & ${street2}";

  static m4(vehicle, duration, distance, location) => "En ${vehicle} pendant ${duration} (${distance}) vers\n${location}";

  static m5(duration, distance, location) => "Marcher ${duration} (${distance}) vers\n${location}";

  static m7(representatives) => "Représentants: ${representatives}";

  static m8(routeContributors, osmContributors) => "Itinéraires: ${routeContributors} et tous les utilisateurs ayant chargé des itinéraires dans OpenStreetMap, tels que ${osmContributors}.\nContactez-nous si vous souhaitez rejoindre la communauté OpenStreetMap!";

  static m9(teamMembers) => "Équipe: ${teamMembers}";

  static m10(translators) => "Traductions: ${translators}";

  static m11(version) => "Version ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "aboutContent" : MessageLookupByLibrary.simpleMessage("Nous sommes une équipe bolivienne et internationale de personnes qui aiment et soutiennent les transports en commun. Nous avons développé cette application pour faciliter l\'utilisation du système de transport en commun à Cochabamba et dans les environs."),
    "aboutLicenses" : MessageLookupByLibrary.simpleMessage("Licences"),
    "aboutOpenSource" : MessageLookupByLibrary.simpleMessage("This app is released as open source on GitHub. Feel free to contribute or bring it to your own city."),
    "alertLocationServicesDeniedMessage" : MessageLookupByLibrary.simpleMessage("Assurez-vous que votre appareil dispose d\'un GPS et que les paramètres de localisation sont activés."),
    "alertLocationServicesDeniedTitle" : MessageLookupByLibrary.simpleMessage("Pas d\'emplacement"),
    "chooseLocationPageSubtitle" : MessageLookupByLibrary.simpleMessage("Agrandir et déplacer la carte pour centrer le marqueur"),
    "chooseLocationPageTitle" : MessageLookupByLibrary.simpleMessage("Choisissez un point sur le plan"),
    "commonCancel" : MessageLookupByLibrary.simpleMessage("Annuler"),
    "commonDestination" : MessageLookupByLibrary.simpleMessage("Destination"),
    "commonError" : MessageLookupByLibrary.simpleMessage("Erreur"),
    "commonFailLoading" : MessageLookupByLibrary.simpleMessage("Échec du chargement des données"),
    "commonGoOffline" : MessageLookupByLibrary.simpleMessage("Se déconnecter"),
    "commonGoOnline" : MessageLookupByLibrary.simpleMessage("Se connecter"),
    "commonNoInternet" : MessageLookupByLibrary.simpleMessage("Pas de connexion Internet."),
    "commonOK" : MessageLookupByLibrary.simpleMessage("OK"),
    "commonOrigin" : MessageLookupByLibrary.simpleMessage("Origine"),
    "commonUnknownError" : MessageLookupByLibrary.simpleMessage("Erreur inconnue"),
    "description" : MessageLookupByLibrary.simpleMessage("La meilleure façon de se déplacer en trufis, micros et bus dans Cochabamba."),
    "errorAmbiguousDestination" : MessageLookupByLibrary.simpleMessage("Le planificateur de trajet ne sait pas trop à quelle destination vous souhaitez aller. Veuillez choisir parmi les options suivantes ou être plus précis."),
    "errorAmbiguousOrigin" : MessageLookupByLibrary.simpleMessage("Le planificateur de trajet n\'est pas sûr du lieu de départ. Veuillez choisir parmis les options suivantes ou être plus précis."),
    "errorAmbiguousOriginDestination" : MessageLookupByLibrary.simpleMessage("L\'origine et la destination sont ambiguës. Veuillez choisir parmi les options suivantes ou être plus précis."),
    "errorNoBarrierFree" : MessageLookupByLibrary.simpleMessage("L\'origine et la destination ne sont pas accessibles en chaise roulante."),
    "errorNoTransitTimes" : MessageLookupByLibrary.simpleMessage("Pas de temps de transit disponible. La date peut-être dépassée ou trop tard dans le futur ou il peut ne pas y avoir de service de transit pour votre trajet au moment que vous l\'avez choisi."),
    "errorOutOfBoundary" : MessageLookupByLibrary.simpleMessage("Le trajet n\'est pas possible. Vous essayez peut-être de planifier un trajet en dehors des limites de données cartographiques."),
    "errorPathNotFound" : MessageLookupByLibrary.simpleMessage("Le trajet n\'est pas possible. Votre point de départ ou d\'arrivée peut ne pas être accessible en toute sécurité (par exemple, vous démarrez peut-être dans une rue résidentielle reliée uniquement à une autoroute)."),
    "errorServerCanNotHandleRequest" : MessageLookupByLibrary.simpleMessage("La demande contient des erreurs que le serveur ne veut pas ou ne peut pas traiter."),
    "errorServerTimeout" : MessageLookupByLibrary.simpleMessage("Le planificateur de trajet prend beaucoup trop de temps pour traiter votre demande. Veuillez réessayer plus tard."),
    "errorServerUnavailable" : MessageLookupByLibrary.simpleMessage("Nous sommes désolés. Le planificateur de trajet est temporairement indisponible. Veuillez réessayer plus tard."),
    "errorTrivialDistance" : MessageLookupByLibrary.simpleMessage("L\'origine est à une distance insignifiante de la destination."),
    "errorUnknownDestination" : MessageLookupByLibrary.simpleMessage("La destination est inconnue. Pouvez-vous être un peu plus descriptif?"),
    "errorUnknownOrigin" : MessageLookupByLibrary.simpleMessage("L\'origine est inconnue. Pouvez-vous être un peu plus descriptif?"),
    "errorUnknownOriginDestination" : MessageLookupByLibrary.simpleMessage("L\'origine et la destination sont inconnues. Pouvez-vous être un peu plus descriptif?"),
    "feedbackContent" : MessageLookupByLibrary.simpleMessage("Avez-vous des suggestions pour notre application ou avez-vous trouvé des erreurs dans les données? Nous aimerions le savoir! Assurez-vous d\'ajouter votre adresse électronique ou votre numéro de téléphone pour que nous puissions vous répondre."),
    "feedbackTitle" : MessageLookupByLibrary.simpleMessage("Envoyez-nous un e-mail"),
    "instructionDistanceKm" : m0,
    "instructionDistanceMeters" : m1,
    "instructionDurationMinutes" : m2,
    "instructionJunction" : m3,
    "instructionRide" : m4,
    "instructionVehicleBus" : MessageLookupByLibrary.simpleMessage("Bus"),
    "instructionVehicleCar" : MessageLookupByLibrary.simpleMessage("Voiture"),
    "instructionVehicleGondola" : MessageLookupByLibrary.simpleMessage("Gondole"),
    "instructionVehicleMicro" : MessageLookupByLibrary.simpleMessage("Micro"),
    "instructionVehicleMinibus" : MessageLookupByLibrary.simpleMessage("Minibus"),
    "instructionVehicleTrufi" : MessageLookupByLibrary.simpleMessage("Trufi"),
    "instructionWalk" : m5,
    "menuAbout" : MessageLookupByLibrary.simpleMessage("À propos"),
    "menuAppReview" : MessageLookupByLibrary.simpleMessage("Évaluer l\'application"),
    "menuConnections" : MessageLookupByLibrary.simpleMessage("Afficher les itinéraires"),
    "menuFeedback" : MessageLookupByLibrary.simpleMessage("Envoyer un commentaire"),
    "menuOnline" : MessageLookupByLibrary.simpleMessage("En ligne"),
    "menuTeam" : MessageLookupByLibrary.simpleMessage("Équipe"),
    "noRouteError" : MessageLookupByLibrary.simpleMessage("Désolé, nous n\'avons pas pu trouver d\'itinéraire. Que voulez-vous faire?"),
    "noRouteErrorActionCancel" : MessageLookupByLibrary.simpleMessage("Essayer une autre destination"),
    "noRouteErrorActionReportMissingRoute" : MessageLookupByLibrary.simpleMessage("Signaler un itinéraire manquant"),
    "noRouteErrorActionShowCarRoute" : MessageLookupByLibrary.simpleMessage("Afficher l\'itinéraire en voiture"),
    "searchFailLoadingPlan" : MessageLookupByLibrary.simpleMessage("Échec du chargement du plan."),
    "searchHintDestination" : MessageLookupByLibrary.simpleMessage("Choisissez une destination"),
    "searchHintOrigin" : MessageLookupByLibrary.simpleMessage("Choisissez le point de départ"),
    "searchItemChooseOnMap" : MessageLookupByLibrary.simpleMessage("Choisissez sur la carte"),
    "searchItemNoResults" : MessageLookupByLibrary.simpleMessage("Aucun résultat"),
    "searchItemYourLocation" : MessageLookupByLibrary.simpleMessage("Votre emplacement"),
    "searchMapMarker" : MessageLookupByLibrary.simpleMessage("Position dans le plan"),
    "searchPleaseSelectDestination" : MessageLookupByLibrary.simpleMessage("Sélectionnez la destination"),
    "searchPleaseSelectOrigin" : MessageLookupByLibrary.simpleMessage("Sélectionnez un point de départ"),
    "searchTitleFavorites" : MessageLookupByLibrary.simpleMessage("Favoris"),
    "searchTitlePlaces" : MessageLookupByLibrary.simpleMessage("Endroits"),
    "searchTitleRecent" : MessageLookupByLibrary.simpleMessage("Récent"),
    "searchTitleResults" : MessageLookupByLibrary.simpleMessage("Résultats de la recherche"),
    "tagline" : MessageLookupByLibrary.simpleMessage("Transports en commun à Cochabamba"),
    "teamContent" : MessageLookupByLibrary.simpleMessage("Nous sommes une équipe internationale appelée Trufi Association qui a créé cette application avec l\'aide de nombreux bénévoles! Voulez-vous améliorer l\'application Trufi et faire partie de notre équipe? Merci de nous contacter via:"),
    "teamSectionRepresentatives" : m7,
    "teamSectionRoutes" : m8,
    "teamSectionTeam" : m9,
    "teamSectionTranslations" : m10,
    "title" : MessageLookupByLibrary.simpleMessage("Trufi App"),
    "version" : m11
  };
}
