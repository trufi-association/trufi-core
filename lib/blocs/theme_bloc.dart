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
          color: activeTheme.accentColor,
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
          color: activeTheme.accentColor,
        ),
      ),
    );
  }
}
