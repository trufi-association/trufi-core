import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class PackageInfoPlatform {
  PackageInfoPlatform();

  static Future<String> version() async {
    if (!kIsWeb) {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } else {
      WebBrowserInfo webBrowserInfo = await DeviceInfoPlugin().webBrowserInfo;
      return webBrowserInfo.userAgent??'webPlatform';
    }
  }
}
