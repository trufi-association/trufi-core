part of 'theme_cubit.dart';

@immutable
class TrufiBaseTheme extends Equatable {
  final ThemeMode themeMode;
  final Brightness brightness;
  final ThemeData theme;
  final ThemeData darkTheme;
  const TrufiBaseTheme({
    required this.themeMode,
    required this.brightness,
    required this.theme,
    required this.darkTheme,
  });

  TrufiBaseTheme copyWith({
    ThemeMode? themeMode,
    Brightness? brightness,
  }) {
    return TrufiBaseTheme(
      themeMode: themeMode ?? this.themeMode,
      brightness: brightness ?? this.brightness,
      theme: theme,
      darkTheme: darkTheme,
    );
  }

  @override
  List<Object?> get props => [themeMode, brightness];
}

class TrufiBaseThemeHiveLocalRepository {
  static const String path = "TrufiBaseTheme";
  static const String _themeModeKey = 'TrufiBaseTheme_themeModeKey';

  late Box _box;

  void loadRepository() {
    _box = Hive.box(path);
  }

  Future<ThemeMode?> getThemeMode() async {
    return _parseThemeMode((_box.get(_themeModeKey) ?? 0) as int);
  }

  Future<void> saveThemeMode(ThemeMode data) async {
    await _box.put(_themeModeKey, data.index);
  }

  static ThemeMode _parseThemeMode(int index) {
    switch (index) {
      case 0:
        return ThemeMode.system;
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
