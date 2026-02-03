// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'home_screen_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class HomeScreenLocalizationsEs extends HomeScreenLocalizations {
  HomeScreenLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get menuHome => 'Inicio';

  @override
  String get searchOrigin => 'Seleccionar origen';

  @override
  String get searchDestination => 'Seleccionar destino';

  @override
  String get selectLocations => 'Selecciona origen y destino para buscar rutas';

  @override
  String get noRoutesFound => 'No se encontraron rutas';

  @override
  String get errorNoRoutes => 'Error al cargar rutas';

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
  String get walk => 'Caminar';

  @override
  String transfers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transbordos',
      one: '1 transbordo',
      zero: 'Sin transbordos',
    );
    return '$_temp0';
  }

  @override
  String departureAt(String time) {
    return 'Salida a las $time';
  }

  @override
  String arrivalAt(String time) {
    return 'Llegada a las $time';
  }

  @override
  String get yourLocation => 'Tu ubicación';

  @override
  String get chooseOnMap => 'Elegir en el mapa';

  @override
  String get confirmLocation => 'Confirmar ubicación';

  @override
  String get selectedLocation => 'Ubicación seleccionada';

  @override
  String get setAsOrigin => 'Establecer como origen';

  @override
  String get setAsDestination => 'Establecer como destino';

  @override
  String get shareRoute => 'Compartir ruta';

  @override
  String shareRouteTitle(String appName) {
    return '$appName - Ruta compartida';
  }

  @override
  String shareRouteOrigin(String location) {
    return 'Origen: $location';
  }

  @override
  String shareRouteDestination(String location) {
    return 'Destino: $location';
  }

  @override
  String shareRouteDate(String date) {
    return 'Fecha: $date';
  }

  @override
  String shareRouteTimes(String departure, String arrival) {
    return 'Salida: $departure → Llegada: $arrival';
  }

  @override
  String shareRouteDuration(String duration) {
    return 'Duración: $duration';
  }

  @override
  String shareRouteItinerary(String summary) {
    return 'Ruta: $summary';
  }

  @override
  String get shareRouteOpenInApp => 'Abrir en la app:';

  @override
  String get tripDetails => 'Detalles del viaje';

  @override
  String get departure => 'Salida';

  @override
  String get arrival => 'Llegada';

  @override
  String get totalDistance => 'Distancia';

  @override
  String get walking => 'Caminando';

  @override
  String get tripSteps => 'Pasos del viaje';

  @override
  String get towards => 'Hacia';

  @override
  String get stops => 'paradas';

  @override
  String get bike => 'Bicicleta';

  @override
  String get train => 'Tren';

  @override
  String get transfersLabel => 'Transbordos';

  @override
  String operatedBy(String agency) {
    return 'Operado por $agency';
  }

  @override
  String get viewFares => 'Ver tarifas';

  @override
  String co2Emissions(String grams) {
    return '${grams}g CO₂';
  }

  @override
  String get locationPermissionTitle => 'Permiso de ubicación';

  @override
  String get locationPermissionDeniedMessage =>
      'El permiso de ubicación fue denegado permanentemente. Por favor habilítalo en la configuración de tu dispositivo para usar esta función.';

  @override
  String get locationDisabledTitle => 'Ubicación desactivada';

  @override
  String get locationDisabledMessage =>
      'Los servicios de ubicación están desactivados en tu dispositivo. Por favor actívalos para usar esta función.';

  @override
  String get buttonCancel => 'Cancelar';

  @override
  String get buttonOpenSettings => 'Abrir configuración';

  @override
  String get buttonApply => 'Aplicar';

  @override
  String get searchForRoute => 'Buscar una ruta';

  @override
  String get searchForRouteHint =>
      'Ingresa origen y destino para encontrar rutas';

  @override
  String get tooltipShare => 'Compartir';

  @override
  String get tooltipClose => 'Cerrar';

  @override
  String get leaveNow => 'Salir ahora';

  @override
  String get departAt => 'Salir a las...';

  @override
  String departAtTime(String time) {
    return 'Salir $time';
  }

  @override
  String get arriveBy => 'Llegar a las...';

  @override
  String arriveByTime(String time) {
    return 'Llegar a las $time';
  }

  @override
  String get today => 'Hoy';

  @override
  String get tomorrow => 'Mañana';

  @override
  String tomorrowWithTime(String time) {
    return 'Mañana $time';
  }

  @override
  String get whenDoYouWantToTravel => '¿Cuándo quieres viajar?';

  @override
  String routesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rutas encontradas',
      one: '1 ruta encontrada',
    );
    return '$_temp0';
  }

  @override
  String get monthJan => 'Ene';

  @override
  String get monthFeb => 'Feb';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthApr => 'Abr';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthAug => 'Ago';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Dic';

  @override
  String get buttonGo => 'Ir';

  @override
  String get buttonDetails => 'Detalles';

  @override
  String get buttonTryAgain => 'Reintentar';

  @override
  String get buttonReset => 'Restablecer';

  @override
  String get routeSettings => 'Configuración de ruta';

  @override
  String get wheelchairAccessible => 'Accesible para silla de ruedas';

  @override
  String get wheelchairAccessibleOn =>
      'Las rutas evitan escaleras y pendientes pronunciadas';

  @override
  String get wheelchairAccessibleOff => 'Incluir todas las rutas';

  @override
  String get walkingSpeed => 'Velocidad al caminar';

  @override
  String get speedSlow => 'Lento';

  @override
  String get speedNormal => 'Normal';

  @override
  String get speedFast => 'Rápido';

  @override
  String get maxWalkDistance => 'Distancia máxima caminando';

  @override
  String get noLimit => 'Sin límite';

  @override
  String get transportModes => 'Modos de transporte';

  @override
  String get modeTransit => 'Transporte público';

  @override
  String get modeBicycle => 'Bicicleta';

  @override
  String get exitNavigation => 'Salir de navegación';

  @override
  String get exitNavigationTitle => '¿Salir de navegación?';

  @override
  String get exitNavigationMessage =>
      '¿Estás seguro de que quieres dejar de navegar esta ruta?';

  @override
  String get buttonExit => 'Salir';

  @override
  String get arrivedMessage => '¡Has llegado!';

  @override
  String get buttonRetry => 'Reintentar';

  @override
  String get buttonSettings => 'Configuración';

  @override
  String get findingRoutes => 'Buscando rutas...';
}
