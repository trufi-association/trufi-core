import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';

class PreferencesBloc extends BlocBase {
  static const String keyLanguageCode = "language_code";

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
}
