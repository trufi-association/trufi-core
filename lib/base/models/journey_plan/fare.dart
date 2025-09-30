class Fare {
  final String? currency;
  final int? cents;

  const Fare({this.currency, this.cents});

  static const String _currency = 'currency';
  static const String _cents = 'cents';

  factory Fare.fromJson(Map<String, dynamic> jsonData) {
    final regularFare = jsonData['fare']['regular'];
    return Fare(
      currency: regularFare[_currency][_currency],
      cents: regularFare[_cents],
    );
  }

  Map<String, dynamic> toJson() => {
        _currency: {_currency: currency},
        _cents: cents,
      };

  String get formattedFare {
    if (cents == null || currency == null) return '';
    final value = cents! / 100;
    return '${value.toStringAsFixed(2)} $currency';
  }
}
