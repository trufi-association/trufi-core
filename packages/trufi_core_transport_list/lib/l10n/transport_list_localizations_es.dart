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
}
