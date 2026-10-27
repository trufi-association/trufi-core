// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'saved_places_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SavedPlacesLocalizationsEn extends SavedPlacesLocalizations {
  SavedPlacesLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get menuSavedPlaces => 'Your Places';

  @override
  String get yourPlaces => 'Your Places';

  @override
  String get home => 'Home';

  @override
  String get work => 'Work';

  @override
  String get favorites => 'Favorites';

  @override
  String get customPlaces => 'Favorites';

  @override
  String get recentPlaces => 'Recent';

  @override
  String get defaultPlaces => 'Default Places';

  @override
  String get setHome => 'Set home address';

  @override
  String get setWork => 'Set work address';

  @override
  String get editPlace => 'Edit place';

  @override
  String get removePlace => 'Remove place';

  @override
  String removePlaceConfirmation(String placeName) {
    return 'Are you sure you want to remove $placeName?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get remove => 'Remove';

  @override
  String get save => 'Save';

  @override
  String get name => 'Name';

  @override
  String get enterName => 'Enter name';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get selectIcon => 'Select Icon';

  @override
  String get clearHistory => 'Clear';

  @override
  String get noPlacesSaved => 'No places saved yet';

  @override
  String get addPlace => 'Add Place';

  @override
  String get chooseOnMap => 'Choose on map';

  @override
  String get searchLocation => 'Search location';

  @override
  String get type => 'Type';

  @override
  String get location => 'Location';

  @override
  String get noLocationSelected => 'No location selected';

  @override
  String get locationRequired => 'Location is required';

  @override
  String get locationSelected => 'Location selected';

  @override
  String get tapToSelectLocation => 'Tap to select on map';

  @override
  String get change => 'Change';

  @override
  String get errorLoadingPlaces => 'Error loading places';

  @override
  String get retry => 'Retry';

  @override
  String get history => 'History';

  @override
  String placeAlreadySaved(String placeName) {
    return '\"$placeName\" is already saved at that location';
  }

  @override
  String get placeNameInUse => 'You already have a place with this name';

  @override
  String get copiedToClipboard => 'Copied';

  @override
  String get menuSavedRoutes => 'Your Routes';

  @override
  String get noRoutesSaved => 'No routes saved yet';

  @override
  String get noRoutesSavedHint =>
      'Plan a trip and tap the bookmark to keep it here';

  @override
  String get savedRoutesSection => 'Saved routes';

  @override
  String routeOrigin(String name) {
    return 'Origin: $name';
  }

  @override
  String routeDestination(String name) {
    return 'Destination: $name';
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
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}min';
  }

  @override
  String get renameRoute => 'Rename route';

  @override
  String get routeName => 'Route name';

  @override
  String get swapDirection => 'Swap direction';

  @override
  String get removeRoute => 'Remove route';

  @override
  String removeRouteConfirmation(String routeName) {
    return 'Are you sure you want to remove $routeName?';
  }

  @override
  String routeAlreadySaved(String routeName) {
    return 'This route is already saved as \"$routeName\"';
  }

  @override
  String get errorLoadingRoutes => 'Error loading routes';
}
