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
}
