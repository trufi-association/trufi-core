// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de_DE locale. All the
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
  get localeName => 'de_DE';

  static m0(value) => "${value} km";

  static m1(value) => "${value} m";

  static m2(value) => "${value} min";

  static m3(street1, street2) => "${street1} und ${street2}";

  static m4(vehicle, duration, distance, location) => "Fahren Sie mit ${vehicle} ${duration} (${distance}) bis ${location}";

  static m5(duration, distance, location) => "Gehen Sie ${duration} (${distance}) bis ${location}";

  static m6(url) => "Hol\' dir die Trufi, die App für den öffentlichen Nahverkehr in Cochabamba, auf ${url}";

  static m7(representatives) => "Vertreter: ${representatives}";

  static m8(routeContributors, osmContributors) => "Routen: ${routeContributors} und alle Benutzer, die Routen zu OpenStreetMap hochgeladen haben, z. B. ${osmContributors}. Kontaktieren Sie uns, wenn Sie der OpenStreetMap-Community beitreten möchten!";

  static m9(teamMembers) => "Team: ${teamMembers}";

  static m10(translators) => "Übersetzungen: ${translators}";

  static m11(version) => "Version ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "aboutContent" : MessageLookupByLibrary.simpleMessage("Wir sind ein bolivianisches und internationales Team, das den öffentlichen Nahverkehr liebt und unterstützen möchte. Wir haben diese App entwickelt, um den Menschen die Verwendung des öffentlichen Nahverkehrs in Cochabamba und der näheren Umgebung zu erleichtern."),
    "aboutLicenses" : MessageLookupByLibrary.simpleMessage("Lizenzen"),
    "aboutOpenSource" : MessageLookupByLibrary.simpleMessage("Diese App ist Open Source und auf GitHub verfügbar. Zögere nicht, einen Beitrag zu leisten oder bringe sie in Deine Stadt!"),
    "alertLocationServicesDeniedMessage" : MessageLookupByLibrary.simpleMessage("Bitte vergewissere dich, dass du ein GPS Signal empfängst und die Ortungsdienste aktiviert sind."),
    "alertLocationServicesDeniedTitle" : MessageLookupByLibrary.simpleMessage("Kein Standort"),
    "appReviewDialogButtonAccept" : MessageLookupByLibrary.simpleMessage("Bewerten"),
    "appReviewDialogButtonDecline" : MessageLookupByLibrary.simpleMessage("Jetzt nicht"),
    "appReviewDialogContent" : MessageLookupByLibrary.simpleMessage("Unterstüzte uns mit einer Bewertung im Google Play Store."),
    "appReviewDialogTitle" : MessageLookupByLibrary.simpleMessage("Magst du Trufi?"),
    "chooseLocationPageSubtitle" : MessageLookupByLibrary.simpleMessage("Karte unter Markierung schwenken und zoomen"),
    "chooseLocationPageTitle" : MessageLookupByLibrary.simpleMessage("Ort auswählen"),
    "commonCancel" : MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "commonDestination" : MessageLookupByLibrary.simpleMessage("Fahrtziel"),
    "commonError" : MessageLookupByLibrary.simpleMessage("Fehler"),
    "commonFailLoading" : MessageLookupByLibrary.simpleMessage("Fehler beim Laden der Daten"),
    "commonGoOffline" : MessageLookupByLibrary.simpleMessage("Offline gehen"),
    "commonGoOnline" : MessageLookupByLibrary.simpleMessage("Online gehen"),
    "commonNoInternet" : MessageLookupByLibrary.simpleMessage("Keine Internetverbindung."),
    "commonOK" : MessageLookupByLibrary.simpleMessage("OK"),
    "commonOrigin" : MessageLookupByLibrary.simpleMessage("Startpunkt"),
    "commonUnknownError" : MessageLookupByLibrary.simpleMessage("Unbekannter Fehler"),
    "description" : MessageLookupByLibrary.simpleMessage("Der beste Weg mit Trufis, Mikros und Bussen durch Cochabamba zu reisen."),
    "donate" : MessageLookupByLibrary.simpleMessage("Spenden"),
    "errorAmbiguousDestination" : MessageLookupByLibrary.simpleMessage("Der Reiseplaner weiß nicht genau, zu welchem Ort Sie fahren möchten. Bitte wählen Sie aus den folgenden Optionen eine aus oder geben Sie eine genauere Beschreibung an."),
    "errorAmbiguousOrigin" : MessageLookupByLibrary.simpleMessage("Der Reiseplaner weiß nicht genau, von welchem Ort aus Sie starten möchten. Bitte wählen Sie aus den folgenden Optionen eine aus oder geben Sie eine genauere Beschreibung an."),
    "errorAmbiguousOriginDestination" : MessageLookupByLibrary.simpleMessage("Der Startpunkt und das Ziel sind unklar. Bitte wählen Sie aus den folgenden Optionen eine aus oder geben Sie eine genauere Beschreibung an."),
    "errorNoBarrierFree" : MessageLookupByLibrary.simpleMessage("Der Startpunkt und das Ziel sind nicht für Rollstuhlfahrer zugänglich."),
    "errorNoTransitTimes" : MessageLookupByLibrary.simpleMessage("Keine Abfahrtszeiten verfügbar. Das Datum liegt eventuell zuweit in der Vergangenheit oder der Zukunft oder es gibt keinen Transitservice zu dem von Ihnen gewählten Zeitpunkt."),
    "errorOutOfBoundary" : MessageLookupByLibrary.simpleMessage("Dieser Trip ist nicht möglich. Sie versuchen möglicherweise eine Reise außerhalb der verfügbaren Kartendaten zu planen."),
    "errorPathNotFound" : MessageLookupByLibrary.simpleMessage("Dieser Trip ist nicht möglich. Ihr Start- oder Endpunkt ist möglicherweise nicht sicher zugänglich (dies ist beispielsweise der Fall, wenn Sie sich in einer Wohnstraße befinden, die nur mit einer Autobahn verbunden ist)."),
    "errorServerCanNotHandleRequest" : MessageLookupByLibrary.simpleMessage("Die Anfrage enthält Fehler, die der Server nicht verarbeiten kann."),
    "errorServerTimeout" : MessageLookupByLibrary.simpleMessage("Das Bearbeiten ihrer Anfrage dauert zu lange. Bitte versuchen Sie es später erneut."),
    "errorServerUnavailable" : MessageLookupByLibrary.simpleMessage("Es tut uns leid. Der Reiseplaner ist vorübergehend nicht verfügbar. Bitte versuchen Sie es später erneut."),
    "errorTrivialDistance" : MessageLookupByLibrary.simpleMessage("Der Startpunkt liegt in einer trivialen Entfernung zum Ziel."),
    "errorUnknownDestination" : MessageLookupByLibrary.simpleMessage("Das Ziel ist unbekannt. Können Sie ein bisschen genauer sein?"),
    "errorUnknownOrigin" : MessageLookupByLibrary.simpleMessage("Der Startpunkt ist unbekannt. Können Sie ein bisschen genauer sein?"),
    "errorUnknownOriginDestination" : MessageLookupByLibrary.simpleMessage("Startpunkt und Ziel sind unbekannt. Können Sie ein bisschen genauer sein?"),
    "feedbackContent" : MessageLookupByLibrary.simpleMessage("Haben Sie Vorschläge für unsere App oder haben Sie Fehler in den Daten gefunden? Wir würden gerne von Ihnen hören! Bitte geben Sie Ihre E-Mail-Adresse oder Ihre Telefonnummer an, damit wir Ihnen antworten können."),
    "feedbackTitle" : MessageLookupByLibrary.simpleMessage("E-Mail senden"),
    "followOnFacebook" : MessageLookupByLibrary.simpleMessage("Folge uns auf Facebook"),
    "followOnInstagram" : MessageLookupByLibrary.simpleMessage("Folge uns auf Instagram"),
    "followOnTwitter" : MessageLookupByLibrary.simpleMessage("Folge uns auf Twitter"),
    "instructionDistanceKm" : m0,
    "instructionDistanceMeters" : m1,
    "instructionDurationMinutes" : m2,
    "instructionJunction" : m3,
    "instructionRide" : m4,
    "instructionVehicleBus" : MessageLookupByLibrary.simpleMessage("dem Bus"),
    "instructionVehicleCar" : MessageLookupByLibrary.simpleMessage("dem Auto"),
    "instructionVehicleGondola" : MessageLookupByLibrary.simpleMessage("der Gondel"),
    "instructionVehicleMicro" : MessageLookupByLibrary.simpleMessage("dem Micro"),
    "instructionVehicleMinibus" : MessageLookupByLibrary.simpleMessage("dem Minibus"),
    "instructionVehicleTrufi" : MessageLookupByLibrary.simpleMessage("der Trufi"),
    "instructionWalk" : m5,
    "menuAbout" : MessageLookupByLibrary.simpleMessage("Über"),
    "menuAppReview" : MessageLookupByLibrary.simpleMessage("App bewerten"),
    "menuConnections" : MessageLookupByLibrary.simpleMessage("Verbindungen"),
    "menuFeedback" : MessageLookupByLibrary.simpleMessage("Feedback"),
    "menuOnline" : MessageLookupByLibrary.simpleMessage("Online"),
    "menuShareApp" : MessageLookupByLibrary.simpleMessage("App weiterempfehlen"),
    "menuTeam" : MessageLookupByLibrary.simpleMessage("Team"),
    "noRouteError" : MessageLookupByLibrary.simpleMessage("Wir konnten leider keine Route finden. Was möchten Sie tun?"),
    "noRouteErrorActionCancel" : MessageLookupByLibrary.simpleMessage("Anderes Ziel auswählen"),
    "noRouteErrorActionReportMissingRoute" : MessageLookupByLibrary.simpleMessage("Fehlende Route melden"),
    "noRouteErrorActionShowCarRoute" : MessageLookupByLibrary.simpleMessage("Auto Route anzeigen"),
    "readOurBlog" : MessageLookupByLibrary.simpleMessage("Lies in unserem Blog"),
    "searchFailLoadingPlan" : MessageLookupByLibrary.simpleMessage("Fehler beim Laden des Plans."),
    "searchHintDestination" : MessageLookupByLibrary.simpleMessage("Ziel auswählen"),
    "searchHintOrigin" : MessageLookupByLibrary.simpleMessage("Start auswählen"),
    "searchItemChooseOnMap" : MessageLookupByLibrary.simpleMessage("Auf der Karte auswählen"),
    "searchItemNoResults" : MessageLookupByLibrary.simpleMessage("Keine Ergebnisse"),
    "searchItemYourLocation" : MessageLookupByLibrary.simpleMessage("Ihr Standort"),
    "searchMapMarker" : MessageLookupByLibrary.simpleMessage("Kartenmarkierung"),
    "searchPleaseSelectDestination" : MessageLookupByLibrary.simpleMessage("Ziel auswählen"),
    "searchPleaseSelectOrigin" : MessageLookupByLibrary.simpleMessage("Startpunkt auswählen"),
    "searchTitleFavorites" : MessageLookupByLibrary.simpleMessage("Favoriten"),
    "searchTitlePlaces" : MessageLookupByLibrary.simpleMessage("Orte"),
    "searchTitleRecent" : MessageLookupByLibrary.simpleMessage("Zuletzt gesucht"),
    "searchTitleResults" : MessageLookupByLibrary.simpleMessage("Suchergebnisse"),
    "shareAppText" : m6,
    "tagline" : MessageLookupByLibrary.simpleMessage("Öffentliche Verkehrsmittel in Cochabamba"),
    "teamContent" : MessageLookupByLibrary.simpleMessage("Wir sind ein internationales Team mit dem Namen Trufi Association, das diese App mit Hilfe vieler Freiwilliger erstellt hat! Möchtest du mithelfen, die Trufi App zu verbessern und Teil unseres Teams sein? Bitte kontaktiere uns über:"),
    "teamSectionRepresentatives" : m7,
    "teamSectionRoutes" : m8,
    "teamSectionTeam" : m9,
    "teamSectionTranslations" : m10,
    "title" : MessageLookupByLibrary.simpleMessage("Trufi App"),
    "version" : m11
  };
}
