import 'package:trufi_core/entities/plan_entity/agency_entity.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';

class RouteEntity {
  final String? id;
  final String? gtfsId;
  final AgencyEntity? agency;
  final String? shortName;
  final String? longName;
  final TransportMode? mode;
  final int? type;
  final String? desc;
  final String? url;
  final String? color;
  final String? textColor;

  const RouteEntity({
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
  });

  factory RouteEntity.fromJson(Map<String, dynamic> json) => RouteEntity(
        id: json['id'] as String?,
        gtfsId: json['gtfsId'] as String?,
        agency: json['agency'] != null
            ? AgencyEntity.fromMap(json['agency'] as Map<String, dynamic>)
            : null,
        shortName: json['shortName'] as String?,
        longName: json['longName'] as String?,
        mode: getTransportMode(mode: json['mode'].toString()),
        type: int.tryParse(json['type'].toString()) ?? 0,
        desc: json['desc'] as String?,
        url: json['url'] as String?,
        color: json['color'] as String?,
        textColor: json['textColor'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'gtfsId': gtfsId,
        'agency': agency?.toMap(),
        'shortName': shortName,
        'longName': longName,
        'mode': mode?.name,
        'type': type,
        'desc': desc,
        'url': url,
        'color': color,
        'textColor': textColor,
      };

  String get headsignFromRouteLongName {
    return longName ?? (longName ?? "");
  }

  bool get useIcon {
    return shortName == null || shortName!.length > 6;
  }
}
