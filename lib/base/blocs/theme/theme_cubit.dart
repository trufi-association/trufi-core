import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<TrufiBaseTheme> {
  static String themeModeDisplayName(
    TrufiBaseLocalization localization,
    ThemeMode themeMode,
  ) {
    switch (themeMode) {
      case ThemeMode.system:
        return localization.themeModeSystem;
      case ThemeMode.light:
        return localization.themeModeLight;
      case ThemeMode.dark:
        return localization.themeModeDark;
      default:
        return localization.themeModeSystem;
    }
  }

  final _localRepository = TrufiBaseThemeHiveLocalRepository();

  ThemeCubit({
    required TrufiBaseTheme themeState,
  }) : super(themeState) {
    _load();
  }

  Future<void> _load() async {
    _localRepository.loadRepository();
    emit(state.copyWith(themeMode: await _localRepository.getThemeMode()));
  }

  void updateTheme({
    ThemeMode? themeMode,
  }) {
    emit(state.copyWith(
      themeMode: themeMode,
    ));
    _localRepository.saveThemeMode(state.themeMode);
  }

  ThemeData themeData(BuildContext context) {
    final ThemeMode mode = state.themeMode;
    final Brightness platformBrightness =
        MediaQuery.platformBrightnessOf(context);
    final bool useDarkTheme = mode == ThemeMode.dark ||
        (mode == ThemeMode.system && platformBrightness == Brightness.dark);
    if (useDarkTheme) {
      return state.darkTheme;
    } else {
      return state.theme;
    }
  }

  static bool isDarkMode(ThemeData themeData) {
    return themeData.brightness == Brightness.dark;
  }
}
