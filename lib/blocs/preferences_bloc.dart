import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/models/preferences.dart';
import 'package:trufi_core/repository/local_repository.dart';
import 'package:trufi_core/trufi_models.dart';
import 'package:uuid/uuid.dart';

class PreferencesBloc extends Cubit<Preference> {
  LocalRepository localRepository;
  static const bool defaultOnline = true;
  static const String defaultMapType = MapStyle.streets;
  static const String defaultLanguageCode = "en";

  PreferencesBloc(this.localRepository)
      : super(const Preference(defaultLanguageCode, "", defaultMapType,
            loadOnline: defaultOnline)) {
    load();
  }

  void updateMapType(String mapType) {
    emit(state.copyWith(currentMapType: mapType));
  }

  Future<void> updateLanguage(String languageCode) async {
    localRepository.saveLanguageCode(languageCode);
    emit(state.copyWith(languageCode: languageCode));
  }

  Future<void> updateOnline({bool loadOnline = false}) async {
    localRepository.saveUseOnline(loadOnline: loadOnline);
    emit(state.copyWith(loadOnline: loadOnline));
  }

  Future<void> updateStateHomePage(String stateHomePage) async {
    if (stateHomePage == null) {
      await localRepository.deleteStateHomePage();
    } else {
      await localRepository.saveStateHomePage(stateHomePage);
    }
    emit(state.copyWith(stateHomePage: stateHomePage));
  }

  Future<void> _loadCorrelationId() async {
    String correlationId = await localRepository.getCorrelationId();

    // Generate new UUID if missing
    if (correlationId == null) {
      correlationId = Uuid().v4();
      await localRepository.saveCorrelationId(correlationId);
    }
  }

  Future<void> _loadLanguageCode() async {
    final String languageCode = await localRepository.getLanguageCode();
    if (languageCode != null) {
      emit(state.copyWith(languageCode: languageCode));
    }
  }

  Future<void> _loadOnline() async {
    emit(
      state.copyWith(
        loadOnline: await localRepository.getOnline() ?? defaultOnline,
      ),
    );
  }

  Future<void> _loadMapType() async {
    emit(
      state.copyWith(
        currentMapType: await localRepository.getMapType() ?? defaultMapType,
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
