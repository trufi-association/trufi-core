import 'package:flutter_driver/flutter_driver.dart';

import 'package:trufi_app/location/location_search_keys.dart' as search_keys;

import 'robot.dart';
import 'home_robot.dart';

class SearchRobot extends Robot {
  SearchRobot(
    FlutterDriver driver,
    Future<void> work,
  ) : super(
          driver,
          find.byValueKey(search_keys.page),
          work,
        );

  SearchRobot seesSearchField() {
    work = work.then((_) async => await seesTooltip("Search"));
    return this;
  }

  SearchRobot seesBackButton() {
    work = work.then((_) async => await seesTooltip(Robot.backButtonTooltip));
    return this;
  }

  HomeRobot tapsOnBackButton() {
    work = work.then((_) async => await tapsOnTooltip(Robot.backButtonTooltip));
    return HomeRobot(driver, work);
  }
}
