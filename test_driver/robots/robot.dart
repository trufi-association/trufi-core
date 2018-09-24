import 'package:flutter_driver/flutter_driver.dart';

class Robot {
  Robot(this.driver, this.finder, this.work);

  final FlutterDriver driver;
  final SerializableFinder finder;

  Future<void> work;

  seesKey(String key) async {
    print("sees: $key");
    await driver.waitFor(find.byValueKey(key));
  }

  seesNotKey(String key) async {
    print("sees not: $key");
    await driver.waitForAbsent(find.byValueKey(key));
  }

  seesTooltip(String tooltip) async {
    print("sees: $tooltip");
    await driver.waitFor(find.byTooltip(tooltip));
  }

  seesNotTooltip(String tooltip) async {
    print("sees not: $tooltip");
    await driver.waitForAbsent(find.byTooltip(tooltip));
  }

  tapsOnKey(String key) async {
    print("taps on: $key");
    await driver.tap(find.byValueKey(key));
  }
}
