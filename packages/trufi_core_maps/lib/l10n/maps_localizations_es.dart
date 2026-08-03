// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'maps_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class MapsLocalizationsEs extends MapsLocalizations {
  MapsLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get online => 'En línea';

  @override
  String get offline => 'Sin conexión';

  @override
  String get mapSettings => 'Configuración del mapa';

  @override
  String get mapType => 'Tipo de mapa';

  @override
  String get chooseMapStyle => 'Elige tu estilo de mapa preferido';

  @override
  String get changeMapType => 'Cambiar tipo de mapa';

  @override
  String get chooseOnMap => 'Elegir en el mapa';

  @override
  String get confirmLocation => 'Confirmar ubicación';

  @override
  String get offlineMapName => 'Mapa offline';

  @override
  String get offlineMapDescription => 'Mapa completamente offline';

  @override
  String get errorLoadingOfflineMap => 'Error al cargar el mapa offline';

  @override
  String get retry => 'Reintentar';

  @override
  String get vectorMapDescription =>
      'Mapa vectorial con estilo moderno y mejor rendimiento';

  @override
  String get lightVectorMapDescription => 'Mapa vectorial claro';

  @override
  String get darkVectorMapDescription => 'Mapa vectorial oscuro';
}
