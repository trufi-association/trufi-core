part of 'enums_plan.dart';

enum OptimizeType { quick, safe, flat, greenWays, triangle, transfers }

extension OptimizeTypeExtension on OptimizeType {
  static const names = <OptimizeType, String>{
    OptimizeType.quick: 'QUICK',
    OptimizeType.safe: 'SAFE',
    OptimizeType.flat: 'FLAT',
    OptimizeType.greenWays: 'GREENWAYS',
    OptimizeType.triangle: 'TRIANGLE',
    OptimizeType.transfers: 'TRANSFERS',
  };
  static const values = <OptimizeType, Map<String, double>?>{
    OptimizeType.quick: null,
    OptimizeType.safe: null,
    OptimizeType.flat: null,
    OptimizeType.greenWays: null,
    OptimizeType.triangle: {
      'safetyFactor': 0.4,
      'slopeFactor': 0.3,
      'timeFactor': 0.3
    },
    OptimizeType.transfers: null,
  };

  String get name => names[this] ?? 'QUICK';
  Map<String, double>? get value => values[this];
}
