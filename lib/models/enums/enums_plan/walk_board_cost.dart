part of 'enums_plan.dart';

enum WalkBoardCost { defaultCost, walkBoardCostHigh }

extension WalkBoardCostExtension on WalkBoardCost {
  static const values = <WalkBoardCost, int>{
    WalkBoardCost.defaultCost: 600,
    WalkBoardCost.walkBoardCostHigh: 1200,
  };
  int get value => values[this] ?? 600;
}
