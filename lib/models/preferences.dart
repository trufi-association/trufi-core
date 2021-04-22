import 'package:equatable/equatable.dart';

class Preference extends Equatable {
  const Preference(this.languageCode, this.correlationId, this.currentMapType,
      {this.loadOnline, this.stateHomePage});

  final String stateHomePage;
  final String languageCode;
  final String correlationId;
  final String currentMapType;
  final bool loadOnline;

  Preference copyWith({
    String languageCode,
    String correlationId,
    String currentMapType,
    String stateHomePage,
    bool loadOnline,
  }) {
    return Preference(
      languageCode ?? this.languageCode,
      correlationId ?? this.correlationId,
      currentMapType ?? this.currentMapType,
      loadOnline: loadOnline ?? this.loadOnline,
      stateHomePage: stateHomePage ?? this.stateHomePage,
    );
  }

  @override
  List<Object> get props =>
      [languageCode, correlationId, currentMapType, loadOnline, stateHomePage];

  @override
  String toString() {
    return "Preference {languageCode: $languageCode, correlationId: $correlationId, currentMapType: $currentMapType, loadOnline: $loadOnline, stateHomePage $stateHomePage}";
  }
}
