part of 'enums_plan.dart';

enum BikeRentalNetwork { taxi, carSharing, regioRad }

BikeRentalNetwork getBikeRentalNetwork(String key) {
  return BikeRentalNetworkExtension.values.keys.firstWhere(
    (keyE) => keyE.name == key,
    orElse: () => null,
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
  static final colors = <BikeRentalNetwork, Color>{
    BikeRentalNetwork.taxi: const Color(0xfff1b736),
    BikeRentalNetwork.carSharing: const Color(0xffff834a),
    BikeRentalNetwork.regioRad: const Color(0xff009fe4),
  };

  String get name => values[this] ?? 'car-sharing';

  SvgPicture get image => images[this] ?? SvgPicture.string(carSharing ?? "");

  Color get color => colors[this] ?? Colors.black;
}

const defaultBikeRentalNetworks = <BikeRentalNetwork>[
  BikeRentalNetwork.taxi,
  BikeRentalNetwork.carSharing,
  BikeRentalNetwork.regioRad,
];
