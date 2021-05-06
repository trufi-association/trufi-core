part of 'setting_panel_cubit.dart';

enum WalkingSpeed { slow, calm, average, prompt, fast }
enum BikingSpeed { slow, calm, average, prompt, fast }
enum WalkBoardCost { defaultCost, walkBoardCostHigh }
enum BikeRentalNetwork { taxi, carSharing, regioRad }
enum OptimizeType { quick, safe, flat, greenWays, triangle, transfers }

WalkingSpeed getWalkingSpeed(String key) {
  return WalkingSpeedExtension.names.keys.firstWhere(
    (keyE) => keyE.name == key,
    orElse: () => WalkingSpeed.average,
  );
}

BikingSpeed getBikingSpeed(String key) {
  return BikingSpeedExtension.names.keys.firstWhere(
    (keyE) => keyE.name == key,
    orElse: () => BikingSpeed.average,
  );
}

BikeRentalNetwork getBikeRentalNetwork(String key) {
  return BikeRentalNetworkExtension.values.keys.firstWhere(
    (keyE) => keyE.name == key,
    orElse: () => BikeRentalNetwork.regioRad,
  );
}

extension WalkingSpeedExtension on WalkingSpeed {
  static const values = <WalkingSpeed, double>{
    WalkingSpeed.slow: 0.69,
    WalkingSpeed.calm: 0.97,
    WalkingSpeed.average: 1.2,
    WalkingSpeed.prompt: 1.67,
    WalkingSpeed.fast: 2.22,
  };
  static const names = <WalkingSpeed, String>{
    WalkingSpeed.slow: "slow",
    WalkingSpeed.calm: "calm",
    WalkingSpeed.average: "average",
    WalkingSpeed.prompt: "prompt",
    WalkingSpeed.fast: "fast",
  };
  double get value => values[this] ?? 1.2;
  String get name => names[this] ?? "slow";
}

extension BikingSpeedExtension on BikingSpeed {
  static const values = <BikingSpeed, double>{
    BikingSpeed.slow: 2.77,
    BikingSpeed.calm: 4.15,
    BikingSpeed.average: 5.55,
    BikingSpeed.prompt: 6.94,
    BikingSpeed.fast: 8.33,
  };
  static const names = <BikingSpeed, String>{
    BikingSpeed.slow: '10 Km/h',
    BikingSpeed.calm: '15 Km/h',
    BikingSpeed.average: '20 Km/h',
    BikingSpeed.prompt: '25 Km/h',
    BikingSpeed.fast: '30 Km/h',
  };
  double get value => values[this] ?? 5.55;
  String get name => names[this] ?? "10 Km/h";
}

extension WalkBoardCostExtension on WalkBoardCost {
  static const values = <WalkBoardCost, int>{
    WalkBoardCost.defaultCost: 600,
    WalkBoardCost.walkBoardCostHigh: 1200,
  };
  int get value => values[this] ?? 600;
}

extension BikeRentalNetworkExtension on BikeRentalNetwork {
  static const values = <BikeRentalNetwork, String>{
    BikeRentalNetwork.taxi: 'taxi',
    BikeRentalNetwork.carSharing: 'car-sharing',
    BikeRentalNetwork.regioRad: 'regiorad',
  };
  String get name => values[this] ?? 'car-sharing';
}

extension OptimizeTypeExtension on OptimizeType {
  static const values = <OptimizeType, String>{
    OptimizeType.quick: 'QUICK',
    OptimizeType.safe: 'SAFE',
    OptimizeType.flat: 'FLAT',
    OptimizeType.greenWays: 'GREENWAYS',
    OptimizeType.triangle: 'TRIANGLE',
    OptimizeType.transfers: 'TRANSFERS',
  };
  String get name => values[this] ?? 'QUICK';
}








const defaultTransportModes = <TransportMode>[
  TransportMode.bus,
  TransportMode.rail,
  TransportMode.subway,
  TransportMode.walk,
];

const defaultBikeRentalNetworks = <BikeRentalNetwork>[
  BikeRentalNetwork.taxi,
  BikeRentalNetwork.carSharing,
  BikeRentalNetwork.regioRad,
];

@immutable
class SettingPanelState extends Equatable {
  static const String _typeWalkingSpeed = "typeWalkingSpeed";
  static const String _avoidWalking = "avoidWalking";
  static const String _transportModes = "transportModes";
  static const String _bikeRentalNetworks = "bikeRentalNetworks";
  static const String _avoidTransfers = "avoidTransfers";
  static const String _includeBikeSuggestions = "includeBikeSuggestions";
  static const String _typeBikingSpeed = "typeBikingSpeed";
  static const String _includeParkAndRideSuggestions = "includeParkAndRideSuggestions";
  static const String _includeCarSuggestions = "includeCarSuggestions";
  static const String _wheelchair = "wheelchair";

