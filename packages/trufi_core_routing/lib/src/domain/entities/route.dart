import 'agency.dart';
import 'transport_mode.dart';

/// A transit route (bus line, train line, etc.).
class Route {
  const Route({
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

  final String? id;
  final String? gtfsId;
  final Agency? agency;
  final String? shortName;
  final String? longName;
  final TransportMode? mode;
  final int? type;
  final String? desc;
  final String? url;
  final String? color;
  final String? textColor;

  /// Creates a [Route] from JSON.
  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      id: json['id'] as String?,
      gtfsId: json['gtfsId'] as String?,
      agency: json['agency'] != null
          ? Agency.fromJson(json['agency'] as Map<String, dynamic>)
          : null,
      shortName: json['shortName'] as String?,
      longName: json['longName'] as String?,
      mode: json['mode'] != null
          ? TransportModeExtension.fromString(json['mode'] as String)
          : null,
      type: json['type'] as int?,
      desc: json['desc'] as String?,
      url: json['url'] as String?,
      color: json['color'] as String?,
      textColor: json['textColor'] as String?,
    );
  }

  /// Converts this route to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gtfsId': gtfsId,
      'agency': agency?.toJson(),
      'shortName': shortName,
      'longName': longName,
      'mode': mode?.otpName,
      'type': type,
      'desc': desc,
      'url': url,
      'color': color,
      'textColor': textColor,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is Route && other.id == id && other.gtfsId == gtfsId;

  @override
  int get hashCode => Object.hash(id, gtfsId);
}
