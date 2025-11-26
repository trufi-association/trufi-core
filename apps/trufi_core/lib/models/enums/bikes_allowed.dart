import 'package:collection/collection.dart';

enum BikesAllowed { noInformation, allowed, notAllowed }

extension BikesAllowedExtension on BikesAllowed {
  static BikesAllowed? getBikesAllowedByString(String? bikesAllowed) {
    return BikesAllowedExtension.names.keys.firstWhereOrNull(
      (key) => key.name == bikesAllowed,
    );
  }

  static const names = <BikesAllowed, String>{
    BikesAllowed.noInformation: 'NO_INFORMATION',
    BikesAllowed.allowed: 'ALLOWED',
    BikesAllowed.notAllowed: 'NOT_ALLOWED',
  };
  String get name => names[this] ?? 'NO_INFORMATION';
}
