import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/models/preferences.dart';
import 'package:trufi_core/repository/local_repository.dart';
import 'package:trufi_core/trufi_models.dart';
import 'package:uuid/uuid.dart';

class PreferencesCubit extends Cubit<Preference> {
  LocalRepository localRepository;
  Uuid uuid;

  static const bool defaultOnline = true;
  static const String defaultMapType = MapStyle.streets;
  static const String defaultLanguageCode = "en";

  PreferencesCubit(this.localRepository, this.uuid)
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

  Future<void> load() async {
    String correlationId = await localRepository.getCorrelationId();

    // Generate new UUID if missing
    if (correlationId == null) {
      correlationId = uuid.v4();
      await localRepository.saveCorrelationId(correlationId);
    }

    emit(
      state.copyWith(
        correlationId: correlationId,
        currentMapType: await localRepository.getMapType() ?? defaultMapType,
        languageCode:
            await localRepository.getLanguageCode() ?? defaultLanguageCode,
        loadOnline: await localRepository.getOnline() ?? defaultOnline,
      ),
    );
  }
}
