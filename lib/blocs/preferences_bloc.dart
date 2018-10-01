import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';

class PreferencesBloc extends BlocBase {
  static PreferencesBloc of(BuildContext context) {
    return BlocProvider.of<PreferencesBloc>(context);
  }

  static const String keyLanguageCode = "language_code";
  static const String keyStateHomePage = "state_home_page";

  PreferencesBloc() {
    _switchLanguageCodeController.listen(_handleSwitchLanguage);
    SharedPreferences.getInstance().then((preferences) {
      _preferences = preferences;
      String languageCode = preferences.getString(keyLanguageCode);
      if (languageCode != null) {
        inSwitchLanguageCode.add(languageCode);
      }
    });
  }

  SharedPreferences _preferences;

  // Switch language code
  BehaviorSubject<String> _switchLanguageCodeController =
      new BehaviorSubject<String>();

  Sink<String> get inSwitchLanguageCode {
    return _switchLanguageCodeController.sink;
  }

  Stream<String> get outSwitchLanguageCode {
    return _switchLanguageCodeController.stream;
  }

  // Dispose

  @override
  void dispose() {
    _switchLanguageCodeController.close();
  }

  // Handle

  void _handleSwitchLanguage(String languageCode) {
    _preferences.setString(keyLanguageCode, languageCode);
  }

  // Getter

  String get languageCode => _preferences?.getString(keyLanguageCode);

  String get stateHomePage => _preferences?.getString(keyStateHomePage);

  // Setter

  set stateHomePage(String value) {
    _preferences?.setString(keyStateHomePage, value);
  }
}
