import 'package:trufi_core/models/plan_entity.dart';

class FareComponent {
  final String? fareId;
  final String? currency;
  final String? url;
  final int? cents;
  final List<RouteEntity>? routes;

  const FareComponent({
    this.fareId,
    this.currency,
    this.url,
    this.cents,
    this.routes,
  });

  static const String _fareId = 'fareId';
  static const String _currency = 'currency';
  static const String _url = 'url';
  static const String _cents = 'cents';
  static const String _routes = 'routes';

  factory FareComponent.fromJson(Map<String, dynamic> json) => FareComponent(
    fareId: json[_fareId],
    currency: json[_currency],
    url: json[_url],
    cents: json[_cents],
    routes:
        json[_routes] != null
            ? List<RouteEntity>.from(
              (json[_routes] as List<dynamic>).map(
                (x) => RouteEntity.fromJson(x as Map<String, dynamic>),
              ),
            )
            : null,
  );

  Map<String, dynamic> toJson() => {
    _fareId: fareId,
    _currency: currency,
    _url: url,
    _cents: cents,
    _routes: List<dynamic>.from((routes ?? []).map((x) => x.toJson())),
  };
}
