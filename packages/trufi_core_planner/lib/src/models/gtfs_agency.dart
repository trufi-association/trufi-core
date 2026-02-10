/// GTFS Agency entity.
/// Represents a transit agency from agency.txt
class GtfsAgency {
  final String id;
  final String name;
  final String url;
  final String timezone;
  final String? lang;
  final String? phone;
  final String? fareUrl;
  final String? email;

  const GtfsAgency({
    required this.id,
    required this.name,
    required this.url,
    required this.timezone,
    this.lang,
    this.phone,
    this.fareUrl,
    this.email,
  });

  factory GtfsAgency.fromCsv(Map<String, String> row) {
    return GtfsAgency(
      id: row['agency_id'] ?? '',
      name: row['agency_name'] ?? '',
      url: row['agency_url'] ?? '',
      timezone: row['agency_timezone'] ?? '',
      lang: row['agency_lang'],
      phone: row['agency_phone'],
      fareUrl: row['agency_fare_url'],
      email: row['agency_email'],
    );
  }
}
