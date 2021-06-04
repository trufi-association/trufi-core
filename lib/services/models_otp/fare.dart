import 'fare_component.dart';

class Fare {
  final String type;
  final String currency;
  final int cents;
  final List<FareComponent> components;

  const Fare({
    this.type,
    this.currency,
    this.cents,
    this.components,
  });

  factory Fare.fromJson(Map<String, dynamic> json) => Fare(
        type: json['type'] as String,
        currency: json['currency'] as String,
        cents: int.tryParse(json['cents'].toString()) ?? 0,
        components: json['components'] != null
            ? List<FareComponent>.from(
                (json["components"] as List<dynamic>).map(
                (x) => FareComponent.fromJson(x as Map<String, dynamic>),
              ))
            : null,
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'currency': currency,
        'cents': cents,
        'components': List<dynamic>.from(components.map((x) => x.toJson())),
      };
}
