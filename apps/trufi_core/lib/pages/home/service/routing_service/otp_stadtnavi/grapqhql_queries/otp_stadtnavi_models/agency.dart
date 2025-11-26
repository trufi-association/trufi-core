import 'package:trufi_core/models/plan_entity.dart';

import 'alert.dart';
import 'route.dart';

class Agency {
  final int? id;
  final String? gtfsId;
  final String? name;
  final String? url;
  final String? timezone;
  final String? lang;
  final String? phone;
  final String? fareUrl;
  final List<RouteOtp>? routes;
  final List<Alert>? alerts;

  const Agency({
    required this.id,
    required this.gtfsId,
    required this.name,
    required this.url,
    required this.timezone,
    required this.lang,
    required this.phone,
    required this.fareUrl,
    required this.routes,
    required this.alerts,
  });

  factory Agency.fromJson(Map<String, dynamic> json) => Agency(
    id: int.tryParse(json['id'].toString()) ?? 0,
    gtfsId: json['gtfsId'].toString(),
    name: json['name'].toString(),
    url: json['url'].toString(),
    timezone: json['timezone'].toString(),
    lang: json['lang'].toString(),
    phone: json['phone'].toString(),
    fareUrl: json['fareUrl'].toString(),
    routes: json['routes'] != null
        ? List<RouteOtp>.from(
            (json["routes"] as List<dynamic>).map(
              (x) => RouteOtp.fromJson(x as Map<String, dynamic>),
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
    'name': name,
    'url': url,
    'timezone': timezone,
    'lang': lang,
    'phone': phone,
    'fareUrl': fareUrl,
    'routes': List<dynamic>.from((routes ?? []).map((x) => x.toJson())),
    'alerts': List<dynamic>.from((alerts ?? []).map((x) => x.toJson())),
  };

  AgencyEntity toAgencyEntity() {
    return AgencyEntity(
      id: id ?? 0,
      gtfsId: gtfsId ?? '',
      name: name ?? '',
      url: url ?? '',
      timezone: timezone ?? '',
      lang: lang ?? '',
      phone: phone ?? '',
      fareUrl: fareUrl ?? '',
    );
  }
}
