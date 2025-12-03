/// A transit agency operating routes.
class Agency {
  const Agency({
    this.id,
    this.gtfsId,
    this.name,
    this.url,
    this.timezone,
    this.lang,
    this.phone,
    this.fareUrl,
  });

  final int? id;
  final String? gtfsId;
  final String? name;
  final String? url;
  final String? timezone;
  final String? lang;
  final String? phone;
  final String? fareUrl;

  /// Creates an [Agency] from JSON.
  factory Agency.fromJson(Map<String, dynamic> json) {
    return Agency(
      id: json['id'] as int?,
      gtfsId: json['gtfsId'] as String?,
      name: json['name'] as String?,
      url: json['url'] as String?,
      timezone: json['timezone'] as String?,
      lang: json['lang'] as String?,
      phone: json['phone'] as String?,
      fareUrl: json['fareUrl'] as String?,
    );
  }

  /// Converts this agency to JSON.
  Map<String, dynamic> toJson() {
    return {
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

  @override
  bool operator ==(Object other) =>
      other is Agency && other.id == id && other.gtfsId == gtfsId;

  @override
  int get hashCode => Object.hash(id, gtfsId);
}
