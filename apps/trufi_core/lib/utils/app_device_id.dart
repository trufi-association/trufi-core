import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AppDeviceId {
  static const String _trufiAppIdKey = "trufiAppIdKey";
  static String _id = '';

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    String? trufiId = prefs.getString(_trufiAppIdKey);
    if (trufiId == null) {
      _id = const Uuid().v4();
      await prefs.setString(_trufiAppIdKey, _id);
    } else {
      _id = trufiId;
    }
  }

  static String get getUniqueId => _id;
}
