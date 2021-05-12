import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class PreferenceState extends Equatable {
  final String languageCode;
  final String correlationId;

  const PreferenceState({
    @required this.languageCode,
     this.correlationId,
  });

  PreferenceState copyWith({
    String languageCode,
    String correlationId,
  }) {
    return PreferenceState(
      languageCode: languageCode ?? this.languageCode,
      correlationId: correlationId ?? this.correlationId,
    );
  }

  @override
  List<Object> get props => [languageCode, correlationId];

  @override
  String toString() {
    return "Preference {languageCode: $languageCode, correlationId: $correlationId}";
  }
}
