
// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'trufi_localization.dart';

// ignore_for_file: unnecessary_brace_in_string_interps

/// The translations for German (`de`).
class TrufiLocalizationDe extends TrufiLocalization {
  TrufiLocalizationDe([String locale = 'de']) : super(locale);

  @override
  String get aboutContent => 'Wir sind ein bolivianisches und internationales Team, das den öffentlichen Nahverkehr liebt und unterstützen möchte. Wir haben diese App entwickelt, um den Menschen die Verwendung des öffentlichen Nahverkehrs in Cochabamba und der näheren Umgebung zu erleichtern.';

  @override
  String get aboutLicenses => 'Lizenzen';

  @override
  String get aboutOpenSource => 'Diese App ist Open Source und auf GitHub verfügbar. Zögere nicht, einen Beitrag zu leisten oder bringe sie in Deine Stadt!';

  @override
  String get alertLocationServicesDeniedMessage => 'Bitte vergewissere dich, dass du ein GPS Signal empfängst und die Ortungsdienste aktiviert sind.';

  @override
  String get alertLocationServicesDeniedTitle => 'Kein Standort';

  @override
  String get appReviewDialogButtonAccept => 'Bewerten';

  @override
  String get appReviewDialogButtonDecline => 'Jetzt nicht';

  @override
  String get appReviewDialogContent => 'Unterstütze uns mit einer Bewertung im Google Play Store.';

  @override
  String get appReviewDialogTitle => 'Magst du Trufi?';

  @override
  String get chooseLocationPageSubtitle => 'Karte unter Markierung schwenken und zoomen';

  @override
  String get chooseLocationPageTitle => 'Ort auswählen';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonDestination => 'Fahrtziel';

  @override
  String get commonError => 'Fehler';

  @override
  String get commonFailLoading => 'Fehler beim Laden der Daten';

  @override
  String get commonGoOffline => 'Offline gehen';

  @override
  String get commonGoOnline => 'Online gehen';

  @override
  String get commonNoInternet => 'Keine Internetverbindung.';

  @override
  String get commonOK => 'OK';

  @override
  String get commonOrigin => 'Startpunkt';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonUnknownError => 'Unbekannter Fehler';

  @override
  String description(Object cityName) {
    return 'Der beste Weg mit Trufis, Mikros und Bussen durch ${cityName} zu reisen.';
  }

  @override
  String get donate => 'Spenden';

  @override
  String get errorAmbiguousDestination => 'Der Reiseplaner weiß nicht genau, zu welchem Ort Sie fahren möchten. Bitte wählen Sie aus den folgenden Optionen eine aus oder geben Sie eine genauere Beschreibung an.';

  @override
  String get errorAmbiguousOrigin => 'Der Reiseplaner weiß nicht genau, von welchem Ort aus Sie starten möchten. Bitte wählen Sie aus den folgenden Optionen eine aus oder geben Sie eine genauere Beschreibung an.';

  @override
  String get errorAmbiguousOriginDestination => 'Der Startpunkt und das Ziel sind unklar. Bitte wählen Sie aus den folgenden Optionen eine aus oder geben Sie eine genauere Beschreibung an.';

  @override
  String get errorEmailFeedback => 'Die Feedback App konnte nicht geöffnet werden, die URL oder die E-Mail ist nicht korrekt.';

  @override
  String get errorNoBarrierFree => 'Der Startpunkt und das Ziel sind nicht für Rollstuhlfahrer zugänglich.';

  @override
  String get errorNoTransitTimes => 'Keine Abfahrtszeiten verfügbar. Das Datum liegt eventuell zu weit in der Vergangenheit oder der Zukunft oder es gibt keinen Transitservice zu dem von Ihnen gewählten Zeitpunkt.';

  @override
  String get errorOutOfBoundary => 'Dieser Trip ist nicht möglich. Sie versuchen möglicherweise eine Reise außerhalb der verfügbaren Kartendaten zu planen.';

  @override
  String get errorPathNotFound => 'Dieser Trip ist nicht möglich. Ihr Start- oder Endpunkt ist möglicherweise nicht sicher zugänglich (dies ist beispielsweise der Fall, wenn Sie sich in einer Wohnstraße befinden, die nur mit einer Autobahn verbunden ist).';

  @override
  String get errorServerCanNotHandleRequest => 'Die Anfrage enthält Fehler, die der Server nicht verarbeiten kann.';

  @override
  String get errorServerTimeout => 'Das Bearbeiten ihrer Anfrage dauert zu lange. Bitte versuchen Sie es später erneut.';

  @override
  String get errorServerUnavailable => 'Es tut uns leid. Der Reiseplaner ist vorübergehend nicht verfügbar. Bitte versuchen Sie es später erneut.';

  @override
  String get errorTrivialDistance => 'Der Startpunkt liegt in einer trivialen Entfernung zum Ziel.';

  @override
  String get errorUnknownDestination => 'Das Ziel ist unbekannt. Können Sie ein bisschen genauer sein?';

  @override
  String get errorUnknownOrigin => 'Der Startpunkt ist unbekannt. Können Sie ein bisschen genauer sein?';

  @override
  String get errorUnknownOriginDestination => 'Startpunkt und Ziel sind unbekannt. Können Sie ein bisschen genauer sein?';

  @override
  String get feedbackContent => 'Haben Sie Vorschläge für unsere App oder haben Sie Fehler in den Daten gefunden? Wir würden gerne von Ihnen hören! Bitte geben Sie Ihre E-Mail-Adresse oder Ihre Telefonnummer an, damit wir Ihnen antworten können.';

