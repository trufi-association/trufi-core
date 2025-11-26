enum RelativeDirectionTrufi {
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

RelativeDirectionTrufi getRelativeDirectionByString(String direction) {
  return RelativeDirectionExtension.names.keys.firstWhere(
    (key) => key.name == direction,
    orElse: () => RelativeDirectionTrufi.continue_,
  );
}

extension RelativeDirectionExtension on RelativeDirectionTrufi {
  static const names = <RelativeDirectionTrufi, String>{
    RelativeDirectionTrufi.depart: 'DEPART',
    RelativeDirectionTrufi.hardLeft: 'HARD_LEFT',
    RelativeDirectionTrufi.left: 'LEFT',
    RelativeDirectionTrufi.slightlyLeft: 'SLIGHTLY_LEFT',
    RelativeDirectionTrufi.continue_: 'CONTINUE',
    RelativeDirectionTrufi.slightlyRight: 'SLIGHTLY_RIGHT',
    RelativeDirectionTrufi.right: 'RIGHT',
    RelativeDirectionTrufi.hardRight: 'HARD_RIGHT',
    RelativeDirectionTrufi.circleClockwise: 'CIRCLE_CLOCKWISE',
    RelativeDirectionTrufi.circleCounterclockwise: 'CIRCLE_COUNTERCLOCKWISE',
    RelativeDirectionTrufi.elevator: 'ELEVATOR',
    RelativeDirectionTrufi.uturnLeft: 'UTURN_LEFT',
    RelativeDirectionTrufi.uturnRight: 'UTURN_RIGHT',
    RelativeDirectionTrufi.enterStation: 'ENTER_STATION',
    RelativeDirectionTrufi.exitStation: 'EXIT_STATION',
    RelativeDirectionTrufi.followSigns: 'FOLLOW_SIGNS',
  };

  String get name => names[this] ?? 'CONTINUE';
}
