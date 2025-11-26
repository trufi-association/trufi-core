import 'package:trufi_core/models/plan_entity.dart';
import 'enums/alert_cause_type.dart';
import 'enums/alert_effect_type.dart';
import 'enums/alert_severity_level_type.dart';
import 'pattern.dart';
import 'translated_string.dart';
import 'trip.dart';

class AlertEntity {
  final String? id;
  final String? alertId;
  final int? alertHash;
  final String? feed;
  final AgencyEntity? agency;
  final RouteEntity? route;
  final TripEntity? trip;
  final StopEntity? stop;
  final List<PatternOtpEntity>? patterns;
  final String? alertHeaderText;
  final List<TranslatedStringEntity>? alertHeaderTextTranslations;
  final String? alertDescriptionText;
  final List<TranslatedStringEntity>? alertDescriptionTextTranslations;
  final String? alertUrl;
  final List<TranslatedStringEntity>? alertUrlTranslations;
  final AlertEffectTypeTrufi? alertEffect;
  final AlertCauseTypeTrufi? alertCause;
  final AlertSeverityLevelTypeTrufi? alertSeverityLevel;
  final double? effectiveStartDate;
  final double? effectiveEndDate;
  final List<String>? entities;

  // Custom field
  final String? sourceAlert;

  const AlertEntity({
    this.id,
    this.alertId,
    this.alertHash,
    this.feed,
    this.agency,
    this.route,
    this.trip,
    this.stop,
    this.patterns,
    this.alertHeaderText,
    this.alertHeaderTextTranslations,
    this.alertDescriptionText,
    this.alertDescriptionTextTranslations,
    this.alertUrl,
    this.alertUrlTranslations,
    this.alertEffect,
    this.alertCause,
    this.alertSeverityLevel,
    this.effectiveStartDate,
    this.effectiveEndDate,
    this.entities,
    this.sourceAlert,
  });

  static const String _id = 'id';
  static const String _alertId = 'alertId';
  static const String _alertHash = 'alertHash';
  static const String _feed = 'feed';
  static const String _agency = 'agency';
  static const String _route = 'route';
  static const String _trip = 'trip';
  static const String _stop = 'stop';
  static const String _patterns = 'patterns';
  static const String _alertHeaderText = 'alertHeaderText';
  static const String _alertHeaderTextTranslations =
      'alertHeaderTextTranslations';
  static const String _alertDescriptionText = 'alertDescriptionText';
  static const String _alertDescriptionTextTranslations =
      'alertDescriptionTextTranslations';
  static const String _alertUrl = 'alertUrl';
  static const String _alertUrlTranslations = 'alertUrlTranslations';
  static const String _alertEffect = 'alertEffect';
  static const String _alertCause = 'alertCause';
  static const String _alertSeverityLevel = 'alertSeverityLevel';
  static const String _effectiveStartDate = 'effectiveStartDate';
  static const String _effectiveEndDate = 'effectiveEndDate';
  static const String _entities = 'entities';
  static const String _sourceAlert = 'sourceAlert';
  static const String _typeName = '__typename';

  factory AlertEntity.fromJson(Map<String, dynamic> json) => AlertEntity(
    id: json[_id],
    alertId: json[_alertId],
    alertHash: json[_alertHash],
    feed: json[_feed],
    agency:
        json[_agency] != null
            ? AgencyEntity.fromJson(json[_agency] as Map<String, dynamic>)
            : null,
    route:
        json[_route] != null
            ? RouteEntity.fromJson(json[_route] as Map<String, dynamic>)
            : null,
    trip:
        json[_trip] != null
            ? TripEntity.fromJson(json[_trip] as Map<String, dynamic>)
            : null,
    stop:
        json[_stop] != null
            ? StopEntity.fromJson(json[_stop] as Map<String, dynamic>)
            : null,
    patterns:
        json[_patterns] != null
            ? List<PatternOtpEntity>.from(
              (json[_patterns] as List<dynamic>).map(
                (x) => PatternOtpEntity.fromJson(x as Map<String, dynamic>),
              ),
            )
            : null,
    alertHeaderText: json[_alertHeaderText],
    alertHeaderTextTranslations:
        json[_alertHeaderTextTranslations] != null
            ? List<TranslatedStringEntity>.from(
              (json[_alertHeaderTextTranslations] as List<dynamic>).map(
                (x) => TranslatedStringEntity.fromJson(x as Map<String, dynamic>),
              ),
            )
            : null,
    alertDescriptionText: json[_alertDescriptionText],
    alertDescriptionTextTranslations:
        json[_alertDescriptionTextTranslations] != null
            ? List<TranslatedStringEntity>.from(
              (json[_alertDescriptionTextTranslations] as List<dynamic>).map(
                (x) => TranslatedStringEntity.fromJson(x as Map<String, dynamic>),
              ),
            )
            : null,
    alertUrl: json[_alertUrl],
    alertUrlTranslations:
        json[_alertUrlTranslations] != null
            ? List<TranslatedStringEntity>.from(
              (json[_alertUrlTranslations] as List<dynamic>).map(
                (x) => TranslatedStringEntity.fromJson(x as Map<String, dynamic>),
              ),
            )
            : null,
    alertEffect: getAlertEffectTypeByString(json[_alertEffect]),
    alertCause: getAlertCauseTypeByString(json[_alertCause]),
    alertSeverityLevel: getAlertSeverityLevelTypeByString(
      json[_alertSeverityLevel],
    ),
    effectiveStartDate: json[_effectiveStartDate],
    effectiveEndDate: json[_effectiveStartDate],
    entities:
        json[_entities] != null
            ? List<String>.from(
              (json[_entities] as List<dynamic>).map((x) => x[_typeName] ?? ''),
            )
            : null,
    sourceAlert: json[_sourceAlert],
  );

  Map<String, dynamic> toJson() => {
    _id: id,
    _alertId: alertId,
    _alertHash: alertHash,
    _feed: feed,
    _agency: agency?.toJson(),
    _route: route?.toJson(),
    _trip: trip?.toJson(),
    _stop: stop?.toJson(),
    _patterns:
        patterns != null
            ? List<dynamic>.from(patterns!.map((x) => x.toJson()))
            : null,
    _alertHeaderText: alertHeaderText,
    _alertHeaderTextTranslations:
        alertHeaderTextTranslations != null
            ? List<dynamic>.from(
              alertHeaderTextTranslations!.map((x) => x.toJson()),
            )
            : null,
    _alertDescriptionText: alertDescriptionText,
    _alertDescriptionTextTranslations:
        alertDescriptionTextTranslations != null
            ? List<dynamic>.from(
              alertDescriptionTextTranslations!.map((x) => x.toJson()),
            )
            : null,
    _alertUrl: alertUrl,
    _alertUrlTranslations:
        alertUrlTranslations != null
            ? List<dynamic>.from(alertUrlTranslations!.map((x) => x.toJson()))
            : null,
    _alertEffect: alertEffect?.name,
    _alertCause: alertCause?.name,
    _alertSeverityLevel: alertSeverityLevel?.name,
    _effectiveStartDate: effectiveStartDate,
    _effectiveEndDate: effectiveEndDate,
    _entities: entities?.map((e) => {_typeName: e}).toList(),
    _sourceAlert: sourceAlert,
  };
}
