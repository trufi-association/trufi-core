import 'package:flutter_driver/flutter_driver.dart';

class Robot {
  Robot(this.driver, this.finder);

  final FlutterDriver driver;
  final SerializableFinder finder;

  sees(String valueKey) async {
    print("sees: $valueKey");
    await driver.waitFor(find.byValueKey(valueKey));
  }

  seesNot(String valueKey) async {
    print("sees not: $valueKey");
    await driver.waitForAbsent(find.byValueKey(valueKey));
  }
}
