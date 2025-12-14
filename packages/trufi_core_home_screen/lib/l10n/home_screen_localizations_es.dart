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
}
