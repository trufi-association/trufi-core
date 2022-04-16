


import 'trufi_base_localizations.dart';

/// The translations for German (`de`).
class TrufiBaseLocalizationDe extends TrufiBaseLocalization {
  TrufiBaseLocalizationDe([String locale = 'de']) : super(locale);

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
  String get commonConfirmLocation => 'Standort bestätigen';

  @override
  String get commonDestination => 'Fahrtziel';

  @override
  String get commonEdit => 'Bearbeiten';

  @override
  String get commonError => 'Fehler';

  @override
  String get commonFromStation => 'von Bahnhof';

  @override
  String get commonFromStop => 'von Halt';

  @override
  String get commonItineraryNoTransitLegs => 'Start jederzeit möglich';

  @override
  String get commonLeavesAt => 'Fährt';

  @override
  String get commonLoading => 'Laden…';

  @override
  String get commonNoInternet => 'Keine Internetverbindung.';

  @override
  String get commonNoResults => 'Keine Ergebnisse';

  @override
  String get commonOK => 'OK';

  @override
  String get commonOrigin => 'Startpunkt';

  @override
  String get commonRemove => 'Entfernen';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonTomorrow => 'Morgen';

  @override
  String get commonUnknownError => 'Unbekannter Fehler';

  @override
  String get commonUnkownPlace => 'Unbekannter Ort';

  @override
  String get commonWait => 'Wartezeit';

  @override
  String get commonWalk => 'Gehen';

  @override
  String get commonYourLocation => 'Ihr Standort';

  @override
  String get errorAmbiguousDestination => 'Der Reiseplaner weiß nicht genau, zu welchem Ort Sie fahren möchten. Bitte wählen Sie aus den folgenden Optionen eine aus oder geben Sie eine genauere Beschreibung an.';

  @override
  String get errorAmbiguousOrigin => 'Der Reiseplaner weiß nicht genau, von welchem Ort aus Sie starten möchten. Bitte wählen Sie aus den folgenden Optionen eine aus oder geben Sie eine genauere Beschreibung an.';

  @override
  String get errorAmbiguousOriginDestination => 'Der Startpunkt und das Ziel sind unklar. Bitte wählen Sie aus den folgenden Optionen eine aus oder geben Sie eine genauere Beschreibung an.';

  @override
  String get errorNoBarrierFree => 'Der Startpunkt und das Ziel sind nicht für Rollstuhlfahrer zugänglich.';

  @override
  String get errorNoConnectServer => 'Keine Verbindung zum Server.';

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
  String get followOnFacebook => 'Folge uns auf Facebook';

  @override
  String get followOnInstagram => 'Folge uns auf Instagram';

  @override
  String get followOnTwitter => 'Folge uns auf Twitter';

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
    return '$value h';
  }

  @override
  String instructionDurationMinutes(Object value) {
    return '$value min';
  }

  @override
  String get instructionVehicleBike => 'Fahrrad';

  @override
  String get instructionVehicleBus => 'Bus';

  @override
  String get instructionVehicleCar => 'Auto';

  @override
  String get instructionVehicleCarpool => 'Fahrgemeinschaft';

  @override
  String get instructionVehicleCommuterTrain => 'Zug';

  @override
  String get instructionVehicleGondola => 'der Gondel';

  @override
  String get instructionVehicleLightRail => 'Stadtbahn';

  @override
  String get instructionVehicleMetro => 'U-Bahn';

  @override
  String get instructionVehicleMicro => 'dem Micro';

  @override
  String get instructionVehicleMinibus => 'dem Minibus';

  @override
  String get instructionVehicleTrufi => 'der Trufi';

  @override
  String get instructionVehicleWalk => 'Gehen';

  @override
  String get menuConnections => 'Routenplaner';

  @override
  String get menuSocialMedia => 'Soziale Medien';

  @override
  String get menuTransportList => 'Verbindungen';

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
  String get searchFailLoadingPlan => 'Fehler beim Laden des Plans.';

  @override
  String get searchHintDestination => 'Ziel auswählen';

  @override
  String get searchHintOrigin => 'Start auswählen';

  @override
  String get searchPleaseSelectDestination => 'Ziel auswählen';

  @override
  String get searchPleaseSelectOrigin => 'Startpunkt auswählen';

  @override
  String shareAppText(Object url, Object appTitle, Object cityName) {
    return 'Hol\' dir die $appTitle, die App für den öffentlichen Nahverkehr in $cityName, auf $url';
  }

  @override
  String get themeModeDark => 'Dunkles Thema';

  @override
  String get themeModeLight => 'Leichtes Thema';

  @override
  String get themeModeSystem => 'Systemeinstellung';
}
