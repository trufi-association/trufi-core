import 'package:trufi_core/models/enums/alert_severity_level_type.dart';

enum AlertSeverityLevelType { unknownseverity, info, warning, severe }

AlertSeverityLevelType getAlertSeverityLevelTypeByString(
  String alertSeverityLevelType,
) {
  return AlertSeverityLevelTypeExtension.names.keys.firstWhere(
    (key) => key.name == alertSeverityLevelType,
    orElse: () => AlertSeverityLevelType.unknownseverity,
  );
}

extension AlertSeverityLevelTypeExtension on AlertSeverityLevelType {
  static const names = <AlertSeverityLevelType, String>{
    AlertSeverityLevelType.unknownseverity: 'UNKNOWN_SEVERITY',
    AlertSeverityLevelType.info: 'INFO',
    AlertSeverityLevelType.warning: 'WARNING',
    AlertSeverityLevelType.severe: 'SEVERE',
  };

  String get name => names[this] ?? 'UNKNOWN_SEVERITY';

  AlertSeverityLevelTypeTrufi toAlertSeverityLevelType() {
    switch (this) {
      case AlertSeverityLevelType.unknownseverity:
        return AlertSeverityLevelTypeTrufi.unknownseverity;
      case AlertSeverityLevelType.info:
        return AlertSeverityLevelTypeTrufi.info;
      case AlertSeverityLevelType.warning:
        return AlertSeverityLevelTypeTrufi.warning;
      case AlertSeverityLevelType.severe:
        return AlertSeverityLevelTypeTrufi.severe;
    }
  }
}
