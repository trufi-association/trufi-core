enum LegMode {
  bicycle,
  bicycleWalk,
  cityBike,
  walk,
  undefined,
}

LegMode getLegModeByKey(String key) {
  return LegModeExtension.names.keys.firstWhere(
    (keyE) => keyE.name == key,
    orElse: () => LegMode.undefined,
  );
}

extension LegModeExtension on LegMode {
  static const names = <LegMode, String>{
    LegMode.bicycle: 'BICYCLE',
    LegMode.bicycleWalk: 'BICYCLE_WALK',
    LegMode.cityBike: 'CITYBIKE',
    LegMode.walk: 'WALK',
    LegMode.undefined: 'UNDEFINED',
  };

  String get name => names[this];
}
