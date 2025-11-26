import 'dart:convert';

import 'fare_component.dart';

class Fare {
  final String? type;
  final String? currency;
  final int? cents;
  final List<FareComponent>? components;

  const Fare({this.type, this.currency, this.cents, this.components});

  static const String _type = 'type';
  static const String _currency = 'currency';
  static const String _cents = 'cents';
  static const String _components = 'components';

  factory Fare.fromSource(String source) =>
      Fare.fromJson(json.decode(source) as Map<String, dynamic>);

  factory Fare.fromJson(Map<String, dynamic> jsonData) => Fare(
    type: jsonData[_type],
    currency: jsonData[_currency],
    cents: jsonData[_cents],
    components:
        jsonData[_components] != null
            ? List<FareComponent>.from(
              (jsonData[_components] as List<dynamic>).map(
                (x) => FareComponent.fromJson(x as Map<String, dynamic>),
              ),
            )
            : null,
  );

  Map<String, dynamic> toJson() => {
    _type: type,
    _currency: currency,
    _cents: cents,
    _components:
        components != null
            ? List<dynamic>.from((components ?? []).map((x) => x.toJson()))
            : null,
  };
}
