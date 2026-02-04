// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'home_screen_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class HomeScreenLocalizationsEn extends HomeScreenLocalizations {
  HomeScreenLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get menuHome => 'Home';

  @override
  String get searchOrigin => 'Select origin';

  @override
  String get searchDestination => 'Select destination';

  @override
  String get selectLocations => 'Select origin and destination to find routes';

  @override
  String get noRoutesFound => 'No routes found';

  @override
  String get errorNoRoutes => 'Error loading routes';

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}min';
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
  String get walk => 'Walk';

  @override
  String transfers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transfers',
      one: '1 transfer',
      zero: 'No transfers',
    );
    return '$_temp0';
  }

  @override
  String departureAt(String time) {
    return 'Departure at $time';
  }

  @override
  String arrivalAt(String time) {
    return 'Arrival at $time';
  }

  @override
  String get yourLocation => 'Your Location';

  @override
  String get chooseOnMap => 'Choose on Map';

  @override
  String get confirmLocation => 'Confirm Location';

  @override
  String get selectedLocation => 'Selected Location';

  @override
  String get setAsOrigin => 'Set as Origin';

  @override
  String get setAsDestination => 'Set as Destination';

  @override
  String get shareRoute => 'Share route';

  @override
  String shareRouteTitle(String appName) {
    return '$appName - Shared route';
  }

  @override
  String shareRouteOrigin(String location) {
    return 'Origin: $location';
  }

  @override
  String shareRouteDestination(String location) {
    return 'Destination: $location';
  }

  @override
  String shareRouteDate(String date) {
    return 'Date: $date';
  }

  @override
  String shareRouteTimes(String departure, String arrival) {
    return 'Departure: $departure → Arrival: $arrival';
  }

  @override
  String shareRouteDuration(String duration) {
    return 'Duration: $duration';
  }

  @override
  String shareRouteItinerary(String summary) {
    return 'Route: $summary';
  }

  @override
  String get shareRouteOpenInApp => 'Open in app:';

  @override
  String get tripDetails => 'Trip Details';

  @override
  String get departure => 'Departure';

  @override
  String get arrival => 'Arrival';

  @override
  String get totalDistance => 'Distance';

  @override
  String get walking => 'Walking';

  @override
  String get tripSteps => 'Trip Steps';

  @override
  String get towards => 'Towards';

  @override
  String get stops => 'stops';

  @override
  String get bike => 'Bike';

  @override
  String get train => 'Train';

  @override
  String get transfersLabel => 'Transfers';

  @override
  String operatedBy(String agency) {
    return 'Operated by $agency';
  }

  @override
  String get viewFares => 'View fares';

  @override
  String co2Emissions(String grams) {
    return '${grams}g CO₂';
  }

  @override
  String get locationPermissionTitle => 'Location Permission';

  @override
  String get locationPermissionDeniedMessage =>
      'Location permission is permanently denied. Please enable it in your device settings to use this feature.';

  @override
  String get locationDisabledTitle => 'Location Disabled';

  @override
  String get locationDisabledMessage =>
      'Location services are disabled on your device. Please enable them to use this feature.';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonOpenSettings => 'Open Settings';

  @override
  String get buttonApply => 'Apply';

  @override
  String get searchForRoute => 'Search for a route';

  @override
  String get searchForRouteHint =>
      'Enter origin and destination to find routes';

  @override
  String get tooltipShare => 'Share';

  @override
  String get tooltipClose => 'Close';

  @override
  String get leaveNow => 'Leave now';

  @override
  String get departAt => 'Depart at...';

  @override
  String departAtTime(String time) {
    return 'Depart $time';
  }

  @override
  String get arriveBy => 'Arrive by...';

  @override
  String arriveByTime(String time) {
    return 'Arrive by $time';
  }

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String tomorrowWithTime(String time) {
    return 'Tomorrow $time';
  }

  @override
  String get whenDoYouWantToTravel => 'When do you want to travel?';

  @override
  String routesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count routes found',
      one: '1 route found',
    );
    return '$_temp0';
  }

  @override
  String get monthJan => 'Jan';

  @override
  String get monthFeb => 'Feb';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthApr => 'Apr';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthAug => 'Aug';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Dec';

  @override
  String get buttonGo => 'Go';

  @override
  String get buttonDetails => 'Details';

  @override
  String get buttonTryAgain => 'Try again';

  @override
  String get buttonReset => 'Reset';

  @override
  String get routeSettings => 'Route Settings';

  @override
  String get wheelchairAccessible => 'Wheelchair accessible';

  @override
  String get wheelchairAccessibleOn => 'Routes avoid stairs and steep slopes';

  @override
  String get wheelchairAccessibleOff => 'Include all routes';

  @override
  String get walkingSpeed => 'Walking speed';

  @override
  String get speedSlow => 'Slow';

  @override
  String get speedNormal => 'Normal';

  @override
  String get speedFast => 'Fast';

  @override
  String get maxWalkDistance => 'Maximum walking distance';

  @override
  String get noLimit => 'No limit';

  @override
  String get transportModes => 'Transport modes';

  @override
  String get modeTransit => 'Transit';

  @override
  String get modeBicycle => 'Bicycle';

  @override
  String get exitNavigation => 'Exit Navigation';

  @override
  String get exitNavigationTitle => 'Exit Navigation?';

  @override
  String get exitNavigationMessage =>
      'Are you sure you want to stop navigating this route?';

  @override
  String get buttonExit => 'Exit';

  @override
  String get arrivedMessage => 'You have arrived!';

  @override
  String get buttonRetry => 'Retry';

  @override
  String get buttonSettings => 'Settings';

  @override
  String get findingRoutes => 'Finding routes...';

  @override
  String moreDepartures(int count) {
    return '+$count more';
  }

  @override
  String get otherDepartures => 'Other departures';

  @override
  String departsAt(String time) {
    return 'Departs $time';
  }
}
