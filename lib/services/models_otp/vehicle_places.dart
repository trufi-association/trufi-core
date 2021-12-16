class VehiclePlaces {
  final int? bicycleSpaces;
  final int? carSpaces;
  final int? wheelchairAccessibleCarSpaces;

  const VehiclePlaces({
    this.bicycleSpaces,
    this.carSpaces,
    this.wheelchairAccessibleCarSpaces,
  });

  factory VehiclePlaces.fromMap(Map<String, dynamic> json) => VehiclePlaces(
        bicycleSpaces: int.tryParse(json['bicycleSpaces'].toString()),
        carSpaces: int.tryParse(json['carSpaces'].toString()),
        wheelchairAccessibleCarSpaces:
            int.tryParse(json['wheelchairAccessibleCarSpaces'].toString()),
      );

  Map<String, dynamic> toMap() => {
        'bicycleSpaces': bicycleSpaces,
        'carSpaces': carSpaces,
        'wheelchairAccessibleCarSpaces': wheelchairAccessibleCarSpaces,
      };
}
