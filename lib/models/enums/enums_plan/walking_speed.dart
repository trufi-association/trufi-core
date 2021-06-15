part of 'enums_plan.dart';

enum WalkingSpeed { slow, average, fast }

WalkingSpeed getWalkingSpeed(String key) {
  return WalkingSpeedExtension.names.keys.firstWhere(
    (keyE) => keyE.name == key,
    orElse: () => WalkingSpeed.average,
  );
}

extension WalkingSpeedExtension on WalkingSpeed {
  static const values = <WalkingSpeed, double>{
    WalkingSpeed.slow: 0.83,
    WalkingSpeed.average: 1.38,
    WalkingSpeed.fast: 1.94444,
  };
  static const names = <WalkingSpeed, String>{
    WalkingSpeed.slow: 'slow',
    WalkingSpeed.average: 'average',
    WalkingSpeed.fast: 'fast',
  };

  static const speeds = <WalkingSpeed, String>{
    WalkingSpeed.slow: '3 km/h',
    WalkingSpeed.average: '5 km/h',
    WalkingSpeed.fast: '7 km/h',
  };

  String get name => names[this];
  String get speed => speeds[this] ?? 'noSpeed';
  double get value => values[this] ?? 1.2;

  String translateValue(TrufiLocalization localization) {
    switch (this) {
      case WalkingSpeed.slow:
        return localization.typeSpeedSlow;
        break;
      case WalkingSpeed.average:
        return localization.typeSpeedAverage;
        break;
      case WalkingSpeed.fast:
        return localization.typeSpeedFast;
        break;
      default:
        return localization.commonError;
    }
  }
}
