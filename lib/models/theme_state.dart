import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ThemeState extends Equatable {
  final ThemeData? activeTheme;
  final ThemeData? searchTheme;
  final ThemeData? bottomBarTheme;

  const ThemeState({this.activeTheme, this.searchTheme, this.bottomBarTheme});

  @override
  List<Object?> get props => [activeTheme, searchTheme, bottomBarTheme];

  @override
  String toString() =>
      "ThemeState: {activeTheme $activeTheme, searchTheme $searchTheme}, bottomBarTheme $bottomBarTheme}";
}
