import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';

class PreferencesBloc extends BlocBase {
  static const String propertyLanguageCodeKey = "property_language_code";
  static const String propertyOfflineKey = "property_offline";
  static const String stateHomePageKey = "state_home_page";

  PreferencesBloc() {
    _changeLanguageCodeController.listen(_handleChangeLanguageCode);
    _changeOfflineController.listen(_handleChangeOffline);
    SharedPreferences.getInstance().then((preferences) {
      _preferences = preferences;
      _load();
    });
  }

  void _load() {
    _loadLanguageCode();
    _loadOffline();
  }

  void _loadLanguageCode() {
    String languageCode = _preferences.getString(propertyLanguageCodeKey);
    if (languageCode != null) {
      inChangeLanguageCode.add(languageCode);
    }
  }

  void _loadOffline() {
    bool offline = _preferences.getBool(propertyOfflineKey);
    if (offline != null) {
      inChangeOffline.add(offline);
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

  // Change offline
  BehaviorSubject<bool> _changeOfflineController = new BehaviorSubject<bool>();

  Sink<bool> get inChangeOffline {
    return _changeOfflineController.sink;
  }

  Stream<bool> get outChangeOffline {
    return _changeOfflineController.stream;
  }

  // Dispose

  @override
  void dispose() {
    _changeLanguageCodeController.close();
    _changeOfflineController.close();
  }

  // Handle

  void _handleChangeOffline(bool value) {
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
