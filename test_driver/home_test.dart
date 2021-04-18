import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_test/flutter_test.dart';

import 'robots/home_robot.dart';

void main() {
  group('home test', () {
    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('home', () async {
      final HomeRobot robot = HomeRobot(driver, Future.value());
      await robot
          .seesFromPlacesField()
          .seesToPlacesField()
          .seesNotSwapButton()
          .tapsOnFromPlacesField()
          .seesSearchField()
          .seesBackButton()
          .tapsOnBackButton()
          .seesFromPlacesField()
          .work;
    });
  });
}
