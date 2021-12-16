part of 'payload_data_plan_cubit.dart';

final initPayloadDataPlanState = PayloadDataPlanState(
  typeWalkingSpeed: WalkingSpeed.average,
  avoidWalking: false,
  transportModes: defaultTransportModes,
  bikeRentalNetworks: defaultBikeRentalNetworks,
  triangleFactor: TriangleFactor.unknown,
  avoidTransfers: false,
  includeBikeSuggestions: true,
  typeBikingSpeed: BikingSpeed.average,
  includeParkAndRideSuggestions: true,
  includeCarSuggestions: true,
  wheelchair: false,
  arriveBy: false,
  date: DateTime.now(),
);

@immutable
class PayloadDataPlanState extends Equatable {
  static const int maxWalkDistance = 3000;
  static const int suggestCarMinDistance = 2000;
  static const int suggestBikeMaxDistance = 30000;
  static const int suggestBikeAndPublicMaxDistance = 15000;
  static const int bikeAndPublicMaxWalkDistance = 15000;
  static const int minDistanceBetweenFromAndTo = 20;
  static const List<String> parkAndRideBannedVehicleParkingTags = [
    'lot_type:Parkplatz',
    'lot_type:Tiefgarage',
    'lot_type:Parkhaus'
  ];

  static const String _typeWalkingSpeed = "typeWalkingSpeed";
  static const String _avoidWalking = "avoidWalking";
  static const String _transportModes = "transportModes";
  static const String _bikeRentalNetworks = "bikeRentalNetworks";
  static const String _triangleFactor = "triangleFactor";
  static const String _avoidTransfers = "avoidTransfers";
  static const String _includeBikeSuggestions = "includeBikeSuggestions";
  static const String _typeBikingSpeed = "typeBikingSpeed";
  static const String _includeParkAndRideSuggestions =
      "includeParkAndRideSuggestions";
  static const String _includeCarSuggestions = "includeCarSuggestions";
  static const String _wheelchair = "wheelchair";
  static const String _date = "date";
  static const String _arriveBy = "arriveBy";

  const PayloadDataPlanState({
    required this.typeWalkingSpeed,
    required this.avoidWalking,
    required this.transportModes,
    required this.bikeRentalNetworks,
    required this.triangleFactor,
    required this.avoidTransfers,
    required this.includeBikeSuggestions,
    required this.typeBikingSpeed,
    required this.includeParkAndRideSuggestions,
    required this.includeCarSuggestions,
    required this.wheelchair,
    required this.arriveBy,
    required this.date,
    this.isFreeParkToParkRide = false,
    this.isFreeParkToCarPark = false,
  });

  final WalkingSpeed typeWalkingSpeed;
  final bool? avoidWalking;
  final List<TransportMode>? transportModes;
  final List<BikeRentalNetwork>? bikeRentalNetworks;
  final TriangleFactor triangleFactor;
  final bool? avoidTransfers;
  final bool? includeBikeSuggestions;
  final BikingSpeed typeBikingSpeed;
  final bool? includeParkAndRideSuggestions;
  final bool? includeCarSuggestions;
  final bool? wheelchair;
  final bool? arriveBy;
  final DateTime? date;
  final bool isFreeParkToParkRide;
  final bool isFreeParkToCarPark;

  PayloadDataPlanState copyWith({
    WalkingSpeed? typeWalkingSpeed,
    List<TransportMode>? transportModes,
    List<BikeRentalNetwork>? bikeRentalNetworks,
    TriangleFactor? triangleFactor,
    bool? avoidTransfers,
    bool? avoidWalking,
    bool? includeBikeSuggestions,
    BikingSpeed? typeBikingSpeed,
    bool? includeParkAndRideSuggestions,
    bool? includeCarSuggestions,
    bool? wheelchair,
    bool? arriveBy,
    DateTime? date,
    bool? isFreeParkToParkRide,
    bool? isFreeParkToCarPark,
  }) {
    return PayloadDataPlanState(
      typeWalkingSpeed: typeWalkingSpeed ?? this.typeWalkingSpeed,
      transportModes: transportModes ?? this.transportModes,
      bikeRentalNetworks: bikeRentalNetworks ?? this.bikeRentalNetworks,
      triangleFactor: triangleFactor ?? this.triangleFactor,
      avoidTransfers: avoidTransfers ?? this.avoidTransfers,
      avoidWalking: avoidWalking ?? this.avoidWalking,
      includeBikeSuggestions:
          includeBikeSuggestions ?? this.includeBikeSuggestions,
      typeBikingSpeed: typeBikingSpeed ?? this.typeBikingSpeed,
      includeParkAndRideSuggestions:
          includeParkAndRideSuggestions ?? this.includeParkAndRideSuggestions,
      includeCarSuggestions:
          includeCarSuggestions ?? this.includeCarSuggestions,
      wheelchair: wheelchair ?? this.wheelchair,
      arriveBy: arriveBy ?? this.arriveBy,
      date: date ?? this.date,
      isFreeParkToParkRide: isFreeParkToParkRide ?? this.isFreeParkToParkRide,
      isFreeParkToCarPark: isFreeParkToCarPark ?? this.isFreeParkToCarPark,
    );
  }

