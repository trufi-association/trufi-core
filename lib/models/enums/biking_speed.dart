part of 'plan_enums.dart';

enum BikingSpeed { slow, calm, average, prompt, fast }

BikingSpeed getBikingSpeed(String key) {
  return BikingSpeedExtension.names.keys.firstWhere(
    (keyE) => keyE.name == key,
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
  static const names = <BikingSpeed, String>{
    BikingSpeed.slow: '10 Km/h',
    BikingSpeed.calm: '15 Km/h',
    BikingSpeed.average: '20 Km/h',
    BikingSpeed.prompt: '25 Km/h',
    BikingSpeed.fast: '30 Km/h',
  };
  double get value => values[this] ?? 5.55;
  String get name => names[this] ?? "10 Km/h";
}
