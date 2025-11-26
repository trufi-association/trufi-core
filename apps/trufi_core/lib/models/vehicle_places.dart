class VehiclePlacesEntity {
  final int? bicycleSpaces;
  final int? carSpaces;
  final int? wheelchairAccessibleCarSpaces;

  const VehiclePlacesEntity({
    this.bicycleSpaces,
    this.carSpaces,
    this.wheelchairAccessibleCarSpaces,
  });

  static const String _bicycleSpaces = 'bicycleSpaces';
  static const String _carSpaces = 'carSpaces';
  static const String _wheelchairAccessibleCarSpaces =
      'wheelchairAccessibleCarSpaces';

  factory VehiclePlacesEntity.fromMap(Map<String, dynamic> json) => VehiclePlacesEntity(
    bicycleSpaces: json[_bicycleSpaces],
    carSpaces: json[_carSpaces],
    wheelchairAccessibleCarSpaces: json[_wheelchairAccessibleCarSpaces],
  );

  Map<String, dynamic> toMap() => {
    _bicycleSpaces: bicycleSpaces,
    _carSpaces: carSpaces,
    _wheelchairAccessibleCarSpaces: wheelchairAccessibleCarSpaces,
  };
}
