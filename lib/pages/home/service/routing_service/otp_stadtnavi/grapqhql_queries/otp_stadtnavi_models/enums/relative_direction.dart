import 'package:trufi_core/models/enums/relative_direction.dart';

enum RelativeDirection {
  depart,
  hardLeft,
  left,
  slightlyLeft,
  continue_,
  slightlyRight,
  right,
  hardRight,
  circleClockwise,
  circleCounterclockwise,
  elevator,
  uturnLeft,
  uturnRight,
  enterStation,
  exitStation,
  followSigns,
}

RelativeDirection getRelativeDirectionByString(String direction) {
  return RelativeDirectionExtension.names.keys.firstWhere(
    (key) => key.name == direction,
    orElse: () => RelativeDirection.continue_,
  );
}

extension RelativeDirectionExtension on RelativeDirection {
  static const names = <RelativeDirection, String>{
    RelativeDirection.depart: 'DEPART',
    RelativeDirection.hardLeft: 'HARD_LEFT',
    RelativeDirection.left: 'LEFT',
    RelativeDirection.slightlyLeft: 'SLIGHTLY_LEFT',
    RelativeDirection.continue_: 'CONTINUE',
    RelativeDirection.slightlyRight: 'SLIGHTLY_RIGHT',
    RelativeDirection.right: 'RIGHT',
    RelativeDirection.hardRight: 'HARD_RIGHT',
    RelativeDirection.circleClockwise: 'CIRCLE_CLOCKWISE',
    RelativeDirection.circleCounterclockwise: 'CIRCLE_COUNTERCLOCKWISE',
    RelativeDirection.elevator: 'ELEVATOR',
    RelativeDirection.uturnLeft: 'UTURN_LEFT',
    RelativeDirection.uturnRight: 'UTURN_RIGHT',
    RelativeDirection.enterStation: 'ENTER_STATION',
    RelativeDirection.exitStation: 'EXIT_STATION',
    RelativeDirection.followSigns: 'FOLLOW_SIGNS',
  };

  RelativeDirectionTrufi toRelativeDirection() {
    switch (this) {
      case RelativeDirection.depart:
        return RelativeDirectionTrufi.depart;
      case RelativeDirection.hardLeft:
        return RelativeDirectionTrufi.hardLeft;
      case RelativeDirection.left:
        return RelativeDirectionTrufi.left;
      case RelativeDirection.slightlyLeft:
        return RelativeDirectionTrufi.slightlyLeft;
      case RelativeDirection.continue_:
        return RelativeDirectionTrufi.continue_;
      case RelativeDirection.slightlyRight:
        return RelativeDirectionTrufi.slightlyRight;
      case RelativeDirection.right:
        return RelativeDirectionTrufi.right;
      case RelativeDirection.hardRight:
        return RelativeDirectionTrufi.hardRight;
      case RelativeDirection.circleClockwise:
        return RelativeDirectionTrufi.circleClockwise;
      case RelativeDirection.circleCounterclockwise:
        return RelativeDirectionTrufi.circleCounterclockwise;
      case RelativeDirection.elevator:
        return RelativeDirectionTrufi.elevator;
      case RelativeDirection.uturnLeft:
        return RelativeDirectionTrufi.uturnLeft;
      case RelativeDirection.uturnRight:
        return RelativeDirectionTrufi.uturnRight;
      case RelativeDirection.enterStation:
        return RelativeDirectionTrufi.enterStation;
      case RelativeDirection.exitStation:
        return RelativeDirectionTrufi.exitStation;
      case RelativeDirection.followSigns:
        return RelativeDirectionTrufi.followSigns;
    }
  }
}
