import 'package:flutter/material.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/utils/util_icons/custom_icons.dart';

enum TransportMode {
  error,
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
  required String mode,
  String? specificTransport,
}) {
  TransportMode value = TransportMode.walk;
  if (specificTransport != null) {
    final String enumType = specificTransport.toUpperCase();
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
    TransportMode.error: "ERROR",
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

  static const _icons = <TransportMode, IconData?>{
    TransportMode.airplane: Icons.airplanemode_active,
    TransportMode.bicycle: Icons.directions_bike,
    TransportMode.bus: Icons.directions_bus,
    TransportMode.cableCar: null,
    TransportMode.car: Icons.drive_eta,
    TransportMode.carPool: Icons.drive_eta,
    TransportMode.ferry: Icons.directions_ferry,
    TransportMode.flexible: Icons.warning,
    TransportMode.funicular: null,
    TransportMode.gondola: null,
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

  static Widget? _images(TransportMode transportMode, Color? color) {
    switch (transportMode) {
      case TransportMode.airplane:
        return null;
      case TransportMode.bicycle:
        return bikeIcon(color: color ?? const Color(0xff666666));
      case TransportMode.bus:
        return busIcon(color: color ?? const Color(0xffff260c));
      case TransportMode.cableCar:
        return gondolaIcon(color: color ?? const Color(0xff000000));
      case TransportMode.car:
        return carIcon(color: color ?? const Color(0xff000000));
      case TransportMode.carPool:
        return carpoolIcon(color: color ?? const Color(0xff9fc727));
      case TransportMode.ferry:
        return null;
      case TransportMode.flexible:
        return null;
      case TransportMode.funicular:
        return gondolaIcon(color: color ?? const Color(0xff000000));
      case TransportMode.gondola:
        return gondolaIcon(color: color ?? const Color(0xff000000));
      case TransportMode.legSwitch:
        return null;
      case TransportMode.rail:
        return railIcon(color: color ?? const Color(0xff018000));
      case TransportMode.subway:
        return subwayIcon(color: color ?? Colors.blueAccent[700]);
      case TransportMode.tram:
        return null;
      case TransportMode.transit:
        return null;
      case TransportMode.walk:
        return walkIcon(color: color ?? const Color(0xff000000));
      // route icons for specific types of transportation
      case TransportMode.trufi:
        return null;
      case TransportMode.micro:
        return null;
      case TransportMode.miniBus:
        return null;
      case TransportMode.lightRail:
        return null;
      default:
        return null;
    }
  }

  static final _colors = <TransportMode, Color?>{
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
    TransportMode.trufi: const Color(0xffd81b60),
    TransportMode.micro: const Color(0xffd81b60),
    TransportMode.miniBus: const Color(0xffd81b60),
    TransportMode.lightRail: const Color(0xffd81b60),
  };

  static final _backgroundColors = <TransportMode, Color?>{
    TransportMode.airplane: null,
    TransportMode.bicycle: Colors.grey[200],
    TransportMode.bus: const Color(0xffff260c),
    TransportMode.cableCar: null,
    TransportMode.car: Colors.black,
    TransportMode.carPool: const Color(0xff9fc726),
    TransportMode.ferry: const Color(0xff1B3661),
    TransportMode.flexible: null,
    TransportMode.funicular: null,
    TransportMode.gondola: null,
    TransportMode.legSwitch: null,
    TransportMode.rail: const Color(0xff018000),
    TransportMode.subway: Colors.blueAccent[700],
    TransportMode.tram: null,
    TransportMode.transit: null,
    TransportMode.walk: Colors.grey[200],
    // route icons for specific types of transportation
    TransportMode.trufi: const Color(0xffd81b60),
    TransportMode.micro: const Color(0xffd81b60),
    TransportMode.miniBus: const Color(0xffd81b60),
    TransportMode.lightRail: const Color(0xffd81b60),
  };

  static const qualifiers = <TransportMode, String>{
    TransportMode.bicycle: 'RENT',
  };

  static String? _translates(
      TransportMode mode, TrufiBaseLocalization localization) {
    return {
      TransportMode.airplane: null,
      TransportMode.bicycle: localization.instructionVehicleBike,
      TransportMode.bus: localization.instructionVehicleBus,
      TransportMode.cableCar: localization.instructionVehicleGondola,
      TransportMode.car: localization.instructionVehicleCar,
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
      TransportMode.walk: localization.instructionVehicleBike,
      // route icons for specific types of transportation
      TransportMode.trufi: localization.instructionVehicleTrufi,
      TransportMode.micro: localization.instructionVehicleMicro,
      TransportMode.miniBus: localization.instructionVehicleMinibus,
      TransportMode.lightRail: localization.instructionVehicleLightRail,
    }[mode];
  }

  String get name => names[this] ?? 'ERROR';
  String? get qualifier => qualifiers[this];

  String getTranslate(TrufiBaseLocalization localization) =>
      _translates(this, localization) ?? 'No translate';

  Color get color => _colors[this] ?? const Color(0xff1B3661);

  Color get backgroundColor =>
      _backgroundColors[this] ?? const Color(0xff1B3661);

  Widget getImage({Color? color, double size = 24}) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      child: FittedBox(
        child: _images(this, color) ??
            (_icons[this] != null
                ? Icon(
                    _icons[this],
                    color: color ?? color,
                  )
                : const Icon(
                    Icons.error,
                    color: Colors.red,
                  )),
      ),
    );
  }
}
