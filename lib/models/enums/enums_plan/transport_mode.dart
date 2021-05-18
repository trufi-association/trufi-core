part of 'enums_plan.dart';

enum TransportMode {
  airplane,
  bicycle,
  bus,
  cableCar,
  car,
  carPool,
  ferry,
  flexible,
  funicular,
  gondola,
  legSwitch,
  rail,
  subway,
  tram,
  transit,
  walk,
  // route name keywords for specific types of transportation
  trufi,
  micro,
  miniBus,
  lightRail,
}

const defaultTransportModes = <TransportMode>[
  TransportMode.bus,
  TransportMode.rail,
  TransportMode.subway,
  TransportMode.walk,
];

TransportMode getTransportMode({
  @required String mode,
  String specificTransport,
}) {
  TransportMode value = TransportMode.walk;
  if (specificTransport != null) {
    final String enumType = specificTransport?.toUpperCase() ?? "";
    value = enumType.contains(TransportMode.trufi.name)
        ? TransportMode.trufi
        : enumType.contains(TransportMode.micro.name)
            ? TransportMode.bus
            : enumType.contains(TransportMode.miniBus.name)
                ? TransportMode.miniBus
                : enumType.contains(TransportMode.gondola.name)
                    ? TransportMode.gondola
                    : enumType.contains(TransportMode.lightRail.name)
                        ? TransportMode.lightRail
                        : _getTransportModeByMode(mode);
  } else {
    value = _getTransportModeByMode(mode);
  }
  return value;
}

TransportMode _getTransportModeByMode(String mode) {
  return TransportModeExtension.names.keys.firstWhere(
    (key) => key.name == mode,
    orElse: () => TransportMode.walk,
  );
}

extension TransportModeExtension on TransportMode {
  static const names = <TransportMode, String>{
    TransportMode.airplane: "AIRPLANE",
    TransportMode.bicycle: "BICYCLE",
    TransportMode.bus: "BUS",
    TransportMode.cableCar: "CABLE_CAR",
    TransportMode.car: "CAR",
    TransportMode.carPool: "CARPOOL",
    TransportMode.ferry: "FERRY",
    TransportMode.flexible: "FLEXIBLE",
    TransportMode.funicular: "FUNICULAR",
    TransportMode.gondola: "GONDOLA",
    TransportMode.legSwitch: "LEG_SWITCH",
    TransportMode.rail: "RAIL",
    TransportMode.subway: "SUBWAY",
    TransportMode.tram: "TRAM",
    TransportMode.transit: "TRANSIT",
    TransportMode.walk: "WALK",
    // route name keywords for specific types of transportation
    TransportMode.trufi: "TRUFI",
    TransportMode.micro: "MICRO",
    TransportMode.miniBus: "MINIBUS",
    TransportMode.lightRail: "LIGHT RAIL",
  };

  static const icons = <TransportMode, IconData>{
    TransportMode.airplane: Icons.airplanemode_active,
    TransportMode.bicycle: Icons.pedal_bike,
    TransportMode.bus: Icons.directions_bus,
    TransportMode.cableCar: CustomIcons.gondola,
    TransportMode.car: Icons.drive_eta,
    TransportMode.carPool: Icons.drive_eta,
    TransportMode.ferry: Icons.directions_ferry,
    TransportMode.flexible: Icons.warning,
    TransportMode.funicular: CustomIcons.gondola,
    TransportMode.gondola: CustomIcons.gondola,
    TransportMode.legSwitch: Icons.warning,
    TransportMode.rail: Icons.train,
    TransportMode.subway: Icons.directions_subway,
    TransportMode.tram: Icons.warning,
    TransportMode.transit: Icons.directions_transit,
    TransportMode.walk: Icons.directions_walk,
    // route icons for specific types of transportation
    TransportMode.trufi: Icons.local_taxi,
    TransportMode.micro: Icons.directions_bus,
    TransportMode.miniBus: Icons.airport_shuttle,
    TransportMode.lightRail: Icons.train,
  };
  static const qualifiers = <TransportMode, String>{
    TransportMode.bicycle: "RENT",
  };
  String get name => names[this] ?? 'WALK';
  IconData get icon => icons[this] ?? Icons.directions_walk;
  String get qualifier => qualifiers[this] ?? "";
}
