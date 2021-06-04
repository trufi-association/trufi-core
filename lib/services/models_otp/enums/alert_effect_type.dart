enum AlertEffectType {
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

AlertEffectType getAlertEffectTypeByString(String alertEffectType) {
  return AlertEffectTypeExtension.names.keys.firstWhere(
    (key) => key.name == alertEffectType,
    orElse: () => AlertEffectType.noService,
  );
}

extension AlertEffectTypeExtension on AlertEffectType {
  static const names = <AlertEffectType, String>{
    AlertEffectType.noService: 'NO_SERVICE',
    AlertEffectType.reducedService: 'REDUCED_SERVICE',
    AlertEffectType.significantDelays: 'SIGNIFICANT_DELAYS',
    AlertEffectType.detour: 'DETOUR',
    AlertEffectType.additionalService: 'ADDITIONAL_SERVICE',
    AlertEffectType.modifiedService: 'MODIFIED_SERVICE',
    AlertEffectType.otherEffect: 'OTHER_EFFECT',
    AlertEffectType.unknownEffect: 'UNKNOWN_EFFECT',
    AlertEffectType.stopMoved: 'STOP_MOVED',
    AlertEffectType.noEffect: 'NO_EFFECT',
  };
  String get name => names[this] ?? 'NO_SERVICE';
}
