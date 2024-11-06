part of 'plan.dart';

class RouteInfo extends Equatable {
  final String id;
  final String gtfsId;
  final String? shortName;
  final String? longName;
  final TransportMode? mode;
  final int? type;
  final String? desc;
  final String? url;
  final String? color;
  final String? textColor;

  const RouteInfo({
    required this.id,
    required this.gtfsId,
    this.shortName,
    this.longName,
    this.mode,
    this.type,
    this.desc,
    this.url,
    this.color,
    this.textColor,
  });

  factory RouteInfo.fromJson(Map<String, dynamic> json) => RouteInfo(
        id: json['id'],
        gtfsId: json['gtfsId'],
        shortName: json['shortName'],
        longName: json['longName'],
        mode: getTransportMode(mode: json['mode'].toString()),
        type: int.tryParse(json['type'].toString()) ?? 0,
        desc: json['desc'],
        url: json['url'],
        color: json['color'],
        textColor: json['textColor'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'gtfsId': gtfsId,
        'shortName': shortName,
        'longName': longName,
        'mode': mode?.name,
        'type': type,
        'desc': desc,
        'url': url,
        'color': color,
        'textColor': textColor,
      };

  Color get primaryColor {
    return color != null
        ? Color(int.tryParse('0xFF$color')!)
        : mode?.color ?? Colors.black;
  }

  Color get backgroundColor {
    return color != null
        ? Color(int.tryParse('0xFF$color')!)
        : mode?.backgroundColor ?? Colors.black;
  }

  @override
  List<Object?> get props => [
        id,
        gtfsId,
        shortName,
        longName,
        mode,
        type,
        desc,
        url,
        color,
        textColor,
      ];
}
