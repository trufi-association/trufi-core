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
}
