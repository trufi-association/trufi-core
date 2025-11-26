import 'package:trufi_core/models/enums/transport_mode.dart';
import 'package:trufi_core/models/plan_entity.dart';

import 'agency.dart';
import 'alert.dart';
import 'enums/bikes_allowed.dart';
import 'enums/mode.dart';
import 'pattern.dart';
import 'stop.dart';
import 'trip.dart';

class RouteOtp {
  final String? id;
  final String? gtfsId;
  final Agency? agency;
  final String? shortName;
  final String? longName;
  final Mode? mode;
  final int? type;
  final String? desc;
  final String? url;
  final String? color;
  final String? textColor;
  final BikesAllowed? bikesAllowed;
  final List<PatternOtp>? patterns;
  final List<Stop>? stops;
  final List<Trip>? trips;
  final List<Alert>? alerts;

  const RouteOtp({
    this.id,
    this.gtfsId,
    this.agency,
    this.shortName,
    this.longName,
    this.mode,
    this.type,
    this.desc,
    this.url,
    this.color,
    this.textColor,
    this.bikesAllowed,
    this.patterns,
    this.stops,
    this.trips,
    this.alerts,
  });

  factory RouteOtp.fromJson(Map<String, dynamic> json) => RouteOtp(
    id: json['id'] as String?,
    gtfsId: json['gtfsId'] as String?,
    agency: json['agency'] != null
        ? Agency.fromJson(json['agency'] as Map<String, dynamic>)
        : null,
    shortName: json['shortName'] as String?,
    longName: json['longName'] as String?,
    mode: getModeByString(json['mode'].toString()),
    type: int.tryParse(json['type'].toString()) ?? 0,
    desc: json['desc'] as String?,
    url: json['url'] as String?,
    color: json['color'] as String?,
    textColor: json['textColor'] as String?,
    bikesAllowed: getBikesAllowedByString(json['bikesAllowed'].toString()),
    patterns: json['patterns'] != null
        ? List<PatternOtp>.from(
            (json["patterns"] as List<dynamic>).map(
              (x) => PatternOtp.fromJson(x as Map<String, dynamic>),
            ),
          )
        : null,
    stops: json['stops'] != null
        ? List<Stop>.from(
            (json["stops"] as List<dynamic>).map(
              (x) => PatternOtp.fromJson(x as Map<String, dynamic>),
            ),
          )
        : null,
    trips: json['trips'] != null
        ? List<Trip>.from(
            (json["trips"] as List<dynamic>).map(
              (x) => PatternOtp.fromJson(x as Map<String, dynamic>),
            ),
          )
        : null,
    alerts: json['alerts'] != null
        ? List<Alert>.from(
            (json["alerts"] as List<dynamic>).map(
              (x) => Alert.fromJson(x as Map<String, dynamic>),
            ),
          )
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'gtfsId': gtfsId,
    'agency': agency?.toJson(),
    'shortName': shortName,
    'longName': longName,
    'mode': mode?.name,
    'type': type,
    'desc': desc,
    'url': url,
    'color': color,
    'textColor': textColor,
    'bikesAllowed': bikesAllowed?.name,
    'patterns': patterns != null
        ? List<dynamic>.from(patterns!.map((x) => x.toJson()))
        : null,
    'stops': stops != null
        ? List<dynamic>.from(stops!.map((x) => x.toJson()))
        : null,
    'trips': trips != null
        ? List<dynamic>.from(trips!.map((x) => x.toJson()))
        : null,
    'alerts': alerts != null
        ? List<dynamic>.from(alerts!.map((x) => x.toJson()))
        : null,
  };

  String get headsignFromRouteLongName {
    return longName ?? (longName ?? "");
  }

  bool get useIcon {
    return shortName == null || shortName!.length > 6;
  }

  RouteEntity toRouteEntity() {
    return RouteEntity(
      id: id,
      gtfsId: gtfsId,
      agency: agency?.toAgencyEntity(),
      shortName: shortName,
      longName: longName,
      mode: getTransportMode(mode: mode?.name ?? ''),
      type: type,
      desc: desc,
      url: url,
      color: color,
      textColor: textColor,
      alerts: alerts?.map((e) => e.toAlertEntity()).toList(),
    );
  }
}
