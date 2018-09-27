import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';

class PreferencesBloc extends BlocBase {
  PreferencesBloc() {
    SharedPreferences.getInstance().then((preferences) {
      _preferences = preferences;
    });
  }

  // Change language
  BehaviorSubject<String> _changeLanguageCodeController =
      new BehaviorSubject<String>();

  Sink<String> get inChangeLanguageCode => _changeLanguageCodeController.sink;

  Stream<String> get outChangeLanguageCode => _changeLanguageCodeController.stream;

  SharedPreferences _preferences;

  @override
  void dispose() {
    _changeLanguageCodeController.close();
  }
}
