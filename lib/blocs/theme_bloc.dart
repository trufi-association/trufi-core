import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit(ThemeData activeTheme, ThemeData searchTheme)
      : super(
          ThemeState(
            activeTheme: activeTheme,
            searchTheme: searchTheme ?? getDefaultSearchTheme(activeTheme),
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
}

class ThemeState extends Equatable {
  final ThemeData activeTheme;
  final ThemeData searchTheme;

  const ThemeState({this.activeTheme, this.searchTheme});

  @override
  List<Object> get props => [activeTheme, searchTheme];

  @override
  String toString() =>
      "ThemeState: {activeTheme $activeTheme, searchTheme $searchTheme}";
}
