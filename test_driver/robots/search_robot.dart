import 'package:flutter_driver/flutter_driver.dart';

import 'package:trufi_app/location/location_search_keys.dart' as search_keys;

import 'robot.dart';

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
}
