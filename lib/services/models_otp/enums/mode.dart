import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:trufi_core/models/enums/enums_plan/icons/icons_transport_modes.dart';
import 'package:trufi_core/utils/util_icons/custom_icons.dart';

enum Mode {
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
  walk
}

Mode getModeByString(String mode) {
  return ModeExtension.names.keys.firstWhere(
    (key) => key.name == mode,
    orElse: () => Mode.walk,
  );
}

extension ModeExtension on Mode {
  static const names = <Mode, String>{
    Mode.airplane: 'AIRPLANE',
    Mode.bicycle: 'BICYCLE',
    Mode.bus: 'BUS',
    Mode.cableCar: 'CABLE_CAR',
    Mode.car: 'CAR',
    Mode.carPool: 'CARPOOL',
    Mode.ferry: 'FERRY',
    Mode.flexible: 'FLEXIBLE',
    Mode.funicular: 'FUNICULAR',
    Mode.gondola: 'GONDOLA',
    Mode.legSwitch: 'LEG_SWITCH',
    Mode.rail: 'RAIL',
    Mode.subway: 'SUBWAY',
    Mode.tram: 'TRAM',
    Mode.transit: 'TRANSIT',
    Mode.walk: 'WALK',
  };

  static const icons = <Mode, IconData>{
    Mode.airplane: Icons.airplanemode_active,
    Mode.bicycle: Icons.pedal_bike,
    Mode.bus: Icons.directions_bus,
    Mode.cableCar: CustomIcons.gondola,
    Mode.car: Icons.drive_eta,
    Mode.carPool: Icons.drive_eta,
    Mode.ferry: Icons.directions_ferry,
    Mode.flexible: Icons.warning,
    Mode.funicular: CustomIcons.gondola,
    Mode.gondola: CustomIcons.gondola,
    Mode.legSwitch: Icons.warning,
    Mode.rail: Icons.train,
    Mode.subway: Icons.directions_subway,
    Mode.tram: Icons.warning,
    Mode.transit: Icons.directions_transit,
    Mode.walk: Icons.directions_walk,
  };

  static final colors = <Mode, Color>{
    Mode.airplane: null,
    Mode.bicycle: Colors.blue,
    Mode.bus: const Color(0xffff260c),
    Mode.cableCar: null,
    Mode.car: null,
    Mode.carPool: const Color(0xff9fc726),
    Mode.ferry: null,
    Mode.flexible: null,
    Mode.funicular: null,
    Mode.gondola: null,
    Mode.legSwitch: null,
    Mode.rail: const Color(0xff83b23b),
    Mode.subway: Colors.blueAccent[700],
    Mode.tram: null,
    Mode.transit: null,
    Mode.walk: Colors.grey[850],
  };

  static final images = <Mode, SvgPicture>{
    Mode.airplane: null,
    Mode.bicycle: SvgPicture.string(citybike ?? ""),
    Mode.bus: SvgPicture.string(bus() ?? ""),
    Mode.cableCar: null,
    Mode.car: SvgPicture.string(carpool ?? ""),
    Mode.carPool: SvgPicture.string(carpool ?? ""),
    Mode.ferry: null,
    Mode.flexible: null,
    Mode.funicular: null,
    Mode.gondola: null,
    Mode.legSwitch: null,
    Mode.rail: SvgPicture.string(rail() ?? ""),
    Mode.subway: SvgPicture.string(subway() ?? ""),
    Mode.tram: null,
    Mode.transit: null,
    Mode.walk: null,
  };

  String get name => names[this] ?? 'WALK';

  IconData get icon => icons[this] ?? (Icons.directions_walk);

  Widget get image => images[this] ?? (Icon(icon, color: color));

  Color get color => colors[this] ?? Colors.grey;
}
