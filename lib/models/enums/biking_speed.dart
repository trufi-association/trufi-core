part of 'plan_enums.dart';

enum BikingSpeed { slow, calm, average, prompt, fast }

BikingSpeed getBikingSpeed(double key) {
  return BikingSpeedExtension.values.keys.firstWhere(
    (keyE) => keyE.value == key,
    orElse: () => BikingSpeed.average,
  );
}

extension BikingSpeedExtension on BikingSpeed {
  static const values = <BikingSpeed, double>{
    BikingSpeed.slow: 2.77,
    BikingSpeed.calm: 4.15,
    BikingSpeed.average: 5.55,
    BikingSpeed.prompt: 6.94,
    BikingSpeed.fast: 8.33,
  };

  double get value => values[this] ?? 5.55;

  String translateValue (TrufiLocalization localization){
    // TODO translate
    switch (this) {
      case BikingSpeed.slow:
        return '10 Km/h';
        break;
      case BikingSpeed.calm:
        return '15 Km/h';
        break;
      case BikingSpeed.average:
        return '20 Km/h';
        break;
      case BikingSpeed.prompt:
        return '25 Km/h';
        break;
      case BikingSpeed.fast:
        return '30 Km/h';
        break;
      default:
        return 'not translate';
    }
  }
}
