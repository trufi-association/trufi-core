import 'package:package_info_plus/package_info_plus.dart';

/// Thin wrapper around `package_info_plus` that returns the app's
/// version and display name across mobile and web.
///
/// On web, `package_info_plus` reads the values bundled into
/// `version.json` at build time (`flutter build web`), so this
/// returns the same identifiers as on Android/iOS — the previous
/// implementation deliberately fell back to the browser user-agent
/// on web, which surfaced literal `Mozilla/5.0 …` strings in the
/// drawer footer in place of the app version.
class PackageInfoPlatform {
  PackageInfoPlatform();

  static Future<String> version() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  static Future<String> appName() async {
    final info = await PackageInfo.fromPlatform();
    return info.appName;
  }
}
