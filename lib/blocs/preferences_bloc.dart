import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../blocs/bloc_provider.dart';

class PreferencesBloc extends BlocBase {
  static PreferencesBloc of(BuildContext context) {
    return TrufiBlocProvider.of<PreferencesBloc>(context);
  }

  static const String correlationIdKey = "correlation_id";
  static const String propertyLanguageCodeKey = "property_language_code";
  static const String propertyOnlineKey = "property_online";
  static const String propertyMapTypeKey = "property_map_type";
  static const String stateHomePageKey = "state_home_page";
  static const String reviewWorthyActionCountKey = "review_worthy_action_count";
  static const String lastReviewRequestAppVersionKey =
      "last_review_request_app_version";

  static const bool defaultOnline = true;
  static const String defaultMapType = "";

  PreferencesBloc() {
    _changeLanguageCodeController.listen(_handleChangeLanguageCode);
    _changeOnlineController.listen(_handleChangeOnline);
    SharedPreferences.getInstance().then((preferences) {
      _preferences = preferences;
      _load();
    });
  }

  void _load() {
    _loadCorrelationId();
    _loadLanguageCode();
    _loadOnline();
    _loadMapType();
  }

  void _loadCorrelationId() {
    String correlationId = _preferences.getString(correlationIdKey);

    // Generate new UUID if missing
    if (correlationId == null) {
      correlationId = Uuid().v4();
      _preferences.setString(correlationIdKey, correlationId);
    }
  }

  void _loadLanguageCode() {
    final String languageCode = _preferences.getString(propertyLanguageCodeKey);
    if (languageCode != null) {
      inChangeLanguageCode.add(languageCode);
    }
  }

  void _loadOnline() {
    inChangeOnline.add(
      _preferences.getBool(propertyOnlineKey) ?? defaultOnline,
    );
  }

  void _loadMapType() {
    inChangeMapType.add(
      _preferences.getString(propertyMapTypeKey) ?? defaultMapType,
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

  // Change map type
  final _changeMapTypeController = BehaviorSubject<String>();

  Sink<String> get inChangeMapType {
    return _changeMapTypeController.sink;
  }

  Stream<String> get outChangeMapType {
    return _changeMapTypeController.stream;
  }

  // Dispose

  @override
  void dispose() {
    _changeLanguageCodeController.close();
    _changeOnlineController.close();
    _changeMapTypeController.close();
  }

  // Handle

  void _handleChangeOnline(bool value) {
    _preferences.setBool(propertyOnlineKey, value);
  }

  void _handleChangeLanguageCode(String value) {
    _preferences.setString(propertyLanguageCodeKey, value);
  }

  // Getter

  String get correlationId => _preferences?.getString(correlationIdKey);
  String get stateHomePage => _preferences?.getString(stateHomePageKey);
  int get reviewWorthyActionCount =>
      _preferences?.getInt(reviewWorthyActionCountKey);
  String get lastReviewRequestAppVersion =>
      _preferences?.getString(lastReviewRequestAppVersionKey);

  // Setter

  set correlationId(String value) {
    _preferences?.setString(correlationIdKey, value);
  }

  set stateHomePage(String value) {
    _preferences?.setString(stateHomePageKey, value);
  }

  set reviewWorthyActionCount(int count) {
    _preferences?.setInt(reviewWorthyActionCountKey, count);
  }

  set lastReviewRequestAppVersion(String version) {
    _preferences?.setString(lastReviewRequestAppVersionKey, version);
  }
}
