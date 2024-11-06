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
            specificTransport: (json['longName'] ?? '') as String),
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

  Color get backgroundColor {
    return color != null
        ? Color(int.tryParse('0xFF$color')!)
        : mode?.backgroundColor ?? Colors.black;
  }

  @override
  List<Object?> get props => [
        shortName,
        longName,
        mode,
        color,
        textColor,
      ];
}

class Agency extends Equatable {
  static const _name = 'name';

  final String name;

  const Agency({
    this.name = 'Not name',
  });

  Map<String, dynamic> toJson() {
    return {
      _name: name,
    };
  }

  factory Agency.fromJson(Map<String, dynamic> map) {
    return Agency(
      name: map[_name],
    );
  }

  @override
  List<Object?> get props => [name];
}
