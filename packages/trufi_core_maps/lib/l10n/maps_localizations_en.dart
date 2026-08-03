// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'maps_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class MapsLocalizationsEn extends MapsLocalizations {
  MapsLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get mapSettings => 'Map Settings';

  @override
  String get mapType => 'Map Type';

  @override
  String get chooseMapStyle => 'Choose your preferred map style';

  @override
  String get changeMapType => 'Change map type';

  @override
  String get chooseOnMap => 'Choose on Map';

  @override
  String get confirmLocation => 'Confirm Location';

  @override
  String get offlineMapName => 'Offline Map';

  @override
  String get offlineMapDescription => 'Fully offline map';

  @override
  String get errorLoadingOfflineMap => 'Error loading offline map';

  @override
  String get retry => 'Retry';

  @override
  String get vectorMapDescription =>
      'Vector map with modern styling and better performance';

  @override
  String get lightVectorMapDescription => 'Light vector map';

  @override
  String get darkVectorMapDescription => 'Dark vector map';
}
