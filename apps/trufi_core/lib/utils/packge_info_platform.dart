import 'package:package_info_plus/package_info_plus.dart';
import 'package:trufi_core/utils/app_device_id.dart';

abstract class PackageInfoPlatform {
  static Future<String> version() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  static Future<String> appName() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.appName;
  }

  static Future<String> getUserAgent() async =>
      "${appName()}/${version()}/${AppDeviceId.getUniqueId}";
}
