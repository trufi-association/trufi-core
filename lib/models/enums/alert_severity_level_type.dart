enum AlertSeverityLevelTypeTrufi { unknownseverity, info, warning, severe }

AlertSeverityLevelTypeTrufi getAlertSeverityLevelTypeByString(
    String alertSeverityLevelType) {
  return AlertSeverityLevelTypeExtension.names.keys.firstWhere(
    (key) => key.name == alertSeverityLevelType,
    orElse: () => AlertSeverityLevelTypeTrufi.unknownseverity,
  );
}

extension AlertSeverityLevelTypeExtension on AlertSeverityLevelTypeTrufi {
  static const names = <AlertSeverityLevelTypeTrufi, String>{
    AlertSeverityLevelTypeTrufi.unknownseverity: 'UNKNOWN_SEVERITY',
    AlertSeverityLevelTypeTrufi.info: 'INFO',
    AlertSeverityLevelTypeTrufi.warning: 'WARNING',
    AlertSeverityLevelTypeTrufi.severe: 'SEVERE'
  };

  String get name => names[this] ?? 'UNKNOWN_SEVERITY';
}
