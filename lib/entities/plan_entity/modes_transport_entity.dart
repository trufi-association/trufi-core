part of 'plan_entity.dart';

class ModesTransportEntity {
  static const _walkPlan = 'walkPlan';
  static const _bikePlan = 'bikePlan';
  static const _bikeAndPublicPlan = 'bikeAndPublicPlan';
  static const _bikeParkPlan = 'bikeParkPlan';
  static const _carPlan = 'carPlan';
  static const _parkRidePlan = 'parkRidePlan';

  final PlanEntity walkPlan;
  final PlanEntity bikePlan;
  final PlanEntity bikeAndPublicPlan;
  final PlanEntity bikeParkPlan;
  final PlanEntity carPlan;
  final PlanEntity parkRidePlan;

  const ModesTransportEntity({
    this.walkPlan,
    this.bikePlan,
    this.bikeAndPublicPlan,
    this.bikeParkPlan,
    this.carPlan,
    this.parkRidePlan,
  });

  factory ModesTransportEntity.fromJson(Map<String, dynamic> json) =>
      ModesTransportEntity(
        walkPlan: json[_walkPlan] != null
            ? PlanEntity.fromJson(json[_walkPlan] as Map<String, dynamic>)
            : null,
        bikePlan: json[_bikePlan] != null
            ? PlanEntity.fromJson(json[_bikePlan] as Map<String, dynamic>)
            : null,
        bikeAndPublicPlan: json[_bikeAndPublicPlan] != null
            ? PlanEntity.fromJson(
                json[_bikeAndPublicPlan] as Map<String, dynamic>)
            : null,
        bikeParkPlan: json[_bikeParkPlan] != null
            ? PlanEntity.fromJson(json[_bikeParkPlan] as Map<String, dynamic>)
            : null,
        carPlan: json[_carPlan] != null
            ? PlanEntity.fromJson(json[_carPlan] as Map<String, dynamic>)
            : null,
        parkRidePlan: json[_parkRidePlan] != null
            ? PlanEntity.fromJson(json[_parkRidePlan] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        _walkPlan: walkPlan?.toJson(),
        _bikePlan: bikePlan?.toJson(),
        _bikeAndPublicPlan: bikeAndPublicPlan?.toJson(),
        _bikeParkPlan: bikeParkPlan?.toJson(),
        _carPlan: carPlan?.toJson(),
        _parkRidePlan: parkRidePlan?.toJson(),
      };

  bool get existBikeAndPublicPlan =>
      bikeAndPublicPlan?.itineraries?.isNotEmpty ?? false;

  bool get existBikeParkPlan => bikeParkPlan?.itineraries?.isNotEmpty ?? false;

  bool get existCarPlan => carPlan?.itineraries?.isNotEmpty ?? false;

  bool get existParkRidePlan => parkRidePlan?.itineraries?.isNotEmpty ?? false;

  bool get availableModesTransport =>
      existBikeAndPublicPlan ||
      existBikeParkPlan ||
      existCarPlan ||
      existParkRidePlan;
}
