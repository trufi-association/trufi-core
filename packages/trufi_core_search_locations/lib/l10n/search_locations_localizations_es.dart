// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'search_locations_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class SearchLocationsLocalizationsEs extends SearchLocationsLocalizations {
  SearchLocationsLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get selectOrigin => 'Seleccionar origen';

  @override
  String get selectDestination => 'Seleccionar destino';

  @override
  String get searchOrigin => 'Buscar origen...';

  @override
  String get searchDestination => 'Buscar destino...';

  @override
  String get yourLocation => 'Tu ubicación';

  @override
  String get chooseOnMap => 'Elegir en el mapa';

  @override
  String get yourPlaces => 'TUS LUGARES';

  @override
  String get searchResults => 'RESULTADOS DE BÚSQUEDA';

  @override
  String get noResultsFound => 'No se encontraron resultados';

  @override
  String cornersOf(String street) {
    return 'Esquinas de $street';
  }

  @override
  String get seeCorners => 'Ver esquinas';
}
