// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'search_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class SearchLocalizationsEs extends SearchLocalizations {
  SearchLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get searchTitle => 'Buscar Ubicación';

  @override
  String get searchOrigin => 'Origen';

  @override
  String get searchDestination => 'Destino';

  @override
  String get searchMyLocation => 'Mi ubicación';

  @override
  String get searchChooseOnMap => 'Elegir en el mapa';

  @override
  String get searchSwap => 'Intercambiar';

  @override
  String get searchNoResults => 'No se encontraron resultados';

  @override
  String get searchSearching => 'Buscando...';
}
