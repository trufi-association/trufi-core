import 'package:trufi_core/entities/plan_entity/stop_entity.dart';

class PlaceEntity {
  static const _arrivalTime = "arrivalTime";
  static const _stop = "stopEntity";

  final DateTime arrivalTime;
  final StopEntity stopEntity;

  const PlaceEntity({
    this.arrivalTime,
    this.stopEntity,
  });

  factory PlaceEntity.fromJson(Map<String, dynamic> json) => PlaceEntity(
        arrivalTime: json[_arrivalTime] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                int.tryParse(json[_arrivalTime].toString()) ?? 0)
            : null,
        stopEntity: json[_stop] != null
            ? StopEntity.fromJson(json[_stop] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'arrivalTime': arrivalTime?.millisecondsSinceEpoch,
        'stopEntity': stopEntity?.toJson(),
      };
}
