part of 'plan_entity.dart';

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
  final List<AlertEntity>? alerts;

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
    this.alerts,
  });

  static const String _id = 'id';
  static const String _gtfsId = 'gtfsId';
  static const String _agency = 'agency';
  static const String _shortName = 'shortName';
  static const String _longName = 'longName';
  static const String _mode = 'mode';
  static const String _type = 'type';
  static const String _desc = 'desc';
  static const String _url = 'url';
  static const String _color = 'color';
  static const String _textColor = 'textColor';
  static const String _alerts = 'alerts';

  factory RouteEntity.fromJson(Map<String, dynamic> json) => RouteEntity(
    id: json[_id],
    gtfsId: json[_gtfsId],
    agency:
        json[_agency] != null
            ? AgencyEntity.fromJson(json[_agency] as Map<String, dynamic>)
            : null,
    shortName: json[_shortName],
    longName: json[_longName],
    mode: getTransportMode(mode: json[_mode]),
    type: json[_type],
    desc: json[_desc],
    url: json[_url],
    color: json[_color],
    textColor: json[_textColor],
    alerts:
        json[_alerts] != null
            ? List<AlertEntity>.from(
              (json[_alerts] as List<dynamic>).map(
                (x) => AlertEntity.fromJson(x as Map<String, dynamic>),
              ),
            )
            : null,
  );

  Map<String, dynamic> toJson() => {
    _id: id,
    _gtfsId: gtfsId,
    _agency: agency?.toJson(),
    _shortName: shortName,
    _longName: longName,
    _mode: mode?.name,
    _type: type,
    _desc: desc,
    _url: url,
    _color: color,
    _textColor: textColor,
    _alerts:
        alerts != null
            ? List<dynamic>.from(alerts!.map((x) => x.toJson()))
            : null,
  };
}
