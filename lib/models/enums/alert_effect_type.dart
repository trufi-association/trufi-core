enum AlertEffectTypeTrufi {
  noService,
  reducedService,
  significantDelays,
  detour,
  additionalService,
  modifiedService,
  otherEffect,
  unknownEffect,
  stopMoved,
  noEffect,
}

AlertEffectTypeTrufi getAlertEffectTypeByString(String alertEffectType) {
  return AlertEffectTypeExtension.names.keys.firstWhere(
    (key) => key.name == alertEffectType,
    orElse: () => AlertEffectTypeTrufi.noService,
  );
}

extension AlertEffectTypeExtension on AlertEffectTypeTrufi {
  static const names = <AlertEffectTypeTrufi, String>{
    AlertEffectTypeTrufi.noService: 'NO_SERVICE',
    AlertEffectTypeTrufi.reducedService: 'REDUCED_SERVICE',
    AlertEffectTypeTrufi.significantDelays: 'SIGNIFICANT_DELAYS',
    AlertEffectTypeTrufi.detour: 'DETOUR',
    AlertEffectTypeTrufi.additionalService: 'ADDITIONAL_SERVICE',
    AlertEffectTypeTrufi.modifiedService: 'MODIFIED_SERVICE',
    AlertEffectTypeTrufi.otherEffect: 'OTHER_EFFECT',
    AlertEffectTypeTrufi.unknownEffect: 'UNKNOWN_EFFECT',
    AlertEffectTypeTrufi.stopMoved: 'STOP_MOVED',
    AlertEffectTypeTrufi.noEffect: 'NO_EFFECT',
  };
  String get name => names[this] ?? 'NO_SERVICE';
}
