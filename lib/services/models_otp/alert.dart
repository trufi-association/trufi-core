import 'agency.dart';
import 'enums/alert_cause_type.dart';
import 'enums/alert_effect_type.dart';
import 'enums/alert_severity_level_type.dart';
import 'pattern.dart';
import 'route.dart';
import 'stop.dart';
import 'translated_string.dart';
import 'trip.dart';

class Alert {
  final String id;
  final String alertId;
  final int alertHash;
  final String feed;
  final Agency agency;
  final RouteOtp route;
  final Trip trip;
  final Stop stop;
  final List<PatternOtp> patterns;
  final String alertHeaderText;
  final List<TranslatedString> alertHeaderTextTranslations;
  final String alertDescriptionText;
  final List<TranslatedString> alertDescriptionTextTranslations;
  final String alertUrl;
  final List<TranslatedString> alertUrlTranslations;
  final AlertEffectType alertEffect;
  final AlertCauseType alertCause;
  final AlertSeverityLevelType alertSeverityLevel;
  final double effectiveStartDate;
  final double effectiveEndDate;

  const Alert({
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
  });

  factory Alert.fromJson(Map<String, dynamic> json) => Alert(
        id: json['id'].toString(),
        alertId: json['alertId'].toString(),
        alertHash: int.tryParse(json['alertHash'].toString()) ?? 0,
        feed: json['feed'].toString(),
        agency: json['agency'] != null
            ? Agency.fromJson(json['agency'] as Map<String, dynamic>)
            : null,
        route: json['route'] != null
            ? RouteOtp.fromJson(json['route'] as Map<String, dynamic>)
            : null,
        trip: json['trip'] != null
            ? Trip.fromJson(json['trip'] as Map<String, dynamic>)
            : null,
        stop: json['stop'] != null
            ? Stop.fromJson(json['stop'] as Map<String, dynamic>)
            : null,
        patterns: json['patterns'] != null
            ? List<PatternOtp>.from((json["patterns"] as List<dynamic>).map(
                (x) => PatternOtp.fromJson(x as Map<String, dynamic>),
              ))
            : null,
        alertHeaderText: json['alertHeaderText'].toString(),
        alertHeaderTextTranslations: json['alertHeaderTextTranslations'] != null
            ? List<TranslatedString>.from(
                (json["alertHeaderTextTranslations"] as List<dynamic>).map(
                (x) => TranslatedString.fromJson(x as Map<String, dynamic>),
              ))
            : null,
        alertDescriptionText: json['alertDescriptionText'].toString(),
        alertDescriptionTextTranslations:
            json['alertDescriptionTextTranslations'] != null
                ? List<TranslatedString>.from(
                    (json["alertDescriptionTextTranslations"] as List<dynamic>)
                        .map(
                    (x) => TranslatedString.fromJson(x as Map<String, dynamic>),
                  ))
                : null,
        alertUrl: json['alertUrl'].toString(),
        alertUrlTranslations: json['alertUrlTranslations'] != null
            ? List<TranslatedString>.from(
                (json["alertUrlTranslations"] as List<dynamic>).map(
                (x) => TranslatedString.fromJson(x as Map<String, dynamic>),
              ))
            : null,
        alertEffect: getAlertEffectTypeByString(json['alertEffect'].toString()),
        alertCause: getAlertCauseTypeByString(json['alertCause'].toString()),
        alertSeverityLevel: getAlertSeverityLevelTypeByString(
            json['alertSeverityLevel'].toString()),
        effectiveStartDate:
            double.tryParse(json['effectiveStartDate'].toString()),
        effectiveEndDate: double.tryParse(json['effectiveEndDate'].toString()),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'alertId': alertId,
        'alertHash': alertHash,
        'feed': feed,
        'agency': agency?.toJson(),
        'route': route?.toJson(),
        'trip': trip?.toJson(),
        'stop': stop?.toJson(),
        'patterns': List<dynamic>.from(patterns.map((x) => x.toJson())),
        'alertHeaderText': alertHeaderText,
        'alertHeaderTextTranslations': List<dynamic>.from(
            alertHeaderTextTranslations.map((x) => x.toJson())),
        'alertDescriptionText': alertDescriptionText,
        'alertDescriptionTextTranslations': List<dynamic>.from(
            alertDescriptionTextTranslations.map((x) => x.toJson())),
        'alertUrl': alertUrl,
        'alertUrlTranslations':
            List<dynamic>.from(alertUrlTranslations.map((x) => x.toJson())),
        'alertEffect': alertEffect?.name,
        'alertCause': alertCause?.name,
        'alertSeverityLevel': alertSeverityLevel?.name,
        'effectiveStartDate': effectiveStartDate,
        'effectiveEndDate': effectiveEndDate,
      };
}
