class TicketType {
  final String id;
  final String fareId;
  final double price;
  final String currency;
  final List<String> zones;

  const TicketType({
    this.id,
    this.fareId,
    this.price,
    this.currency,
    this.zones,
  });

  factory TicketType.fromJson(Map<String, dynamic> json) => TicketType(
        id: json['id'].toString(),
        fareId: json['fareId'].toString(),
        price: double.tryParse(json['price'].toString()) ?? 0,
        currency: json['currency'].toString(),
        zones: json['zones'] != null
            ? (json['zones'] as List<dynamic>).cast<String>()
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fareId': fareId,
        'price': price,
        'currency': currency,
        'zones': zones,
      };
}
