import 'package:meta/meta.dart';

class AgencyEntity {
  final int? id;
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

  factory AgencyEntity.fromMap(Map<String, dynamic> map) => AgencyEntity(
        id: int.tryParse(map['id'].toString()),
        gtfsId: map['gtfsId'].toString(),
        name: map['name'].toString(),
        url: map['url'].toString(),
        timezone: map['timezone'].toString(),
        lang: map['lang'].toString(),
        phone: map['phone'].toString(),
        fareUrl: map['fareUrl'].toString(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'gtfsId': gtfsId,
        'name': name,
        'url': url,
        'timezone': timezone,
        'lang': lang,
        'phone': phone,
        'fareUrl': fareUrl,
      };
}
