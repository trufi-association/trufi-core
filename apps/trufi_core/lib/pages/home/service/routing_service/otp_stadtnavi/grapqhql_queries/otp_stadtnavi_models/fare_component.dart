import 'package:trufi_core/models/plan_entity.dart';
import 'route.dart';

class FareComponent {
  final String? fareId;
  final String? currency;
  final String? url;
  final int? cents;
  final List<RouteOtp>? routes;

  const FareComponent({
    this.fareId,
    this.currency,
    this.url,
    this.cents,
    this.routes,
  });

  factory FareComponent.fromJson(Map<String, dynamic> json) => FareComponent(
    fareId: json['fareId'] as String?,
    currency: json['currency'] as String?,
    url: json['url'] as String?,
    cents: (json['cents'] as num).toInt(),
    routes: json['routes'] != null
        ? List<RouteOtp>.from(
            (json["routes"] as List<dynamic>).map(
              (x) => RouteOtp.fromJson(x as Map<String, dynamic>),
            ),
          )
        : null,
  );

  Map<String, dynamic> toJson() => {
    'fareId': fareId,
    'currency': currency,
    'url': url,
    'cents': cents,
    'routes': List<dynamic>.from((routes ?? []).map((x) => x.toJson())),
  };

  AgencyEntity? get agency {
    return (routes?.isNotEmpty ?? false)
        ? routes![0].agency?.toAgencyEntity()
        : null;
  }
}
