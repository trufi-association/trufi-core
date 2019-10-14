import 'dart:async';

import 'package:flutter/services.dart';

class Core {
  static const MethodChannel _channel =
      const MethodChannel('core');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
