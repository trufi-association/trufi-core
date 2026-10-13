// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'transport_list_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class TransportListLocalizationsEs extends TransportListLocalizations {
  TransportListLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get menuTransportList => 'Rutas';

  @override
  String get searchRoutes => 'Buscar rutas';

  @override
  String get noRoutesFound => 'No se encontraron rutas';

  @override
  String get shareRoute => 'Compartir ruta';

  @override
  String stops(int count) {
    return '$count paradas';
  }

  @override
  String get routeNotFound => 'Ruta no encontrada';

  @override
  String get routeLoadError => 'No se pudo cargar la ruta';

  @override
  String get pullDownToRefresh => 'Desliza hacia abajo para actualizar';

  @override
  String get tryDifferentSearch => 'Intenta con otro término de búsqueda';

  @override
  String get buttonGoBack => 'Volver';

  @override
  String routeCount(int count) {
    return '$count rutas';
  }

  @override
  String get labelDistance => 'Distancia';

  @override
  String get labelStops => 'Paradas';

  @override
  String get labelMode => 'Modo';

  @override
  String get noStopsAvailable => 'Sin paradas disponibles';

  @override
  String get loadingRoute => 'Cargando ruta...';

  @override
  String get otherAgencies => 'Otros';

  @override
  String shareRouteMessage(String uri) {
    return 'Compartir: $uri';
  }

  @override
  String get defaultModeBus => 'Bus';

  @override
  String get mapSettingsTitle => 'Configuración del mapa';

  @override
  String get mapTypeLabel => 'Tipo de mapa';

  @override
  String get applyChanges => 'Aplicar cambios';

  @override
  String get stopStart => 'Inicio';

  @override
  String get stopEnd => 'Fin';

  @override
  String get stopInfoNotAvailable =>
      'La información de paradas no está disponible para esta ruta';

  @override
  String get errorLoadingRoutes => 'No se pudieron cargar las rutas';

  @override
  String get retry => 'Reintentar';

  @override
  String get qrShareSubtitle => 'Escanea para abrir las rutas de este operador';

  @override
  String get copyQrImage => 'Copiar QR';

  @override
  String get copyQrImageFailed => 'No se pudo copiar el QR';

  @override
  String get modeTram => 'Tranvía';

  @override
  String get modeSubway => 'Metro';

  @override
  String get modeRail => 'Tren';

  @override
  String get modeBus => 'Bus';

  @override
  String get modeFerry => 'Ferry';

  @override
  String get modeCableTram => 'Tranvía de cable';

  @override
  String get modeAerialLift => 'Teleférico';

  @override
  String get modeFunicular => 'Funicular';

  @override
  String get modeTrolleybus => 'Trolebús';

  @override
  String get modeMonorail => 'Monorriel';

  @override
  String distanceKilometers(String value) {
    return '$value km';
  }

  @override
  String distanceMeters(String value) {
    return '$value m';
  }

  @override
  String get copiedToClipboard => 'Copiado';

  @override
  String get menuNearbyLines => 'Líneas cercanas';

  @override
  String get nearbyAnchorYourLocation => 'Tu ubicación';

  @override
  String get nearbyAnchorPinned => 'Ubicación marcada';

  @override
  String get nearbyAnchorDefault =>
      'Centro de la ciudad (ubicación no disponible)';

  @override
  String get nearbyUseMyLocation => 'Usar mi ubicación';

  @override
  String get nearbyMovePinHint => 'Mantén pulsado el mapa para mover el pin';

  @override
  String nearbyRadiusChip(int meters, int count) {
    return '$meters m ($count)';
  }

  @override
  String nearbyAtDistance(String distance) {
    return 'A $distance';
  }

  @override
  String nearbyPassesAtDistance(String distance) {
    return 'Pasa a $distance';
  }

  @override
  String nearbyStopName(String name) {
    return 'Parada $name';
  }

  @override
  String nearbyTowards(String headsign) {
    return 'Hacia $headsign';
  }

  @override
  String nearbySelectedLine(String name) {
    return 'Resaltada: $name';
  }

  @override
  String nearbyEmptyTitle(int meters) {
    return 'Ninguna línea pasa a menos de $meters m';
  }

  @override
  String nearbyEmptyInRadius(int meters) {
    return 'No hay líneas a menos de $meters m. Prueba un radio mayor.';
  }

  @override
  String get nearbyUnavailableTitle =>
      'Las líneas cercanas necesitan el planificador GTFS sin conexión';

  @override
  String get nearbyUnavailableHint =>
      'Añade a los motores de rutas un TrufiPlannerProvider local con un GTFS incluido en la app.';

  @override
  String get nearbyLoadingData => 'Cargando datos sin conexión…';

  @override
  String get nearbyFooterNote => 'Basado en rutas y horarios GTFS';

  @override
  String get nearbyOpenDetails => 'Detalles de la línea';

  @override
  String get nearbyClearSelection => 'Quitar resaltado';

  @override
  String get nearbyClose => 'Cerrar';
}
