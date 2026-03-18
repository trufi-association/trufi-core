// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'navigation_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class NavigationLocalizationsEs extends NavigationLocalizations {
  NavigationLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get navExitNavigation => 'Salir de la navegación';

  @override
  String get navExitConfirmTitle => '¿Salir de la navegación?';

  @override
  String get navExitConfirmMessage =>
      '¿Estás seguro de que deseas dejar de navegar esta ruta?';

  @override
  String get navCancel => 'Cancelar';

  @override
  String get navExit => 'Salir';

  @override
  String get navClose => 'Cerrar';

  @override
  String get navRetry => 'Reintentar';

  @override
  String get navSettings => 'Configuración';

  @override
  String get navArrived => '¡Has llegado!';

  @override
  String get navOffRoute => 'Parece que estás fuera de la ruta';

  @override
  String get navWeakGps => 'La señal GPS es débil';

  @override
  String get navNext => 'Siguiente: ';

  @override
  String get navError => 'Ocurrió un error';

  @override
  String get navStarting => 'Iniciando navegación...';

  @override
  String get navGettingLocation => 'Obteniendo tu ubicación';

  @override
  String get navCouldNotStartTracking =>
      'No se pudo iniciar el seguimiento de ubicación';

  @override
  String get navArrivedShort => 'Has llegado';

  @override
  String get navOneStop => '1 parada';

  @override
  String navStops(int count) {
    return '$count paradas';
  }

  @override
  String navExitAt(String stopName) {
    return 'Baja en $stopName';
  }

  @override
  String get navFinalDestination => 'Destino final';

  @override
  String get navPermissionDenied => 'Permiso de ubicación denegado';

  @override
  String get navPermissionPermanentlyDenied =>
      'Permiso de ubicación denegado permanentemente. Habilítalo en la configuración.';

  @override
  String get navLocationDisabled =>
      'Los servicios de ubicación están deshabilitados. Habilítalos.';

  @override
  String get navOrigin => 'Origen';

  @override
  String get navTransfer => 'Transbordo';

  @override
  String get navDestination => 'Destino';
}
