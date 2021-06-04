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
  medicalemergency
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
    AlertCauseType.medicalemergency: 'MEDICAL_EMERGENCY'
  };
  String get name => names[this] ?? 'UNKNOWN_CAUSE';
}
