import 'package:flutter/material.dart';

final stadtnaviTheme = ThemeData(
  primaryColor: const Color(0xff263238),
  primaryColorLight: const Color(0xffeceff1),
  accentColor: const Color(0xffd81b60),
  backgroundColor: Colors.white,
  textTheme: ThemeData.light().textTheme.copyWith(
        bodyText1: const TextStyle(color: Color(0xFF000000)),
        bodyText2: const TextStyle(color: Color(0xFF9EC528)),
        headline6: const TextStyle(color: Colors.white),
        subtitle1: const TextStyle(color: Colors.white),
      ),
  primaryTextTheme: ThemeData.light().primaryTextTheme.copyWith(
        headline6: const TextStyle(color: Colors.white),
        subtitle1: const TextStyle(color: Colors.white),
      ),
  primaryIconTheme: ThemeData.light().primaryIconTheme.copyWith(
        color: const Color(0xFFFDFDFE),
      ),
);

final bottomBarTheme = ThemeData(
  primaryColor: const Color(0xff263238),
  accentColor: const Color(0xffd81b60),
  backgroundColor: const Color(0xff263238),
  primaryColorLight: const Color(0xffeceff1),
  textTheme: ThemeData.light().textTheme.copyWith(
        bodyText1: const TextStyle(color: Colors.black, fontSize: 19),
        bodyText2: const TextStyle(color: Color(0xffd81b60), fontSize: 19),
        headline6: const TextStyle(color: Colors.white, fontSize: 19),
        subtitle1: const TextStyle(color: Colors.white),
      ),
  primaryTextTheme: ThemeData.light().primaryTextTheme.copyWith(
        bodyText1: const TextStyle(color: Colors.black, fontSize: 15),
        bodyText2: const TextStyle(color: Color(0xffd81b60), fontSize: 15),
        headline6: const TextStyle(color: Colors.white, fontSize: 15),
        subtitle1: const TextStyle(color: Colors.white, fontSize: 15),
      ),
  primaryIconTheme: ThemeData.light().primaryIconTheme.copyWith(
        color: Colors.white,
      ),
  accentIconTheme: ThemeData.light().primaryIconTheme.copyWith(
        color: Colors.black,
      ),
);
