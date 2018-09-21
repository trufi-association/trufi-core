import 'package:flutter_driver/flutter_driver.dart';

import 'package:trufi_app/pages/home_keys.dart' as home_keys;

import 'robot.dart';

class HomeRobot extends Robot {
  HomeRobot(FlutterDriver driver)
      : super(driver, find.byValueKey(home_keys.page));

  Future<HomeRobot> seesFromPlacesField() async {
    await sees(home_keys.fromPlaceField);
    return this;
  }

  Future<HomeRobot> seesToPlacesField() async {
    await sees(home_keys.toPlaceField);
    return this;
  }

  Future<HomeRobot> seesNotSwapButton() async {
    await seesNot(home_keys.swapButton);
    return this;
  }

  Future<HomeRobot> seesSwapButton() async {
    await sees(home_keys.swapButton);
    return this;
  }
}
