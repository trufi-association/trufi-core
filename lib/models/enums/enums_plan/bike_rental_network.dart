part of 'enums_plan.dart';

enum BikeRentalNetwork { taxi, carSharing, regioRad }

BikeRentalNetwork getBikeRentalNetwork(String key) {
  return BikeRentalNetworkExtension.values.keys.firstWhere(
    (keyE) => keyE.name == key,
    orElse: () => BikeRentalNetwork.regioRad,
  );
}

extension BikeRentalNetworkExtension on BikeRentalNetwork {
  static const values = <BikeRentalNetwork, String>{
    BikeRentalNetwork.taxi: 'taxi',
    BikeRentalNetwork.carSharing: 'car-sharing',
    BikeRentalNetwork.regioRad: 'regiorad',
  };

  static final images = <BikeRentalNetwork, SvgPicture>{
    BikeRentalNetwork.taxi: SvgPicture.string(taxi ?? ""),
    BikeRentalNetwork.carSharing: SvgPicture.string(carSharing ?? ""),
    BikeRentalNetwork.regioRad: SvgPicture.string(regioRad ?? ""),
  };

  String get name => values[this] ?? 'car-sharing';

  SvgPicture get image => images[this] ?? SvgPicture.string(carSharing ?? "");
}

const defaultBikeRentalNetworks = <BikeRentalNetwork>[
  BikeRentalNetwork.taxi,
  BikeRentalNetwork.carSharing,
  BikeRentalNetwork.regioRad,
];
