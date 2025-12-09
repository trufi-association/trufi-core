// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'home_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class HomeLocalizationsEn extends HomeLocalizations {
  HomeLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get homeTitle => 'Welcome to Trufi';

  @override
  String get homeSubtitle => 'Your journey starts here';

  @override
  String get homeSearchPlaceholder => 'Where do you want to go?';

  @override
  String get homeQuickActions => 'Quick Actions';

  @override
  String get homeFavorites => 'Favorites';

  @override
  String get homePocFeatures => 'POC Features';
}
