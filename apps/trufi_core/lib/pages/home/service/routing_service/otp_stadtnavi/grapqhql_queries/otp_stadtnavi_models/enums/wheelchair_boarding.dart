enum WheelchairBoarding { noinformation, possible, notpossible }

WheelchairBoarding getWheelchairBoardingByString(String wheelchairBoarding) {
  return WheelchairBoardingExtension.names.keys.firstWhere(
    (key) => key.name == wheelchairBoarding,
    orElse: () => WheelchairBoarding.noinformation,
  );
}

extension WheelchairBoardingExtension on WheelchairBoarding {
  static const names = <WheelchairBoarding, String>{
    WheelchairBoarding.noinformation: 'NO_INFORMATION',
    WheelchairBoarding.possible: 'POSSIBLE',
    WheelchairBoarding.notpossible: 'NOT_POSSIBLE'
  };
  String get name => names[this] ?? 'NO_INFORMATION';
}
