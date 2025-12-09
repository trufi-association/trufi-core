// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'home_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class HomeLocalizationsEs extends HomeLocalizations {
  HomeLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get homeTitle => 'Bienvenido a Trufi';

  @override
  String get homeSubtitle => 'Tu viaje comienza aquí';

  @override
  String get homeSearchPlaceholder => '¿A dónde quieres ir?';

  @override
  String get homeQuickActions => 'Acciones Rápidas';

  @override
  String get homeFavorites => 'Favoritos';

  @override
  String get homePocFeatures => 'Características del POC';
}
