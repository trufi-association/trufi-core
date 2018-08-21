class Location {
  final String description;
  final double latitude;
  final double longitude;

  Location({this.description, this.latitude, this.longitude});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      description: json['description'],
      latitude: json['lat'],
      longitude: json['lng'],
    );
  }

  String toString() {
    return '$latitude,$longitude';
  }
}
