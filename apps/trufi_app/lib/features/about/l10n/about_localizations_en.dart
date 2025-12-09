// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'about_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AboutLocalizationsEn extends AboutLocalizations {
  AboutLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutDescription => 'Trufi App is a POC demonstrating the v5 architecture with dynamic screens, translations, and GoRouter.';

  @override
  String get aboutArchitectureDetails => 'Architecture Details';

  @override
  String get aboutPattern => 'Pattern';

  @override
  String get aboutNavigation => 'Navigation';

  @override
  String get aboutTranslations => 'Translations';

  @override
  String get aboutState => 'State';

  @override
  String get aboutFeaturesImplemented => 'Features Implemented';

  @override
  String get aboutReferenceIssue => 'Reference Issue';
}
