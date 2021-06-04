class BikePark {
  final String id;
  final String bikeParkId;
  final String name;
  final int spacesAvailable;
  final bool realtime;
  final double lon;
  final double lat;

  const BikePark({
    this.id,
    this.bikeParkId,
    this.name,
    this.spacesAvailable,
    this.realtime,
    this.lon,
    this.lat,
  });

  factory BikePark.fromJson(Map<String, dynamic> json) => BikePark(
        id: json['id'].toString(),
        bikeParkId: json['bikeParkId'].toString(),
        name: json['name'].toString(),
        spacesAvailable: int.tryParse(json['spacesAvailable'].toString()) ?? 0,
        realtime: json['realtime'] as bool,
        lon: double.tryParse(json['lon'].toString()) ?? 0,
        lat: double.tryParse(json['lat'].toString()) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'bikeParkId': bikeParkId,
        'name': name,
        'spacesAvailable': spacesAvailable,
        'realtime': realtime,
        'lon': lon,
        'lat': lat,
      };
}
