import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

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
      driver = await FlutterDriver.connect();
      HomeRobot r = HomeRobot(driver);
      r = await (await (await r.seesFromPlacesField()).seesToPlacesField())
          .seesNotSwapButton();
//      await r.seesFromPlacesField().then((r) async {
//        await r.seesToPlacesField().then((r) async {
//          await r.seesNotSwapButton();
//        });
//      });
    });
  });
}