  const SettingPanelState({
    this.typeWalkingSpeed = WalkingSpeed.fast,
    this.avoidWalking = false,
    this.transportModes = defaultTransportModes,
    this.bikeRentalNetworks = defaultBikeRentalNetworks,
    this.avoidTransfers = false,
    this.includeBikeSuggestions = true,
    this.typeBikingSpeed = BikingSpeed.fast,
    this.includeParkAndRideSuggestions = true,
    this.includeCarSuggestions = true,
    this.wheelchair = true,
  });

  final WalkingSpeed typeWalkingSpeed; // walkSpeed
  final bool avoidWalking; //is true send "walkReluctance"=5 otherwise=2
  final List<TransportMode> transportModes; //transportMode
  final List<BikeRentalNetwork> bikeRentalNetworks;
  final bool avoidTransfers; // walkBoardCost false:default, true: walkBoardCostHigh
  final bool includeBikeSuggestions;
  // if select various part params(false: optimization:QUICK - true: optimization : TRIANGLE)
  final BikingSpeed typeBikingSpeed; // BikingSpeed param
  final bool includeParkAndRideSuggestions; // shouldMakeParkRideQuery is make by data
  final bool includeCarSuggestions; // shouldMakeCarQuery is make by data
  final bool wheelchair; // its relatione with param accessibilityOption

  SettingPanelState copyWith({
    WalkingSpeed typeWalkingSpeed,
    List<TransportMode> transportModes,
    List<BikeRentalNetwork> bikeRentalNetworks,
    bool avoidTransfers,
    bool avoidWalking,
    bool includeBikeSuggestions,
    BikingSpeed typeBikingSpeed,
    bool includeParkAndRideSuggestions,
    bool includeCarSuggestions,
    bool wheelchair,
  }) {
    return SettingPanelState(
      typeWalkingSpeed: typeWalkingSpeed ?? this.typeWalkingSpeed,
      transportModes: transportModes ?? this.transportModes,
      bikeRentalNetworks: bikeRentalNetworks ?? this.bikeRentalNetworks,
      avoidTransfers: avoidTransfers ?? this.avoidTransfers,
      avoidWalking: avoidWalking ?? this.avoidWalking,
      includeBikeSuggestions: includeBikeSuggestions ?? this.includeBikeSuggestions,
      typeBikingSpeed: typeBikingSpeed ?? this.typeBikingSpeed,
      includeParkAndRideSuggestions:
          includeParkAndRideSuggestions ?? this.includeParkAndRideSuggestions,
      includeCarSuggestions: includeCarSuggestions ?? this.includeCarSuggestions,
      wheelchair: wheelchair ?? this.wheelchair,
    );
  }

  // Json
  factory SettingPanelState.fromJson(Map<String, dynamic> json) {
    return SettingPanelState(
      typeWalkingSpeed: getWalkingSpeed(json[_typeWalkingSpeed] as String),
      transportModes: json[_transportModes]
          .map<TransportMode>(
            (key) => getTransportMode(mode: key as String),
          )
          .toList() as List<TransportMode>,
      bikeRentalNetworks: json[_bikeRentalNetworks]
          .map<BikeRentalNetwork>(
            (key) => getBikeRentalNetwork(key as String),
          )
          .toList() as List<BikeRentalNetwork>,
      avoidTransfers: json[_avoidTransfers] as bool,
      avoidWalking: json[_avoidWalking] as bool,
      includeBikeSuggestions: json[_includeBikeSuggestions] as bool,
      typeBikingSpeed: getBikingSpeed(json[_typeBikingSpeed] as String),
      includeParkAndRideSuggestions: json[_includeParkAndRideSuggestions] as bool,
      includeCarSuggestions: json[_includeCarSuggestions] as bool,
      wheelchair: json[_wheelchair] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _typeWalkingSpeed: typeWalkingSpeed.name,
      _avoidWalking: avoidWalking,
      _transportModes: transportModes.map((transportMode) => transportMode.name).toList(),
      _bikeRentalNetworks:
          bikeRentalNetworks.map((bikeRentalNetwork) => bikeRentalNetwork.name).toList(),
      _avoidTransfers: avoidTransfers,
      _includeBikeSuggestions: includeBikeSuggestions,
      _typeBikingSpeed: typeBikingSpeed.name,
      _includeParkAndRideSuggestions: includeParkAndRideSuggestions,
      _includeCarSuggestions: includeCarSuggestions,
      _wheelchair: wheelchair,
    };
  }

  @override
  List<Object> get props => [
        typeWalkingSpeed,
        avoidWalking,
        transportModes,
        bikeRentalNetworks,
        avoidTransfers,
        includeBikeSuggestions,
        typeBikingSpeed,
        includeParkAndRideSuggestions,
        includeCarSuggestions,
        wheelchair,
      ];
}
