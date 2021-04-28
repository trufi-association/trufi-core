import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

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
