class BikeRentalStationUris {
  final String? android;
  final String? ios;
  final String? web;

  const BikeRentalStationUris({
    this.android,
    this.ios,
    this.web,
  });

  factory BikeRentalStationUris.fromMap(Map<String, dynamic> map) {
    return BikeRentalStationUris(
      android: map['android'] as String?,
      ios: map['ios'] as String?,
      web: map['web'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'android': android,
        'ios': ios,
        'web': web,
      };
}