  PayloadDataPlanState copyWithDateNull({
    bool? arriveBy,
    DateTime? date,
  }) {
    return PayloadDataPlanState(
      typeWalkingSpeed: typeWalkingSpeed,
      transportModes: transportModes,
      bikeRentalNetworks: bikeRentalNetworks,
      triangleFactor: triangleFactor,
      avoidTransfers: avoidTransfers,
      avoidWalking: avoidWalking,
      includeBikeSuggestions: includeBikeSuggestions,
      typeBikingSpeed: typeBikingSpeed,
      includeParkAndRideSuggestions: includeParkAndRideSuggestions,
      includeCarSuggestions: includeCarSuggestions,
      wheelchair: wheelchair,
      arriveBy: arriveBy ?? this.arriveBy,
      date: date,
    );
  }

  // Json
  factory PayloadDataPlanState.fromJson(Map<String, dynamic> json) {
    return PayloadDataPlanState(
      typeWalkingSpeed: getWalkingSpeed(json[_typeWalkingSpeed] as String?),
      transportModes: json[_transportModes]
          .map<TransportMode>(
            (key) => getTransportMode(mode: key as String),
          )
          .toList() as List<TransportMode>?,
      bikeRentalNetworks: json[_bikeRentalNetworks]
          .map<BikeRentalNetwork>(
            (key) => getBikeRentalNetwork(key as String),
          )
          .toList() as List<BikeRentalNetwork>?,
      triangleFactor:
          getTriangleFactorByString(json[_triangleFactor] as String?),
      avoidTransfers: json[_avoidTransfers] as bool?,
      avoidWalking: json[_avoidWalking] as bool?,
      includeBikeSuggestions: json[_includeBikeSuggestions] as bool?,
      typeBikingSpeed: getBikingSpeed(json[_typeBikingSpeed] as String?),
      includeParkAndRideSuggestions:
          json[_includeParkAndRideSuggestions] as bool?,
      includeCarSuggestions: json[_includeCarSuggestions] as bool?,
      wheelchair: json[_wheelchair] as bool?,
      arriveBy: json[_arriveBy] as bool?,
      date: json[_date] != null ? DateTime.parse(json[_date] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _typeWalkingSpeed: typeWalkingSpeed.name,
      _avoidWalking: avoidWalking,
      _transportModes:
          transportModes!.map((transportMode) => transportMode.name).toList(),
      _bikeRentalNetworks: bikeRentalNetworks!
          .map((bikeRentalNetwork) => bikeRentalNetwork.name)
          .toList(),
      _triangleFactor: triangleFactor.name,
      _avoidTransfers: avoidTransfers,
      _includeBikeSuggestions: includeBikeSuggestions,
      _typeBikingSpeed: typeBikingSpeed.name,
      _includeParkAndRideSuggestions: includeParkAndRideSuggestions,
      _includeCarSuggestions: includeCarSuggestions,
      _wheelchair: wheelchair,
      _arriveBy: arriveBy,
      _date: date?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        typeWalkingSpeed,
        avoidWalking,
        transportModes,
        bikeRentalNetworks,
        triangleFactor,
        avoidTransfers,
        includeBikeSuggestions,
        typeBikingSpeed,
        includeParkAndRideSuggestions,
        includeCarSuggestions,
        wheelchair,
        date,
        arriveBy,
        isFreeParkToParkRide,
        isFreeParkToCarPark,
      ];
}
