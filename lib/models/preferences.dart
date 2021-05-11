import 'package:equatable/equatable.dart';

class Preference extends Equatable {
  const Preference(
    this.languageCode,
    this.correlationId, {
    this.loadOnline,
  });

  final String languageCode;
  final String correlationId;
  final bool loadOnline;

  Preference copyWith({
    String languageCode,
    String correlationId,
    String currentMapType,
    bool loadOnline,
  }) {
    return Preference(
      languageCode ?? this.languageCode,
      correlationId ?? this.correlationId,
      loadOnline: loadOnline ?? this.loadOnline,
    );
  }

  @override
  List<Object> get props => [languageCode, correlationId, loadOnline];

  @override
  String toString() {
    return "Preference {languageCode: $languageCode, correlationId: $correlationId, loadOnline: $loadOnline}";
  }
}
