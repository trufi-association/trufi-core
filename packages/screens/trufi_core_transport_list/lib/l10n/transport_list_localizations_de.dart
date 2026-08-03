// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'transport_list_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class TransportListLocalizationsDe extends TransportListLocalizations {
  TransportListLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get menuTransportList => 'Linien';

  @override
  String get searchRoutes => 'Linien suchen';

  @override
  String get noRoutesFound => 'Keine Linien gefunden';

  @override
  String get shareRoute => 'Linie teilen';

  @override
  String stops(int count) {
    return '$count Haltestellen';
  }

  @override
  String get routeNotFound => 'Linie nicht gefunden';

  @override
  String get routeLoadError => 'Die Linie konnte nicht geladen werden';

  @override
  String get pullDownToRefresh => 'Nach unten ziehen zum Aktualisieren';

  @override
  String get tryDifferentSearch => 'Versuche einen anderen Suchbegriff';

  @override
  String get buttonGoBack => 'Zurück';

  @override
  String routeCount(int count) {
    return '$count Linien';
  }

  @override
  String get labelDistance => 'Entfernung';

  @override
  String get labelStops => 'Haltestellen';

  @override
  String get labelMode => 'Verkehrsmittel';

  @override
  String get noStopsAvailable => 'Keine Haltestellen verfügbar';

  @override
  String get loadingRoute => 'Linie wird geladen...';

  @override
  String get otherAgencies => 'Sonstige';

  @override
  String shareRouteMessage(String uri) {
    return 'Teilen: $uri';
  }

  @override
  String get defaultModeBus => 'Bus';

  @override
  String get mapSettingsTitle => 'Karteneinstellungen';

  @override
  String get mapTypeLabel => 'Kartentyp';

  @override
  String get applyChanges => 'Änderungen übernehmen';

  @override
  String get stopStart => 'Start';

  @override
  String get stopEnd => 'Ende';

  @override
  String get stopInfoNotAvailable =>
      'Für diese Linie sind keine Haltestelleninformationen verfügbar';

  @override
  String get errorLoadingRoutes => 'Die Linien konnten nicht geladen werden';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get qrShareSubtitle =>
      'Scannen, um die Linien dieses Betreibers zu öffnen';
}
