import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/models/preferences.dart';
import 'package:trufi_core/repository/shared_preferences_repository.dart';
import 'package:trufi_core/trufi_models.dart';
import 'package:uuid/uuid.dart';

class PreferencesBloc extends Cubit<Preference> {
  SharedPreferencesRepository sharedPreferencesRepository;
  static const bool defaultOnline = true;
  static const String defaultMapType = MapStyle.streets;
  static const String defaultLanguageCode = "en";

  PreferencesBloc(this.sharedPreferencesRepository)
      : super(const Preference(defaultLanguageCode, "", defaultMapType,
            loadOnline: defaultOnline)) {
    load();
  }

  void updateMapType(String mapType) {
    emit(state.copyWith(currentMapType: mapType));
  }

  Future<void> updateLanguage(String languageCode) async {
    sharedPreferencesRepository.saveLanguageCode(languageCode);
    emit(state.copyWith(languageCode: languageCode));
  }

  Future<void> updateOnline({bool loadOnline = false}) async {
    sharedPreferencesRepository.saveUseOnline(loadOnline: loadOnline);
    emit(state.copyWith(loadOnline: loadOnline));
  }

  Future<void> updateStateHomePage(String stateHomePage) async {
    if (stateHomePage == null) {
      await sharedPreferencesRepository.deleteStateHomePage();
    } else {
      await sharedPreferencesRepository.saveStateHomePage(stateHomePage);
    }
    emit(state.copyWith(stateHomePage: stateHomePage));
  }

  Future<void> _loadCorrelationId() async {
    String correlationId = await sharedPreferencesRepository.getCorrelationId();

    // Generate new UUID if missing
    if (correlationId == null) {
      correlationId = Uuid().v4();
      await sharedPreferencesRepository.saveCorrelationId(correlationId);
    }
  }

  Future<void> _loadLanguageCode() async {
    final String languageCode =
        await sharedPreferencesRepository.getLanguageCode();
    if (languageCode != null) {
      emit(state.copyWith(languageCode: languageCode));
    }
  }

  Future<void> _loadOnline() async {
    emit(
      state.copyWith(
        loadOnline:
            await sharedPreferencesRepository.getOnline() ?? defaultOnline,
      ),
    );
  }

  Future<void> _loadMapType() async {
    emit(
      state.copyWith(
        currentMapType:
            await sharedPreferencesRepository.getMapType() ?? defaultMapType,
      ),
    );
  }

  void load() {
    _loadCorrelationId();
    _loadLanguageCode();
    _loadOnline();
    _loadMapType();
  }
}
