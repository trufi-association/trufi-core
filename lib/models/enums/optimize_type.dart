part of 'plan_enums.dart';

enum OptimizeType { quick, safe, flat, greenWays, triangle, transfers }

extension OptimizeTypeExtension on OptimizeType {
  static const values = <OptimizeType, String>{
    OptimizeType.quick: 'QUICK',
    OptimizeType.safe: 'SAFE',
    OptimizeType.flat: 'FLAT',
    OptimizeType.greenWays: 'GREENWAYS',
    OptimizeType.triangle: 'TRIANGLE',
    OptimizeType.transfers: 'TRANSFERS',
  };
  String get name => values[this] ?? 'QUICK';
}
