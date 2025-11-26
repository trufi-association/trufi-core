enum AlertCauseTypeTrufi {
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

AlertCauseTypeTrufi getAlertCauseTypeByString(String alertCauseType) {
  return AlertCauseTypeExtension.names.keys.firstWhere(
    (key) => key.name == alertCauseType,
    orElse: () => AlertCauseTypeTrufi.unknowncause,
  );
}

extension AlertCauseTypeExtension on AlertCauseTypeTrufi {
  static const names = <AlertCauseTypeTrufi, String>{
    AlertCauseTypeTrufi.unknowncause: 'UNKNOWN_CAUSE',
    AlertCauseTypeTrufi.othercause: 'OTHER_CAUSE',
    AlertCauseTypeTrufi.technicalproblem: 'TECHNICAL_PROBLEM',
    AlertCauseTypeTrufi.strike: 'STRIKE',
    AlertCauseTypeTrufi.demonstration: 'DEMONSTRATION',
    AlertCauseTypeTrufi.accident: 'ACCIDENT',
    AlertCauseTypeTrufi.holiday: 'HOLIDAY',
    AlertCauseTypeTrufi.weather: 'WEATHER',
    AlertCauseTypeTrufi.maintenance: 'MAINTENANCE',
    AlertCauseTypeTrufi.construction: 'CONSTRUCTION',
    AlertCauseTypeTrufi.policeactivity: 'POLICE_ACTIVITY',
    AlertCauseTypeTrufi.medicalemergency: 'MEDICAL_EMERGENCY'
  };
  String get name => names[this] ?? 'UNKNOWN_CAUSE';
}
