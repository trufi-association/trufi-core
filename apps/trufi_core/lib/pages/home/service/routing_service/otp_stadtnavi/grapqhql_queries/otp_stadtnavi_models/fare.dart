import 'dart:convert';

import 'fare_component.dart';

class Fare {
  final String? type;
  final String? currency;
  final int? cents;
  final List<FareComponent>? components;

  const Fare({
    this.type,
    this.currency,
    this.cents,
    this.components,
  });

  factory Fare.fromMap(Map<String, dynamic> json) => Fare(
        type: json['type'] as String?,
        currency: json['currency'] as String?,
        cents: (json['cents'] as num? ?? 0).toInt(),
        components: json['components'] != null
            ? List<FareComponent>.from(
                (json['components'] as List<dynamic>).map(
                (x) => FareComponent.fromJson(x as Map<String, dynamic>),
              ))
            : null,
      );

  Map<String, dynamic> toMap() => {
        'type': type,
        'currency': currency,
        'cents': cents,
        'components': components != null
            ? List<dynamic>.from((components ?? []).map((x) => x.toJson()))
            : null,
      };

  factory Fare.fromJson(String source) =>
      Fare.fromMap(json.decode(source) as Map<String, dynamic>);
}
