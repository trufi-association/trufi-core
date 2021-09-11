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

  static SvgPicture images(TransportMode transportMode, Color color) {
    final String colorHX = color?.value?.toRadixString(16);
    switch (transportMode) {
      case TransportMode.airplane:
        return null;
        break;
      case TransportMode.bicycle:
        return SvgPicture.string(bike(color: colorHX ?? '666666') ?? "");
        break;
      case TransportMode.bus:
        return SvgPicture.string(bus(color: colorHX ?? 'ff260c') ?? "");
        break;
      case TransportMode.cableCar:
        return null;
        break;
      case TransportMode.car:
        return SvgPicture.string(car(color: colorHX ?? 'ff260c') ?? "");
        break;
      case TransportMode.carPool:
        return SvgPicture.string(carpool ?? "");
        break;
      case TransportMode.ferry:
        return null;
        break;
      case TransportMode.flexible:
        return null;
        break;
      case TransportMode.funicular:
        return null;
        break;
      case TransportMode.gondola:
        return null;
        break;
      case TransportMode.legSwitch:
        return null;
        break;
      case TransportMode.rail:
        return SvgPicture.string(rail(color: colorHX ?? '83b23b') ?? "");
        break;
      case TransportMode.subway:
        return SvgPicture.string(subway(color: colorHX ?? '2962ff') ?? "");
        break;
      case TransportMode.tram:
        return null;
        break;
      case TransportMode.transit:
        return null;
        break;
      case TransportMode.walk:
        return SvgPicture.string(walk ?? "");
        break;
      // route icons for specific types of transportation
      case TransportMode.trufi:
        return null;
        break;
      case TransportMode.micro:
        return null;
        break;
      case TransportMode.miniBus:
        return null;
        break;
      case TransportMode.lightRail:
        return null;
        break;
      default:
        return null;
    }
  }

  static final colors = <TransportMode, Color>{
    TransportMode.airplane: null,
    TransportMode.bicycle: const Color(0xff666666),
    TransportMode.bus: const Color(0xffff260c),
    TransportMode.cableCar: null,
    TransportMode.car: Colors.black,
    TransportMode.carPool: const Color(0xff9fc726),
    TransportMode.ferry: null,
    TransportMode.flexible: null,
    TransportMode.funicular: null,
    TransportMode.gondola: null,
    TransportMode.legSwitch: null,
    TransportMode.rail: const Color(0xff018000),
    TransportMode.subway: Colors.blueAccent[700],
    TransportMode.tram: null,
    TransportMode.transit: null,
    TransportMode.walk: Colors.grey[700],
    // route icons for specific types of transportation
    TransportMode.trufi: const Color(0xffff260c),
    TransportMode.micro: const Color(0xffff260c),
    TransportMode.miniBus: const Color(0xffff260c),
    TransportMode.lightRail: const Color(0xff83b23b),
  };

  static final backgroundColors = <TransportMode, Color>{
    TransportMode.airplane: null,
    TransportMode.bicycle: Colors.grey[200],
    TransportMode.bus: const Color(0xffff260c),
    TransportMode.cableCar: null,
    TransportMode.car: Colors.black,
    TransportMode.carPool: const Color(0xff9fc726),
    TransportMode.ferry: null,
    TransportMode.flexible: null,
    TransportMode.funicular: null,
    TransportMode.gondola: null,
    TransportMode.legSwitch: null,
    TransportMode.rail: const Color(0xff83b23b),
    TransportMode.subway: Colors.blueAccent[700],
    TransportMode.tram: null,
    TransportMode.transit: null,
    TransportMode.walk: Colors.grey[200],
    // route icons for specific types of transportation
    TransportMode.trufi: const Color(0xffff260c),
    TransportMode.micro: const Color(0xffff260c),
    TransportMode.miniBus: const Color(0xffff260c),
    TransportMode.lightRail: const Color(0xff83b23b),
  };
  static const qualifiers = <TransportMode, String>{
    TransportMode.bicycle: 'RENT',
  };

  static String translates(TransportMode mode, TrufiLocalization localization) {
    return {
      TransportMode.airplane: null,
      TransportMode.bicycle: localization.instructionVehicleBike,
      TransportMode.bus: localization.instructionVehicleBus,
      TransportMode.cableCar: localization.instructionVehicleGondola,
      TransportMode.car: localization.instructionVehicleOnCar,
      TransportMode.carPool: localization.instructionVehicleCarpool,
      TransportMode.ferry: localization.instructionVehicleMetro,
      TransportMode.flexible: null,
      TransportMode.funicular: null,
      TransportMode.gondola: localization.instructionVehicleGondola,
      TransportMode.legSwitch: null,
      TransportMode.rail: localization.instructionVehicleLightRail,
      TransportMode.subway: localization.instructionVehicleMetro,
      TransportMode.tram: localization.instructionVehicleCommuterTrain,
      TransportMode.transit: null,
      TransportMode.walk: localization.instructionVehicleBus,
      // route icons for specific types of transportation
      TransportMode.trufi: localization.instructionVehicleTrufi,
      TransportMode.micro: localization.instructionVehicleMicro,
      TransportMode.miniBus: localization.instructionVehicleMinibus,
      TransportMode.lightRail: localization.instructionVehicleLightRail,
    }[mode];
  }

  String getTranslate(TrufiLocalization localization) =>
      translates(this, localization) ?? 'No translate';

  String get name => names[this] ?? 'WALK';
  IconData get icon => icons[this] ?? Icons.directions_walk;
  Color get color => colors[this] ?? Colors.grey;
  Color get backgroundColor => backgroundColors[this] ?? Colors.transparent;
  Widget getImage({Color color}) =>
      images(this, color) ??
      (Icon(
            icons[this],
            color: color,
          ) ??
          const Icon(
            Icons.error,
            color: Colors.red,
          ));
  String get qualifier => qualifiers[this];
}
