import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/models/theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit(
    ThemeData activeTheme,
    ThemeData searchTheme,
    ThemeData bottomBarTheme,
  ) : super(
          ThemeState(
            activeTheme: activeTheme,
            searchTheme: searchTheme ?? getDefaultSearchTheme(activeTheme),
            bottomBarTheme:
                bottomBarTheme ?? getDefaultBottomBarTheme(activeTheme),
          ),
        );

  static ThemeData getDefaultSearchTheme(ThemeData activeTheme) {
    return activeTheme.copyWith(
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: const MaterialColor(
          0xffffffff,
          <int, Color>{
            50: Color(0xffeceff1),
            100: Color(0xffcfd8dc),
            200: Color(0xffb0bec5),
            300: Color(0xff90a4ae),
            400: Color(0xff78909c),
            500: Color(0xff607d8b),
            600: Color(0xff546e7a),
            700: Color(0xff455a64),
            800: Color(0xff37474f),
            900: Color(0xff263238),
          },
        ),
        accentColor: const Color(0xffd81b60),
      ),
      primaryColorBrightness: Brightness.light,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Color(0xff607d8b),
        selectionColor: Color(0xff78909c),
        selectionHandleColor: Color(0xff78909c),
      ),
      primaryIconTheme:
          activeTheme.primaryIconTheme.copyWith(color: Colors.black54),
      textTheme: activeTheme.primaryTextTheme.copyWith(
        headline6: activeTheme.primaryTextTheme.bodyText2
            .copyWith(color: Colors.black),
        bodyText2: activeTheme.primaryTextTheme.bodyText2
            .copyWith(color: Colors.black),
        bodyText1: activeTheme.primaryTextTheme.bodyText1.copyWith(
          color: activeTheme.colorScheme.secondary,
        ),
      ),
    );
  }

  static ThemeData getDefaultBottomBarTheme(ThemeData activeTheme) {
    return activeTheme.copyWith(
      primaryColor: Colors.white,
      primaryColorBrightness: Brightness.light,
      primaryIconTheme:
          activeTheme.primaryIconTheme.copyWith(color: Colors.black54),
      textTheme: activeTheme.primaryTextTheme.copyWith(
        headline6: activeTheme.primaryTextTheme.bodyText2
            .copyWith(color: Colors.black),
        bodyText2: activeTheme.primaryTextTheme.bodyText2
            .copyWith(color: Colors.black),
        bodyText1: activeTheme.primaryTextTheme.bodyText1.copyWith(
          color: activeTheme.colorScheme.secondary,
        ),
      ),
    );
  }
}
