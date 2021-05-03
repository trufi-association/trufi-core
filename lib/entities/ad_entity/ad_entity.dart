import '../plan_entity/plan_entity.dart';

class AdEntity {
  AdEntity({
    this.text,
    this.url,
    this.location,
  });

  static const _ad = "ad";
  static const _text = "text";
  static const _url = "url";
  static const _location = "location";

  final String text;
  final String url;
  final PlanLocation location;

  factory AdEntity.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    final Map<String, dynamic> adJson = json[_ad] as Map<String, dynamic>;
    return AdEntity(
      text: adJson[_text] as String,
      url: adJson[_url] as String,
      location: (adJson[_location] as Map<String, dynamic>).isEmpty
          ? null
          : PlanLocation.fromJson(adJson[_location] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _ad: {
        _text: text.toString(),
        _url: url.toString(),
        _location: location.toJson(),
      }
    };
  }
}
