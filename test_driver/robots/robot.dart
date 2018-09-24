import 'package:flutter_driver/flutter_driver.dart';

class Robot {
  static final String backButtonTooltip = "Back";

  Robot(this.driver, this.work);

  final FlutterDriver driver;

  Future<void> work;

  seesKey(String key) async {
    print("sees key: $key");
    await driver.waitFor(find.byValueKey(key));
  }

  seesText(String text) async {
    print("sees text: $text");
    await driver.waitFor(find.text(text));
  }

  seesTooltip(String tooltip) async {
    print("sees tooltip: $tooltip");
    await driver.waitFor(find.byTooltip(tooltip));
  }

  seesNotKey(String key) async {
    print("sees not key: $key");
    await driver.waitForAbsent(find.byValueKey(key));
  }

  seesNotText(String text) async {
    print("sees not text: $text");
    await driver.waitForAbsent(find.text(text));
  }

  seesNotTooltip(String tooltip) async {
    print("sees not tooltip: $tooltip");
    await driver.waitForAbsent(find.byTooltip(tooltip));
  }

  tapsOnKey(String key) async {
    print("taps on key: $key");
    await driver.tap(find.byValueKey(key));
  }

  tapsOnText(String text) async {
    print("taps on text: $text");
    await driver.tap(find.text(text));
  }

  tapsOnTooltip(String tooltip) async {
    print("taps on tooltip: $tooltip");
    await driver.tap(find.byTooltip(tooltip));
  }
}
