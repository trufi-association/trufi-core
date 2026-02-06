// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'home_screen_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class HomeScreenLocalizationsDe extends HomeScreenLocalizations {
  HomeScreenLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get menuHome => 'Startseite';

  @override
  String get searchOrigin => 'Startort auswählen';

  @override
  String get searchDestination => 'Zielort auswählen';

  @override
  String get selectLocations => 'Wähle Start und Ziel, um Routen zu finden';

  @override
  String get noRoutesFound => 'Keine Routen gefunden';

  @override
  String get errorNoRoutes => 'Fehler beim Laden der Routen';

  @override
  String durationMinutes(int minutes) {
    return '$minutes Min';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}Min';
  }

  @override
  String distanceMeters(int meters) {
    return '$meters m';
  }

  @override
  String distanceKilometers(String km) {
    return '$km km';
  }

  @override
  String get walk => 'Zu Fuß';

  @override
  String transfers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Umstiege',
      one: '1 Umstieg',
      zero: 'Keine Umstiege',
    );
    return '$_temp0';
  }

  @override
  String departureAt(String time) {
    return 'Abfahrt um $time';
  }

  @override
  String arrivalAt(String time) {
    return 'Ankunft um $time';
  }

  @override
  String get yourLocation => 'Dein Standort';

  @override
  String get chooseOnMap => 'Auf der Karte wählen';

  @override
  String get confirmLocation => 'Standort bestätigen';

  @override
  String get selectedLocation => 'Ausgewählter Standort';

  @override
  String get setAsOrigin => 'Als Startort festlegen';

  @override
  String get setAsDestination => 'Als Zielort festlegen';

  @override
  String get shareRoute => 'Route teilen';

  @override
  String shareRouteTitle(String appName) {
    return '$appName - Geteilte Route';
  }

  @override
  String shareRouteOrigin(String location) {
    return 'Start: $location';
  }

  @override
  String shareRouteDestination(String location) {
    return 'Ziel: $location';
  }

  @override
  String shareRouteDate(String date) {
    return 'Datum: $date';
  }

  @override
  String shareRouteTimes(String departure, String arrival) {
    return 'Abfahrt: $departure → Ankunft: $arrival';
  }

  @override
  String shareRouteDuration(String duration) {
    return 'Dauer: $duration';
  }

  @override
  String shareRouteItinerary(String summary) {
    return 'Route: $summary';
  }

  @override
  String get shareRouteOpenInApp => 'In der App öffnen:';

  @override
  String get tripDetails => 'Reisedetails';

  @override
  String get departure => 'Abfahrt';

  @override
  String get arrival => 'Ankunft';

  @override
  String get totalDistance => 'Entfernung';

  @override
  String get walking => 'Zu Fuß';

  @override
  String get tripSteps => 'Reiseschritte';

  @override
  String get towards => 'Richtung';

  @override
  String get stops => 'Haltestellen';

  @override
  String get bike => 'Fahrrad';

  @override
  String get train => 'Zug';

  @override
  String get transfersLabel => 'Umstiege';

  @override
  String operatedBy(String agency) {
    return 'Betrieben von $agency';
  }

  @override
  String get viewFares => 'Tarife ansehen';

  @override
  String co2Emissions(String grams) {
    return '${grams}g CO₂';
  }

  @override
  String get locationPermissionTitle => 'Standortberechtigung';

  @override
  String get locationPermissionDeniedMessage =>
      'Die Standortberechtigung wurde dauerhaft verweigert. Bitte aktiviere sie in den Geräteeinstellungen, um diese Funktion zu nutzen.';

  @override
  String get locationDisabledTitle => 'Standort deaktiviert';

  @override
  String get locationDisabledMessage =>
      'Die Standortdienste sind auf deinem Gerät deaktiviert. Bitte aktiviere sie, um diese Funktion zu nutzen.';

  @override
  String get buttonCancel => 'Abbrechen';

  @override
  String get buttonOpenSettings => 'Einstellungen öffnen';

  @override
  String get buttonApply => 'Anwenden';

  @override
  String get searchForRoute => 'Nach einer Route suchen';

  @override
  String get searchForRouteHint =>
      'Gib Start und Ziel ein, um Routen zu finden';

  @override
  String get tooltipShare => 'Teilen';

  @override
  String get tooltipClose => 'Schließen';

  @override
  String get leaveNow => 'Jetzt losfahren';

  @override
  String get departAt => 'Abfahrt um...';

  @override
  String departAtTime(String time) {
    return 'Abfahrt $time';
  }

  @override
  String get arriveBy => 'Ankunft bis...';

  @override
  String arriveByTime(String time) {
    return 'Ankunft bis $time';
  }

  @override
  String get today => 'Heute';

  @override
  String get tomorrow => 'Morgen';

  @override
  String tomorrowWithTime(String time) {
    return 'Morgen $time';
  }

  @override
  String get whenDoYouWantToTravel => 'Wann möchtest du reisen?';

  @override
  String routesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Routen gefunden',
      one: '1 Route gefunden',
    );
    return '$_temp0';
  }

  @override
  String get monthJan => 'Jan';

  @override
  String get monthFeb => 'Feb';

  @override
  String get monthMar => 'Mär';

  @override
  String get monthApr => 'Apr';

  @override
  String get monthMay => 'Mai';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthAug => 'Aug';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthOct => 'Okt';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Dez';

  @override
  String get buttonGo => 'Los';

  @override
  String get buttonDetails => 'Details';

  @override
  String get buttonTryAgain => 'Erneut versuchen';

  @override
  String get buttonReset => 'Zurücksetzen';

  @override
  String get routeSettings => 'Routeneinstellungen';

  @override
  String get wheelchairAccessible => 'Rollstuhlgerecht';

  @override
  String get wheelchairAccessibleOn =>
      'Routen vermeiden Treppen und steile Hänge';

  @override
  String get wheelchairAccessibleOff => 'Alle Routen einschließen';

  @override
  String get walkingSpeed => 'Gehgeschwindigkeit';

  @override
  String get speedSlow => 'Langsam';

  @override
  String get speedNormal => 'Normal';

  @override
  String get speedFast => 'Schnell';

  @override
  String get maxWalkDistance => 'Maximale Gehstrecke';

  @override
  String get noLimit => 'Kein Limit';

  @override
  String get transportModes => 'Verkehrsmittel';

  @override
  String get modeTransit => 'ÖPNV';

  @override
  String get modeBicycle => 'Fahrrad';

  @override
  String get exitNavigation => 'Navigation beenden';

  @override
  String get exitNavigationTitle => 'Navigation beenden?';

  @override
  String get exitNavigationMessage =>
      'Bist du sicher, dass du die Navigation dieser Route beenden möchtest?';

  @override
  String get buttonExit => 'Beenden';

  @override
  String get arrivedMessage => 'Du bist angekommen!';

  @override
  String get buttonRetry => 'Erneut versuchen';

  @override
  String get buttonSettings => 'Einstellungen';

  @override
  String get findingRoutes => 'Routen werden gesucht...';

  @override
  String moreDepartures(int count) {
    return '+$count weitere';
  }

  @override
  String get otherDepartures => 'Weitere Abfahrten';

  @override
  String departsAt(String time) {
    return 'Abfahrt $time';
  }

  @override
  String get routingProvider => 'Routing-Anbieter';

  @override
  String get autoFallback => 'Automatischer Fallback';

  @override
  String get autoFallbackDescription =>
      'Versucht zuerst online, nutzt offline bei Fehler';

  @override
  String get engineOnlineName => 'Online';

  @override
  String get engineOnlineDescription =>
      'OpenTripPlanner 2.8. Echtzeit-Routing mit detaillierten Fußweganweisungen.';

  @override
  String get engineOfflineName => 'Offline';

  @override
  String get engineOfflineDescription =>
      'GTFS-basiertes Routing, inspiriert von GuíaCochala. Funktioniert ohne Internet.';

  @override
  String get limitationRequiresInternet => 'Erfordert Internet';

  @override
  String get limitationSlower => 'Langsamere Antwort';

  @override
  String get limitationNoWalkingRoute => 'Keine Fußweg-Route auf Karte';
}
