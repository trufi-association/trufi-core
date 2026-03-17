// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'navigation_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class NavigationLocalizationsEn extends NavigationLocalizations {
  NavigationLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navExitNavigation => 'Exit Navigation';

  @override
  String get navExitConfirmTitle => 'Exit Navigation?';

  @override
  String get navExitConfirmMessage =>
      'Are you sure you want to stop navigating this route?';

  @override
  String get navCancel => 'Cancel';

  @override
  String get navExit => 'Exit';

  @override
  String get navClose => 'Close';

  @override
  String get navRetry => 'Retry';

  @override
  String get navSettings => 'Settings';

  @override
  String get navArrived => 'You have arrived!';

  @override
  String get navOffRoute => 'You appear to be off the route';

  @override
  String get navWeakGps => 'GPS signal is weak';

  @override
  String get navNext => 'Next: ';

  @override
  String get navError => 'An error occurred';

  @override
  String get navStarting => 'Starting navigation...';

  @override
  String get navGettingLocation => 'Getting your location';

  @override
  String get navCouldNotStartTracking => 'Could not start location tracking';

  @override
  String get navArrivedShort => 'You have arrived';

  @override
  String get navOneStop => '1 stop';

  @override
  String navStops(int count) {
    return '$count stops';
  }

  @override
  String navExitAt(String stopName) {
    return 'Exit at $stopName';
  }

  @override
  String get navFinalDestination => 'Final destination';

  @override
  String get navPermissionDenied => 'Location permission denied';

  @override
  String get navPermissionPermanentlyDenied =>
      'Location permission permanently denied. Please enable in settings.';

  @override
  String get navLocationDisabled =>
      'Location services are disabled. Please enable them.';

  @override
  String get navOrigin => 'Origin';

  @override
  String get navTransfer => 'Transfer';

  @override
  String get navDestination => 'Destination';
}
