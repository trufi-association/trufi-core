// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'search_locations_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SearchLocationsLocalizationsEn extends SearchLocationsLocalizations {
  SearchLocationsLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get selectOrigin => 'Select origin';

  @override
  String get selectDestination => 'Select destination';

  @override
  String get searchOrigin => 'Search origin...';

  @override
  String get searchDestination => 'Search destination...';

  @override
  String get yourLocation => 'Your Location';

  @override
  String get chooseOnMap => 'Choose on Map';

  @override
  String get yourPlaces => 'YOUR PLACES';

  @override
  String get searchResults => 'SEARCH RESULTS';

  @override
  String get noResultsFound => 'No results found';

  @override
  String cornersOf(String street) {
    return 'Corners of $street';
  }

  @override
  String get seeCorners => 'See corners';
}
