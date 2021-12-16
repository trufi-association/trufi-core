import 'package:flutter_driver/flutter_driver.dart';
import 'package:trufi_core/keys.dart' as keys;

import 'home_robot.dart';
import 'robot.dart';

class SearchRobot extends Robot {
  SearchRobot(FlutterDriver? driver, Future<void> work) : super(driver, work);

  SearchRobot seesBackButton() {
    work = work.then((_) async => seesTooltip(Robot.backButtonTooltip));
    return this;
  }

  SearchRobot seesSearchField() {
    work = work.then((_) async => seesText(keys.search));
    return this;
  }

  HomeRobot tapsOnBackButton() {
    work = work.then((_) async => tapsOnTooltip(Robot.backButtonTooltip));
    return HomeRobot(driver, work);
  }
}
