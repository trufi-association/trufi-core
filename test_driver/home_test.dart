import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

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
      HomeRobot().seesMyLocationFab();
    });
  });
}

class HomeRobot {
  HomeRobot seesMyLocationFab() {
    return this;
  }
}
