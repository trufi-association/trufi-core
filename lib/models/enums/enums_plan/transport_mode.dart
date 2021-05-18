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

  static final images = <TransportMode, SvgPicture>{
    TransportMode.airplane: null,
    TransportMode.bicycle: SvgPicture.string(citybike ?? ""),
    TransportMode.bus: SvgPicture.string(bus ?? ""),
    TransportMode.cableCar: null,
    TransportMode.car: SvgPicture.string(carpool ?? ""),
    TransportMode.carPool: SvgPicture.string(carpool ?? ""),
    TransportMode.ferry: null,
    TransportMode.flexible: null,
    TransportMode.funicular: null,
    TransportMode.gondola: null,
    TransportMode.legSwitch: null,
    TransportMode.rail: SvgPicture.string(rail ?? ""),
    TransportMode.subway: SvgPicture.string(subway ?? ""),
    TransportMode.tram: null,
    TransportMode.transit: null,
    TransportMode.walk: null,
    // route icons for specific types of transportation
    TransportMode.trufi: null,
    TransportMode.micro: null,
    TransportMode.miniBus: null,
    TransportMode.lightRail: null,
  };

  static final colors = <TransportMode, Color>{
    TransportMode.airplane: null,
    TransportMode.bicycle: Colors.blue,
    TransportMode.bus: const Color(0xffff260c),
    TransportMode.cableCar: null,
    TransportMode.car: null,
    TransportMode.ferry: null,
    TransportMode.flexible: null,
    TransportMode.funicular: null,
    TransportMode.gondola: null,
    TransportMode.legSwitch: null,
    TransportMode.rail: const Color(0xff83b23b),
    TransportMode.subway: Colors.blueAccent[700],
    TransportMode.tram: null,
    TransportMode.transit: null,
    TransportMode.walk: Colors.grey[850],
    // route icons for specific types of transportation
    TransportMode.trufi: const Color(0xffff260c),
    TransportMode.micro: const Color(0xffff260c),
    TransportMode.miniBus: const Color(0xffff260c),
    TransportMode.lightRail: const Color(0xff83b23b),
  };
  static const qualifiers = <TransportMode, String>{
    TransportMode.bicycle: "RENT",
  };

  String get name => names[this] ?? 'WALK';
  IconData get icon => icons[this] ?? Icons.directions_walk;
  Color get color => colors[this] ?? Colors.grey;
  SvgPicture get image =>
      images[this] ??
      SvgPicture.asset(
        "assets/images/transport_modes/icon-icon_bus-live-green.svg",
        package: "trufi_core",
      );
  String get qualifier => qualifiers[this] ?? "";
}
