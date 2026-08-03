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
}
