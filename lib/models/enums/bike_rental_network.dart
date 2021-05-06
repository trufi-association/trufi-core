part of 'plan_enums.dart';

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
  String get name => values[this] ?? 'car-sharing';
}

const defaultBikeRentalNetworks = <BikeRentalNetwork>[
  BikeRentalNetwork.taxi,
  BikeRentalNetwork.carSharing,
  BikeRentalNetwork.regioRad,
];
