enum PickupDropoffType { scheduled, none, callagency, coordinatewithdriver }

PickupDropoffType getPickupDropoffTypeByString(String pickupDropoffType) {
  return PickupDropoffTypeExtension.names.keys.firstWhere(
    (key) => key.name == pickupDropoffType,
    orElse: () => PickupDropoffType.scheduled,
  );
}

extension PickupDropoffTypeExtension on PickupDropoffType {
  static const names = <PickupDropoffType, String>{
    PickupDropoffType.scheduled: 'SCHEDULED',
    PickupDropoffType.none: 'NONE',
    PickupDropoffType.callagency: 'CALL_AGENCY',
    PickupDropoffType.coordinatewithdriver: 'COORDINATE_WITH_DRIVER'
  };
  String get name => names[this] ?? 'SCHEDULED';
}
