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
  walk,
}

Mode getModeByString(String mode) {
  final sdsad = ModeExtension.names.keys.firstWhere(
    (key) => key.name.toUpperCase() == mode.toUpperCase(),
    orElse: () => Mode.walk,
  );
  return sdsad;
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
  String toOtpString() => names[this] ?? '';
}
