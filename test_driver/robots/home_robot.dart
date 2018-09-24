import 'package:flutter_driver/flutter_driver.dart';

import 'package:trufi_app/pages/home_keys.dart' as home_keys;

import 'robot.dart';
import 'search_robot.dart';

class HomeRobot extends Robot {
  HomeRobot(
    FlutterDriver driver,
    Future<void> work,
  ) : super(
          driver,
          find.byValueKey(home_keys.page),
          work,
        );

  HomeRobot seesFromPlacesField() {
    work = work.then((_) => seesKey(home_keys.fromPlaceField));
    return this;
  }

  HomeRobot seesToPlacesField() {
    work = work.then((_) => seesKey(home_keys.toPlaceField));
    return this;
  }

  HomeRobot seesNotSwapButton() {
    work = work.then((_) => seesNotKey(home_keys.swapButton));
    return this;
  }

  HomeRobot seesSwapButton() {
    work = work.then((_) => seesKey(home_keys.swapButton));
    return this;
  }

  SearchRobot tapsOnFromPlacesField() {
    work = work.then((_) async => await tapsOnKey(home_keys.fromPlaceField));
    return SearchRobot(driver, work);
  }
}
