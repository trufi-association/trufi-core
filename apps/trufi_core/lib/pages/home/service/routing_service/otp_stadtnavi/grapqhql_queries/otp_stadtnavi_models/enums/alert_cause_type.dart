import 'package:trufi_core/models/enums/alert_cause_type.dart';

enum AlertCauseType {
  unknowncause,
  othercause,
  technicalproblem,
  strike,
  demonstration,
  accident,
  holiday,
  weather,
  maintenance,
  construction,
  policeactivity,
  medicalemergency,
}

AlertCauseType getAlertCauseTypeByString(String alertCauseType) {
  return AlertCauseTypeExtension.names.keys.firstWhere(
    (key) => key.name == alertCauseType,
    orElse: () => AlertCauseType.unknowncause,
  );
}

extension AlertCauseTypeExtension on AlertCauseType {
  static const names = <AlertCauseType, String>{
    AlertCauseType.unknowncause: 'UNKNOWN_CAUSE',
    AlertCauseType.othercause: 'OTHER_CAUSE',
    AlertCauseType.technicalproblem: 'TECHNICAL_PROBLEM',
    AlertCauseType.strike: 'STRIKE',
    AlertCauseType.demonstration: 'DEMONSTRATION',
    AlertCauseType.accident: 'ACCIDENT',
    AlertCauseType.holiday: 'HOLIDAY',
    AlertCauseType.weather: 'WEATHER',
    AlertCauseType.maintenance: 'MAINTENANCE',
    AlertCauseType.construction: 'CONSTRUCTION',
    AlertCauseType.policeactivity: 'POLICE_ACTIVITY',
    AlertCauseType.medicalemergency: 'MEDICAL_EMERGENCY',
  };
  String get name => names[this] ?? 'UNKNOWN_CAUSE';

  AlertCauseTypeTrufi toAlertCauseType() {
    switch (this) {
      case AlertCauseType.unknowncause:
        return AlertCauseTypeTrufi.unknowncause;
      case AlertCauseType.othercause:
        return AlertCauseTypeTrufi.othercause;
      case AlertCauseType.technicalproblem:
        return AlertCauseTypeTrufi.technicalproblem;
      case AlertCauseType.strike:
        return AlertCauseTypeTrufi.strike;
      case AlertCauseType.demonstration:
        return AlertCauseTypeTrufi.demonstration;
      case AlertCauseType.accident:
        return AlertCauseTypeTrufi.accident;
      case AlertCauseType.holiday:
        return AlertCauseTypeTrufi.holiday;
      case AlertCauseType.weather:
        return AlertCauseTypeTrufi.weather;
      case AlertCauseType.maintenance:
        return AlertCauseTypeTrufi.maintenance;
      case AlertCauseType.construction:
        return AlertCauseTypeTrufi.construction;
      case AlertCauseType.policeactivity:
        return AlertCauseTypeTrufi.policeactivity;
      case AlertCauseType.medicalemergency:
        return AlertCauseTypeTrufi.medicalemergency;
    }
  }
}
