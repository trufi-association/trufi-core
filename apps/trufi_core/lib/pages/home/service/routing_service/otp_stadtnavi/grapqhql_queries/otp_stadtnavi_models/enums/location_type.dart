enum LocationType { stop, station, entrance }

LocationType getLocationTypeByString(String locationType) {
  return LocationTypeExtension.names.keys.firstWhere(
    (key) => key.name == locationType,
    orElse: () => LocationType.stop,
  );
}

extension LocationTypeExtension on LocationType {
  static const names = <LocationType, String>{
    LocationType.stop: 'STOP',
    LocationType.station: 'STATION',
    LocationType.entrance: 'ENTRANCE'
  };
  String get name => names[this] ?? 'STOP';
}
