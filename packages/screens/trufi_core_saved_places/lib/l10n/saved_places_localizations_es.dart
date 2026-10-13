// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'saved_places_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class SavedPlacesLocalizationsEs extends SavedPlacesLocalizations {
  SavedPlacesLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get menuSavedPlaces => 'Tus Lugares';

  @override
  String get yourPlaces => 'Tus Lugares';

  @override
  String get home => 'Casa';

  @override
  String get work => 'Trabajo';

  @override
  String get favorites => 'Favoritos';

  @override
  String get customPlaces => 'Favoritos';

  @override
  String get recentPlaces => 'Recientes';

  @override
  String get defaultPlaces => 'Lugares Predeterminados';

  @override
  String get setHome => 'Establecer dirección de casa';

  @override
  String get setWork => 'Establecer dirección de trabajo';

  @override
  String get editPlace => 'Editar lugar';

  @override
  String get removePlace => 'Eliminar lugar';

  @override
  String removePlaceConfirmation(String placeName) {
    return '¿Estás seguro de que quieres eliminar $placeName?';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get remove => 'Eliminar';

  @override
  String get save => 'Guardar';

  @override
  String get name => 'Nombre';

  @override
  String get enterName => 'Ingresa el nombre';

  @override
  String get nameRequired => 'El nombre es requerido';

  @override
  String get selectIcon => 'Seleccionar Icono';

  @override
  String get clearHistory => 'Limpiar';

  @override
  String get noPlacesSaved => 'Aún no hay lugares guardados';

  @override
  String get addPlace => 'Agregar Lugar';

  @override
  String get chooseOnMap => 'Elegir en el mapa';

  @override
  String get searchLocation => 'Buscar ubicación';

  @override
  String get type => 'Tipo';

  @override
  String get location => 'Ubicación';

  @override
  String get noLocationSelected => 'No se ha seleccionado ubicación';

  @override
  String get locationRequired => 'La ubicación es requerida';

  @override
  String get locationSelected => 'Ubicación seleccionada';

  @override
  String get tapToSelectLocation => 'Toca para seleccionar en el mapa';

  @override
  String get change => 'Cambiar';

  @override
  String get errorLoadingPlaces => 'Error al cargar lugares';

  @override
  String get retry => 'Reintentar';

  @override
  String get history => 'Historial';

  @override
  String placeAlreadySaved(String placeName) {
    return '\"$placeName\" ya está guardado en esa ubicación';
  }

  @override
  String get copiedToClipboard => 'Copiado';

  @override
  String get menuSavedRoutes => 'Tus Rutas';

  @override
  String get noRoutesSaved => 'Aún no hay rutas guardadas';

  @override
  String get noRoutesSavedHint =>
      'Planifica un viaje y toca el marcador para guardarlo aquí';

  @override
  String routeOrigin(String name) {
    return 'Origen: $name';
  }

  @override
  String routeDestination(String name) {
    return 'Destino: $name';
  }

  @override
  String routeSummary(String distance, String duration) {
    return '$distance, ~$duration';
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
  String get renameRoute => 'Renombrar ruta';

  @override
  String get routeName => 'Nombre de la ruta';

  @override
  String get swapDirection => 'Invertir dirección';

  @override
  String get removeRoute => 'Eliminar ruta';

  @override
  String removeRouteConfirmation(String routeName) {
    return '¿Estás seguro de que quieres eliminar $routeName?';
  }

  @override
  String routeAlreadySaved(String routeName) {
    return 'Esta ruta ya está guardada como \"$routeName\"';
  }

  @override
  String get errorLoadingRoutes => 'Error al cargar rutas';
}
