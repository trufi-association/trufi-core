part of 'setting_panel_cubit.dart';

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

  final WalkingSpeed typeWalkingSpeed;
  final bool avoidWalking;
  final List<TransportMode> transportModes;
  final List<BikeRentalNetwork> bikeRentalNetworks;
  final bool avoidTransfers;
  final bool includeBikeSuggestions;
  final BikingSpeed typeBikingSpeed;
  final bool includeParkAndRideSuggestions;
  final bool includeCarSuggestions;
  final bool wheelchair;

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
      _typeBikingSpeed: typeBikingSpeed.value,
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

class JsonSerializable {
  const JsonSerializable();
}
