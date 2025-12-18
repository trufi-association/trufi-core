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
}
