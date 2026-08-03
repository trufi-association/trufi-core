// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'maps_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class MapsLocalizationsDe extends MapsLocalizations {
  MapsLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get mapSettings => 'Karteneinstellungen';

  @override
  String get mapType => 'Kartentyp';

  @override
  String get chooseMapStyle => 'Wähle deinen bevorzugten Kartenstil';

  @override
  String get changeMapType => 'Kartentyp ändern';

  @override
  String get chooseOnMap => 'Auf der Karte wählen';

  @override
  String get confirmLocation => 'Standort bestätigen';

  @override
  String get offlineMapName => 'Offline-Karte';

  @override
  String get offlineMapDescription => 'Vollständig offline nutzbare Karte';

  @override
  String get errorLoadingOfflineMap => 'Fehler beim Laden der Offline-Karte';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get vectorMapDescription =>
      'Vektorkarte mit modernem Design und besserer Leistung';

  @override
  String get lightVectorMapDescription => 'Helle Vektorkarte';

  @override
  String get darkVectorMapDescription => 'Dunkle Vektorkarte';
}
