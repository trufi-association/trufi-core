// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'about_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AboutLocalizationsEs extends AboutLocalizations {
  AboutLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String get aboutVersion => 'Versión';

  @override
  String get aboutDescription => 'Trufi App es un POC que demuestra la arquitectura v5 con pantallas dinámicas, traducciones y GoRouter.';

  @override
  String get aboutArchitectureDetails => 'Detalles de Arquitectura';

  @override
  String get aboutPattern => 'Patrón';

  @override
  String get aboutNavigation => 'Navegación';

  @override
  String get aboutTranslations => 'Traducciones';

  @override
  String get aboutState => 'Estado';

  @override
  String get aboutFeaturesImplemented => 'Características Implementadas';

  @override
  String get aboutReferenceIssue => 'Issue de Referencia';
}
