import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong/latlong.dart';
import 'package:trufi_core/blocs/preferences/preferences.dart';
import 'package:trufi_core/models/social_media/social_media_item.dart';
import 'package:trufi_core/repository/entities/weather_info.dart';
import 'package:trufi_core/repository/local_repository.dart';
import 'package:trufi_core/repository/shared_preferences_repository.dart';
import 'package:trufi_core/repository/wfs_weather_data_repository.dart';
import 'package:uuid/uuid.dart';

class PreferencesCubit extends Cubit<PreferenceState> {
  LocalRepository localRepository = SharedPreferencesRepository();
  final LatLng currentLocation;
  final List<SocialMediaItem> socialMediaItems;

  PreferencesCubit(this.socialMediaItems, this.currentLocation)
      : super(const PreferenceState(languageCode: "en")) {
    _load();
  }

  Future<void> _load() async {
    String correlationId = await localRepository.getCorrelationId();
    final WeatherInfo weatherInfo = await WFSWeatherDataRepository()
        .getCurrentWeatherAtLocation(DateTime.now(), currentLocation);

    // Generate new UUID if missing
    if (correlationId == null) {
      correlationId = Uuid().v4();
      await localRepository.saveCorrelationId(correlationId);
    }

    emit(
      state.copyWith(
          correlationId: correlationId,
          languageCode: await localRepository.getLanguageCode(),
          weatherInfo: weatherInfo),
    );
  }

  Future<void> updateLanguage(String languageCode) async {
    localRepository.saveLanguageCode(languageCode);
    emit(state.copyWith(languageCode: languageCode));
  }
}
