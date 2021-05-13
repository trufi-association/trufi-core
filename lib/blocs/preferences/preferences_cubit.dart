import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/preferences/preferences.dart';
import 'package:trufi_core/models/social_media/social_media_item.dart';
import 'package:trufi_core/repository/local_repository.dart';
import 'package:trufi_core/repository/shared_preferences_repository.dart';
import 'package:uuid/uuid.dart';

class PreferencesCubit extends Cubit<PreferenceState> {
  LocalRepository localRepository = SharedPreferencesRepository();
  final List<SocialMediaItem> socialMediaItems;

  PreferencesCubit(this.socialMediaItems) : super(const PreferenceState(languageCode: "en")) {
    _load();
  }

  Future<void> _load() async {
    String correlationId = await localRepository.getCorrelationId();

    // Generate new UUID if missing
    if (correlationId == null) {
      correlationId = Uuid().v4();
      await localRepository.saveCorrelationId(correlationId);
    }

    emit(
      state.copyWith(
        correlationId: correlationId,
        languageCode: await localRepository.getLanguageCode(),
      ),
    );
  }

  Future<void> updateLanguage(String languageCode) async {
    localRepository.saveLanguageCode(languageCode);
    emit(state.copyWith(languageCode: languageCode));
  }
}
