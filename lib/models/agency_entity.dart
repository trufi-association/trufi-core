part of 'plan_entity.dart';

class AgencyEntity {
  final int id;
  final String gtfsId;
  final String name;
  final String url;
  final String timezone;
  final String lang;
  final String phone;
  final String fareUrl;

  const AgencyEntity({
    required this.id,
    required this.gtfsId,
    required this.name,
    required this.url,
    required this.timezone,
    required this.lang,
    required this.phone,
    required this.fareUrl,
  });

  static const String _id = 'id';
  static const String _gtfsId = 'gtfsId';
  static const String _name = 'name';
  static const String _url = 'url';
  static const String _timezone = 'timezone';
  static const String _lang = 'lang';
  static const String _phone = 'phone';
  static const String _fareUrl = 'fareUrl';

  factory AgencyEntity.fromJson(Map<String, dynamic> map) => AgencyEntity(
    id: map[_id],
    gtfsId: map[_gtfsId],
    name: map[_name],
    url: map[_url],
    timezone: map[_timezone],
    lang: map[_lang],
    phone: map[_phone],
    fareUrl: map[_fareUrl],
  );

  Map<String, dynamic> toJson() => {
    _id: id,
    _gtfsId: gtfsId,
    _name: name,
    _url: url,
    _timezone: timezone,
    _lang: lang,
    _phone: phone,
    _fareUrl: fareUrl,
  };
}
