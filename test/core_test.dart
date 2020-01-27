import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core/core.dart';

void main() {
  const MethodChannel channel = MethodChannel('core');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await Core.platformVersion, '42');
  });
}
