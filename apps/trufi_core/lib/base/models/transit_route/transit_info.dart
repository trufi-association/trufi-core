import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:trufi_core/base/models/enums/transport_mode.dart';

class TransitInfo extends Equatable {
  final String? shortName;
  final String? longName;
  final TransportMode? mode;
  final String? color;
  final String? textColor;

  const TransitInfo({
    this.shortName,
    this.longName,
    this.mode,
    this.color,
    this.textColor,
  });

  factory TransitInfo.fromJson(Map<String, dynamic> json) => TransitInfo(
        shortName: json['shortName'] as String?,
        longName: json['longName'] as String?,
        mode: getTransportMode(
            mode: json['mode'].toString(),
            specificTransport: (json['longName'] ?? '') as String),
        color: json['color'] as String?,
        textColor: json['textColor'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'shortName': shortName,
        'longName': longName,
        'mode': mode?.name,
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
    return  mode?.color ?? Colors.white;
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
