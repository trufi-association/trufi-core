import 'vehicle_parking.dart';

class VehicleParkingWithEntranceEntity {
  final VehicleParkingEntity? vehicleParking;
  final bool? closesSoon;
  final bool? realtime;

  const VehicleParkingWithEntranceEntity({
    this.vehicleParking,
    this.closesSoon,
    this.realtime,
  });

  static const String _vehicleParking = 'vehicleParking';
  static const String _closesSoon = 'closesSoon';
  static const String _realtime = 'realtime';

  factory VehicleParkingWithEntranceEntity.fromMap(Map<String, dynamic> json) =>
      VehicleParkingWithEntranceEntity(
        vehicleParking:
            json[_vehicleParking] != null
                ? VehicleParkingEntity.fromMap(
                  json[_vehicleParking] as Map<String, dynamic>,
                )
                : null,
        closesSoon: json[_closesSoon],
        realtime: json[_realtime],
      );

  Map<String, dynamic> toMap() => {
    _vehicleParking: vehicleParking?.toMap(),
    _closesSoon: closesSoon,
    _realtime: realtime,
  };
}
