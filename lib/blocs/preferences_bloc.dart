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
  static const String propertyOfflineKey = "property_offline";
  static const String stateHomePageKey = "state_home_page";

  PreferencesBloc() {
    _changeLanguageCodeController.listen(_handleChangeLanguageCode);
    _changeOfflineModeController.listen(_handleChangeOfflineMode);
    SharedPreferences.getInstance().then((preferences) {
      _preferences = preferences;
      _load();
    });
  }

  void _load() {
    _loadLanguageCode();
    _loadOfflineMode();
  }

  void _loadLanguageCode() {
    String languageCode = _preferences.getString(propertyLanguageCodeKey);
    if (languageCode != null) {
      inChangeLanguageCode.add(languageCode);
    }
  }

  void _loadOfflineMode() {
    bool offlineMode = _preferences.getBool(propertyOfflineKey);
    if (offlineMode != null) {
      inChangeOfflineMode.add(offlineMode);
    }
  }

  SharedPreferences _preferences;

  // Change language code
  BehaviorSubject<String> _changeLanguageCodeController =
      new BehaviorSubject<String>();

  Sink<String> get inChangeLanguageCode {
    return _changeLanguageCodeController.sink;
  }

  Stream<String> get outChangeLanguageCode {
    return _changeLanguageCodeController.stream;
  }

  // Change offline mode
  BehaviorSubject<bool> _changeOfflineModeController = new BehaviorSubject<bool>();

  Sink<bool> get inChangeOfflineMode {
    return _changeOfflineModeController.sink;
  }

  Stream<bool> get outChangeOfflineMode {
    return _changeOfflineModeController.stream;
  }

  // Dispose

  @override
  void dispose() {
    _changeLanguageCodeController.close();
    _changeOfflineModeController.close();
  }

  // Handle

  void _handleChangeOfflineMode(bool value) {
    _preferences.setBool(propertyOfflineKey, value);
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
