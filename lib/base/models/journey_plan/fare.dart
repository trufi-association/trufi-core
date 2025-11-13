class Fare {
  final String? currency;
  final int? cents;
  final List<FarePrice>? detailsFares;

  const Fare({this.currency, this.cents, this.detailsFares});

  static const String _currency = 'currency';
  static const String _cents = 'cents';

  factory Fare.fromJson(Map<String, dynamic> jsonData) {
    final regularFare = jsonData['fare']?['regular'] ?? {};
    final detailsFares = jsonData['details']?['regular'] ?? [];
    return Fare(
      currency: regularFare[_currency]?[_currency],
      cents: regularFare[_cents],
      detailsFares: detailsFares?.map<FarePrice>((dynamic json) {
            return FarePrice.fromJson(json as Map<String, dynamic>);
          }).toList() as List<FarePrice>? ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fare': {
        'regular': {
          _currency: currency != null ? {_currency: currency} : null,
          _cents: cents,
        },
      },
      'details': {
        'regular': detailsFares?.map((f) => f.toJson()).toList(),
      },
    };
  }
}

class FarePrice {
  final String? currency;
  final int? cents;

  const FarePrice({this.currency, this.cents});

  static const String _currency = 'currency';
  static const String _cents = 'cents';

  factory FarePrice.fromJson(Map<String, dynamic> jsonData) {
    final priceJson = jsonData['price'] ?? {};
    return FarePrice(
      currency: priceJson[_currency]?[_currency],
      cents: priceJson[_cents],
    );
  }

  Map<String, dynamic> toJson() => {
        'price': {
          _currency: {_currency: currency},
          _cents: cents,
        },
      };
}
