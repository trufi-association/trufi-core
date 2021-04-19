import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trufi_core/models/preferences.dart';
import 'package:uuid/uuid.dart';

class PreferencesBloc extends Cubit<Preference> {
  SharedPreferences _preferences;
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
  static const String defaultLanguageCode = "en";

  PreferencesBloc()
      : super(const Preference(defaultLanguageCode, "", defaultMapType,
            loadOnline: defaultOnline)) {
    load();
  }

  void updateLanguage(String languageCode) => emit(
        state.copyWith(languageCode: languageCode),
      );

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
      emit(state.copyWith(languageCode: languageCode));
    }
  }

  void _loadOnline() {
    emit(
      state.copyWith(
        loadOnline: _preferences.getBool(propertyOnlineKey) ?? defaultOnline,
      ),
    );
  }

  void _loadMapType() {
    emit(
      state.copyWith(
        currentMapType:
            _preferences.getString(propertyMapTypeKey) ?? defaultMapType,
      ),
    );
  }

  Future<void> load() async {
    _preferences = await SharedPreferences.getInstance();
    _loadCorrelationId();
    _loadLanguageCode();
    _loadOnline();
    _loadMapType();
  }
}
