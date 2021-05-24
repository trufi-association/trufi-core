import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:trufi_core/repository/entities/weather_info.dart';

class PreferenceState extends Equatable {
  final String languageCode;
  final String correlationId;
  final WeatherInfo weatherInfo;

  const PreferenceState({
    @required this.languageCode,
    this.correlationId,
    this.weatherInfo,
  });

  PreferenceState copyWith(
      {String languageCode, String correlationId, WeatherInfo weatherInfo}) {
    return PreferenceState(
      languageCode: languageCode ?? this.languageCode,
      correlationId: correlationId ?? this.correlationId,
      weatherInfo: weatherInfo ?? this.weatherInfo,
    );
  }

  @override
  List<Object> get props => [languageCode, correlationId, weatherInfo];

  @override
  String toString() {
    return "Preference: { languageCode: $languageCode, correlationId: $correlationId, weatherInfo: $weatherInfo }";
  }
}
