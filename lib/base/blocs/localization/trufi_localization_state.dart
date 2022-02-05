part of 'trufi_localization_cubit.dart';

@immutable
class TrufiLocalization extends Equatable {
  final Locale currentLocale;

  final List<Locale> supportedLocales;
  final List<LocalizationsDelegate> localizationDelegates;

  const TrufiLocalization({
    required this.currentLocale,
    required this.supportedLocales,
    required this.localizationDelegates,
  });

  TrufiLocalization copyWith({
    Locale? currentLocale,
  }) {
    return TrufiLocalization(
      currentLocale: currentLocale ?? this.currentLocale,
      supportedLocales: supportedLocales,
      localizationDelegates: localizationDelegates,
    );
  }

  @override
  List<Object?> get props => [currentLocale];
}

class TrufiLocalizationHiveLocalRepository {
  static const String path = "TrufiLocalization";
  static const String _currentLocale = 'currentLocale';

  late Box _box;

  void loadRepository() {
    _box = Hive.box(path);
  }

  Future<Locale?> getLocale() async {
    if (!_box.containsKey(_currentLocale)) return null;
    return Locale(_box.get(_currentLocale));
  }

  Future<void> saveLocale(Locale data) async {
    await _box.put(_currentLocale, data.languageCode);
  }
}
