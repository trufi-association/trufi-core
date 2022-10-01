// ignore: depend_on_referenced_packages
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart' show Hive;

abstract class TrufiAppId {
  static const String path = "TrufiAppId";

  static String _id = '';
  static final _box = Hive.box(path);
  static const String _trufiAppIdKey = "trufiAppIdKey";

  static Future<void> initialize() async {
    String? trufiId = _box.get(_trufiAppIdKey);
    if (trufiId == null) {
      _id = const Uuid().v4();
      _box.put(_trufiAppIdKey, _id);
    } else {
      _id = trufiId;
    }
  }

  static String get getUniqueId => _id;
}
