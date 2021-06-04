enum BikesAllowed {
  noInformation,
  allowed,
  notAllowed,
}

BikesAllowed getBikesAllowedByString(String bikesAllowed) {
  return BikesAllowedExtension.names.keys.firstWhere(
    (key) => key.name == bikesAllowed,
    orElse: () => BikesAllowed.noInformation,
  );
}

extension BikesAllowedExtension on BikesAllowed {
  static const names = <BikesAllowed, String>{
    BikesAllowed.noInformation: 'NO_INFORMATION',
    BikesAllowed.allowed: 'ALLOWED',
    BikesAllowed.notAllowed: 'NOT_ALLOWED',
  };
  String get name => names[this] ?? 'NO_INFORMATION';
}
