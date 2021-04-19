import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trufi_core/blocs/preferences/preferences.dart';
import 'package:trufi_core/blocs/preferences/preferences_state.dart';
import 'package:trufi_core/models/preferences.dart';
import 'package:uuid/uuid.dart';

class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState> {
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

  SharedPreferences _preferences;

  PreferencesBloc() : super(PreferencesLoading());

  @override
  Stream<PreferencesState> mapEventToState(PreferencesEvent event) async* {
    if (event is PreferencesLoadSuccess) {
      yield* _mapPreferencesSuccess();
    }

    if (event is UpdatePreferences) {
      yield* _mapPreferenceUpdatedToState(event);
    }

    if (event is UpdateOnline) {
      yield* _mapUpdatedOnlineToState(event);
    }
  }

  Stream<PreferencesState> _mapPreferencesSuccess() async* {
    try {
      await SharedPreferences.getInstance().then((preferences) {
        _preferences = preferences;
      });

      final correlationId = _loadCorrelationId();
      final langCode = _loadLanguageCode();
      final loadOnline = _loadOnline();
      final currentMapType = _loadMapType();

      yield PreferencesLoadSuccess(Preference(
        langCode,
        correlationId,
        currentMapType,
        loadOnline: loadOnline,
      ));
    } catch (_) {
      yield PreferencesLoadFailure();
    }
  }

  Stream<PreferencesState> _mapPreferenceUpdatedToState(
      UpdatePreferences event) async* {
    if (state is PreferencesLoadSuccess) {
      yield PreferencesLoadSuccess(event.preference);
    }
  }

  Stream<PreferencesState> _mapUpdatedOnlineToState(UpdateOnline event) async* {
    if (state is PreferencesLoadSuccess) {
      final PreferencesLoadSuccess updatedState =
          (state as PreferencesLoadSuccess)
            ..preference.copyWith(
              loadOnline: event.isOnline,
            );
      yield updatedState;
    }
  }

  String _loadCorrelationId() {
    String correlationId = _preferences.getString(correlationIdKey);

    // Generate new UUID if missing
    if (correlationId == null) {
      correlationId = Uuid().v4();
      _preferences.setString(correlationIdKey, correlationId);
    }

    return correlationId;
  }

  String _loadLanguageCode() {
    return _preferences.getString(propertyLanguageCodeKey);
  }

  bool _loadOnline() {
    return _preferences.getBool(propertyOnlineKey) ?? defaultOnline;
  }

  String _loadMapType() {
    return _preferences.getString(propertyMapTypeKey) ?? defaultMapType;
  }

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
