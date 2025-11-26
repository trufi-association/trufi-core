import 'package:collection/collection.dart';

enum WheelchairBoarding { noinformation, possible, notpossible }

extension WheelchairBoardingExtension on WheelchairBoarding {
  static WheelchairBoarding? getWheelchairBoardingByString(
    String? wheelchairBoarding,
  ) {
    return WheelchairBoardingExtension.names.keys.firstWhereOrNull(
      (key) => key.name == wheelchairBoarding,
    );
  }

  static const names = <WheelchairBoarding, String>{
    WheelchairBoarding.noinformation: 'NO_INFORMATION',
    WheelchairBoarding.possible: 'POSSIBLE',
    WheelchairBoarding.notpossible: 'NOT_POSSIBLE',
  };
  String get name => names[this] ?? 'NO_INFORMATION';
}
