import 'package:trufi_core/l10n/trufi_localization.dart';

enum PlanInfoBox { usingDefaultTransports, undefined }

PlanInfoBox getPlanInfoBoxByKey(String key) {
  return PlanInfoBoxExtension.names.keys.firstWhere(
    (keyE) => keyE.name == key,
    orElse: () => PlanInfoBox.usingDefaultTransports,
  );
}

extension PlanInfoBoxExtension on PlanInfoBox {
  static const names = <PlanInfoBox, String>{
    PlanInfoBox.usingDefaultTransports: 'USING_DEFAULT_TRANSPORTS',
    PlanInfoBox.undefined: 'UNDEFINED',
  };

  String get name => names[this];

  String translateValue(TrufiLocalization localization) {
    switch (this) {
      case PlanInfoBox.usingDefaultTransports:
        // TODO translate
        return 'Keine Routenvorschläge mit Ihren Einstelllungen gefunden. Stattdessen haben wird die folgenden Reiseoptionen gefunden:';
        break;
      default:
        return localization.commonError;
    }
  }
}
