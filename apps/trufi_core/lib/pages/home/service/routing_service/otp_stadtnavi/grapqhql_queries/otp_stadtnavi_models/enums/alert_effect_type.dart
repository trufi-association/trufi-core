import 'package:trufi_core/models/enums/alert_effect_type.dart';

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

  AlertEffectTypeTrufi toAlertEffectType() {
    switch (this) {
      case AlertEffectType.noService:
        return AlertEffectTypeTrufi.noService;
      case AlertEffectType.reducedService:
        return AlertEffectTypeTrufi.reducedService;
      case AlertEffectType.significantDelays:
        return AlertEffectTypeTrufi.significantDelays;
      case AlertEffectType.detour:
        return AlertEffectTypeTrufi.detour;
      case AlertEffectType.additionalService:
        return AlertEffectTypeTrufi.additionalService;
      case AlertEffectType.modifiedService:
        return AlertEffectTypeTrufi.modifiedService;
      case AlertEffectType.otherEffect:
        return AlertEffectTypeTrufi.otherEffect;
      case AlertEffectType.unknownEffect:
        return AlertEffectTypeTrufi.unknownEffect;
      case AlertEffectType.stopMoved:
        return AlertEffectTypeTrufi.stopMoved;
      case AlertEffectType.noEffect:
        return AlertEffectTypeTrufi.noEffect;
    }
  }
}
