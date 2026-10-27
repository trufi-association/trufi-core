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

  @override
  String get copyQrImage => 'QR kopieren';

  @override
  String get copyQrImageFailed => 'QR konnte nicht kopiert werden';

  @override
  String get modeTram => 'Straßenbahn';

  @override
  String get modeSubway => 'U-Bahn';

  @override
  String get modeRail => 'Bahn';

  @override
  String get modeBus => 'Bus';

  @override
  String get modeFerry => 'Fähre';

  @override
  String get modeCableTram => 'Kabelstraßenbahn';

  @override
  String get modeAerialLift => 'Seilbahn';

  @override
  String get modeFunicular => 'Standseilbahn';

  @override
  String get modeTrolleybus => 'Oberleitungsbus';

  @override
  String get modeMonorail => 'Einschienenbahn';

  @override
  String distanceKilometers(String value) {
    return '$value km';
  }

  @override
  String distanceMeters(String value) {
    return '$value m';
  }

  @override
  String get copiedToClipboard => 'Kopiert';

  @override
  String get menuNearbyLines => 'Linien in der Nähe';

  @override
  String get nearbyAnchorYourLocation => 'Dein Standort';

  @override
  String get nearbyAnchorPinned => 'Markierter Ort';

  @override
  String get nearbyAnchorDefault => 'Stadtzentrum (Standort nicht verfügbar)';

  @override
  String get nearbyUseMyLocation => 'Meinen Standort verwenden';

  @override
  String get nearbyMovePinHint =>
      'Halte die Karte gedrückt, um den Pin zu verschieben';

  @override
  String nearbyRadiusChip(int meters, int count) {
    return '$meters m ($count)';
  }

  @override
  String nearbyLinesInRadius(int count, int meters) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Linien',
      one: '1 Linie',
    );
    return '$_temp0 im Umkreis von $meters m';
  }

  @override
  String nearbyAtDistance(String distance) {
    return 'In $distance';
  }

  @override
  String nearbyPassesAtDistance(String distance) {
    return 'Fährt in $distance vorbei';
  }

  @override
  String nearbyStopName(String name) {
    return 'Haltestelle $name';
  }

  @override
  String nearbyTowards(String headsign) {
    return 'Richtung $headsign';
  }

  @override
  String nearbySelectedLine(String name) {
    return 'Hervorgehoben: $name';
  }

  @override
  String nearbyEmptyTitle(int meters) {
    return 'Keine Linien im Umkreis von $meters m';
  }

  @override
  String nearbyEmptyInRadius(int meters) {
    return 'Keine Linien im Umkreis von $meters m. Versuche einen größeren Radius.';
  }

  @override
  String get nearbyUnavailableTitle =>
      'Linien in der Nähe benötigen den Offline-GTFS-Planer';

  @override
  String get nearbyUnavailableHint =>
      'Füge den Routing-Engines einen lokalen TrufiPlannerProvider mit gebündeltem GTFS hinzu.';

  @override
  String get nearbyLoadingData => 'Offline-Daten werden geladen…';

  @override
  String get nearbyFooterNote => 'Basierend auf GTFS-Linien und -Fahrplänen';

  @override
  String get nearbyOpenDetails => 'Liniendetails';

  @override
  String get nearbyClearSelection => 'Hervorhebung entfernen';

  @override
  String get nearbyClose => 'Schließen';
}
