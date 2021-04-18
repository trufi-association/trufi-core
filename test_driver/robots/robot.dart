import 'package:flutter_driver/flutter_driver.dart';

class Robot {
  static const String backButtonTooltip = "Back";

  Robot(this.driver, this.work);

  final FlutterDriver driver;

  Future<void> work;

  Future<void> seesKey(String key) async {
    await driver.waitFor(find.byValueKey(key));
  }

  Future<void> seesText(String text) async {
    await driver.waitFor(find.text(text));
  }

  Future<void> seesTooltip(String tooltip) async {
    await driver.waitFor(find.byTooltip(tooltip));
  }

  Future<void> seesNotKey(String key) async {
    await driver.waitForAbsent(find.byValueKey(key));
  }

  Future<void> seesNotText(String text) async {
    await driver.waitForAbsent(find.text(text));
  }

  Future<void> seesNotTooltip(String tooltip) async {
    await driver.waitForAbsent(find.byTooltip(tooltip));
  }

  Future<void> tapsOnKey(String key) async {
    await driver.tap(find.byValueKey(key));
  }

  Future<void> tapsOnText(String text) async {
    await driver.tap(find.text(text));
  }

  Future<void> tapsOnTooltip(String tooltip) async {
    await driver.tap(find.byTooltip(tooltip));
  }
}
