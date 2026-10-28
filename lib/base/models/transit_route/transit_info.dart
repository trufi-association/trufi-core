import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:trufi_core/base/models/enums/transport_mode.dart';

class TransitInfo extends Equatable {
  final String? shortName;
  final String? longName;
  final TransportMode? mode;
  final Agency? agency;
  final String? color;
  final String? textColor;

  const TransitInfo({
    this.shortName,
    this.longName,
    this.mode,
    this.agency,
    this.color,
    this.textColor,
  });

  factory TransitInfo.fromJson(Map<String, dynamic> json) => TransitInfo(
    shortName: json['shortName'] as String?,
    longName: json['longName'] as String?,
    mode: getTransportMode(
      mode: json['mode'].toString(),
      specificTransport: (json['longName'] ?? '') as String,
    ),
    agency: json["agency"] != null
        ? Agency.fromJson(json["agency"] as Map<String, dynamic>)
        : null,
    color: json['color'] as String?,
    textColor: json['textColor'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'shortName': shortName,
    'longName': longName,
    'mode': mode?.name,
    'agency': agency,
    'color': color,
    'textColor': textColor,
  };

  String get longNameLast {
    return longName?.split("→ ").last ?? '';
  }

  String get longNameStart {
    return longName?.split(": ").last.split("→ ").first ?? '';
  }

  String get longNameSub {
    return longName?.split(": ").last ?? '';
  }

  String get longNameData {
    return longName ?? '';
  }

  Color get primaryColor {
    return mode?.color ?? Colors.white;
  }

  /// The colour the feed gives the route, or the mode's colour when the
  /// feed gives none or gives one that would vanish on the white tiles
  /// (trufi-arequipa#77: Albotran and Chiguata come with `FFFFFF`, which
  /// painted the route list rows white on white and the group chevron,
  /// always white, invisible).
  Color get backgroundColor {
    final fallback = mode?.backgroundColor ?? Colors.black;
    final value = color == null ? null : int.tryParse('0xFF$color');
    if (value == null) return fallback;
    final parsed = Color(value);
    return parsed.computeLuminance() > tooLightLuminance ? fallback : parsed;
  }

  /// Relative luminance above which a route colour is treated as "no
  /// colour": white is 1.0, the lightest brand colours of the Arequipa feed
  /// are below 0.75.
  static const double tooLightLuminance = 0.85;

  @override
  List<Object?> get props => [shortName, longName, mode, color, textColor];
}

class Agency extends Equatable {
  static const _name = 'name';

  final String name;

  const Agency({this.name = 'Not name'});

  Map<String, dynamic> toJson() {
    return {_name: name};
  }

  factory Agency.fromJson(Map<String, dynamic> map) {
    return Agency(name: map[_name]);
  }

  @override
  List<Object?> get props => [name];
}