  @override
  String get feedbackTitle => 'E-Mail senden';

  @override
  String get followOnFacebook => 'Folge uns auf Facebook';

  @override
  String get followOnInstagram => 'Folge uns auf Instagram';

  @override
  String get followOnTwitter => 'Folge uns auf Twitter';

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
    return '${street1} und ${street2}';
  }

  @override
  String instructionRide(Object vehicle, Object distance, Object duration, Object location) {
    return 'Fahren Sie mit ${vehicle} ${duration} (${distance}) bis ${location}';
  }

  @override
  String get instructionVehicleBus => 'dem Bus';

  @override
  String get instructionVehicleCar => 'dem Auto';

  @override
  String get instructionVehicleGondola => 'der Gondel';

  @override
  String get instructionVehicleLightRail => 'Stadtbahn';

  @override
  String get instructionVehicleMicro => 'dem Micro';

  @override
  String get instructionVehicleMinibus => 'dem Minibus';

  @override
  String get instructionVehicleTrufi => 'der Trufi';

  @override
  String instructionWalk(Object distance, Object duration, Object location) {
    return 'Gehen Sie ${duration} (${distance}) bis ${location}';
  }

  @override
  String get mapTypeLabel => 'Kartentyp';

  @override
  String get mapTypeSatelliteCaption => 'Satellit';

  @override
  String get mapTypeStreetsCaption => 'Straßen';

  @override
  String get mapTypeTerrainCaption => 'Terrain';

  @override
  String get menuAbout => 'Über';

  @override
  String get menuAppReview => 'App bewerten';

  @override
  String get menuConnections => 'Verbindungen';

  @override
  String get menuFeedback => 'Feedback';

  @override
  String get menuOnline => 'Online';

  @override
  String get menuShareApp => 'App weiterempfehlen';

  @override
  String get menuTeam => 'Team';

  @override
  String get menuYourPlaces => 'Deine Plätze';

  @override
  String get noRouteError => 'Wir konnten leider keine Route finden. Was möchten Sie tun?';

  @override
  String get noRouteErrorActionCancel => 'Anderes Ziel auswählen';

  @override
  String get noRouteErrorActionReportMissingRoute => 'Fehlende Route melden';

  @override
  String get noRouteErrorActionShowCarRoute => 'Auto Route anzeigen';

  @override
  String get readOurBlog => 'Lies in unserem Blog';

  @override
  String get savedPlacesEnterNameTitle => 'Name eingeben';

  @override
  String get savedPlacesRemoveLabel => 'Platz entfernen';

  @override
  String get savedPlacesSelectIconTitle => 'Symbol auswählen';

  @override
  String get savedPlacesSetIconLabel => 'Symbol auswählen';

  @override
  String get savedPlacesSetNameLabel => 'Namen bearbeiten';

  @override
  String get savedPlacesSetPositionLabel => 'Position bearbeiten';

  @override
  String get searchFailLoadingPlan => 'Fehler beim Laden des Plans.';

  @override
  String get searchHintDestination => 'Ziel auswählen';

  @override
  String get searchHintOrigin => 'Start auswählen';

  @override
  String get searchItemChooseOnMap => 'Auf der Karte auswählen';

  @override
  String get searchItemNoResults => 'Keine Ergebnisse';

  @override
  String get searchItemYourLocation => 'Ihr Standort';

  @override
  String get searchMapMarker => 'Kartenmarkierung';

  @override
  String get searchPleaseSelectDestination => 'Ziel auswählen';

  @override
  String get searchPleaseSelectOrigin => 'Startpunkt auswählen';

  @override
  String get searchTitleFavorites => 'Favoriten';

  @override
  String get searchTitlePlaces => 'Orte';

  @override
  String get searchTitleRecent => 'Zuletzt gesucht';

  @override
  String get searchTitleResults => 'Suchergebnisse';

  @override
  String shareAppText(Object url, Object appTitle, Object cityName) {
    return 'Hol\' dir die ${appTitle}, die App für den öffentlichen Nahverkehr in ${cityName}, auf ${url}';
  }

  @override
  String tagline(Object city) {
    return 'Öffentliche Verkehrsmittel in ${city}';
  }

  @override
  String get teamContent => 'Wir sind ein internationales Team mit dem Namen Trufi Association, das diese App mithilfe vieler Freiwilliger erstellt hat! Möchtest du mithelfen, die Trufi App zu verbessern und Teil unseres Teams sein? Bitte kontaktiere uns über:';

  @override
  String teamSectionRepresentatives(Object representatives) {
    return 'Vertreter: ${representatives}';
  }

  @override
  String teamSectionRoutes(Object osmContributors, Object routeContributors) {
    return 'Routen: ${routeContributors} und alle Benutzer, die Routen zu OpenStreetMap hochgeladen haben, z. B. ${osmContributors}. Kontaktieren Sie uns, wenn Sie der OpenStreetMap-Community beitreten möchten!';
  }

  @override
  String teamSectionTeam(Object teamMembers) {
    return 'Team: ${teamMembers}';
  }

  @override
  String teamSectionTranslations(Object translators) {
    return 'Übersetzungen: ${translators}';
  }

  @override
  String get title => 'Trufi App';

  @override
  String version(Object version) {
    return 'Version ${version}';
  }
}
