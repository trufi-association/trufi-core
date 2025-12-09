// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'about_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AboutLocalizationsDe extends AboutLocalizations {
  AboutLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get aboutTitle => 'Über';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutDescription => 'Trufi App ist ein POC, das die v5-Architektur mit dynamischen Bildschirmen, Übersetzungen und GoRouter demonstriert.';

  @override
  String get aboutArchitectureDetails => 'Architekturdetails';

  @override
  String get aboutPattern => 'Muster';

  @override
  String get aboutNavigation => 'Navigation';

  @override
  String get aboutTranslations => 'Übersetzungen';

  @override
  String get aboutState => 'Zustand';

  @override
  String get aboutFeaturesImplemented => 'Implementierte Funktionen';

  @override
  String get aboutReferenceIssue => 'Referenz-Issue';
}
