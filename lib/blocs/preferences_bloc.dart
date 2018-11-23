import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';

class PreferencesBloc extends BlocBase {
  static PreferencesBloc of(BuildContext context) {
    return BlocProvider.of<PreferencesBloc>(context);
  }

  static const String propertyLanguageCodeKey = "property_language_code";
  static const String propertyOnlineKey = "property_online";
  static const String stateHomePageKey = "state_home_page";

  static const bool defaultOnline = true;

  PreferencesBloc() {
    _changeLanguageCodeController.listen(_handleChangeLanguageCode);
    _changeOnlineController.listen(_handleChangeOnline);
    SharedPreferences.getInstance().then((preferences) {
      _preferences = preferences;
      _load();
    });
  }

  void _load() {
    _loadLanguageCode();
    _loadOnline();
  }

  void _loadLanguageCode() {
    String languageCode = _preferences.getString(propertyLanguageCodeKey);
    if (languageCode != null) {
      inChangeLanguageCode.add(languageCode);
    }
  }

  void _loadOnline() {
    inChangeOnline.add(
      _preferences.getBool(propertyOnlineKey) ?? defaultOnline,
    );
  }

  SharedPreferences _preferences;

  // Change language code
  final _changeLanguageCodeController = BehaviorSubject<String>();

  Sink<String> get inChangeLanguageCode {
    return _changeLanguageCodeController.sink;
  }

  Stream<String> get outChangeLanguageCode {
    return _changeLanguageCodeController.stream;
  }

  // Change online
  final _changeOnlineController = BehaviorSubject<bool>();

  Sink<bool> get inChangeOnline {
    return _changeOnlineController.sink;
  }

  Stream<bool> get outChangeOnline {
    return _changeOnlineController.stream;
  }

  // Dispose

  @override
  void dispose() {
    _changeLanguageCodeController.close();
    _changeOnlineController.close();
  }

  // Handle

  void _handleChangeOnline(bool value) {
    _preferences.setBool(propertyOnlineKey, value);
  }

  void _handleChangeLanguageCode(String value) {
    _preferences.setString(propertyLanguageCodeKey, value);
  }

  // Getter

  String get stateHomePage => _preferences?.getString(stateHomePageKey);

  // Setter

  set stateHomePage(String value) {
    _preferences?.setString(stateHomePageKey, value);
  }
}
