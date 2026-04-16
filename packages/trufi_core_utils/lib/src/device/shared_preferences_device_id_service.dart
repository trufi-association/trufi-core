import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

/// SharedPreferences implementation of [DeviceIdService].
///
/// Generates a UUID v4 on first call, persists it under the
/// `trufi.device_id` key, caches it in memory for subsequent calls within the
/// same instance, and returns the same value for the lifetime of the install.
class SharedPreferencesDeviceIdService implements DeviceIdService {
  SharedPreferencesDeviceIdService();

  static const String _prefsKey = 'trufi.device_id';

  String? _cached;
  Future<String>? _pending;

  @override
  Future<String> getDeviceId() {
    if (_cached != null) return Future.value(_cached);
    return _pending ??= _load();
  }

  Future<String> _load() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_prefsKey);
    if (id == null || id.isEmpty) {
      id = _generateUuidV4();
      await prefs.setString(_prefsKey, id);
    }
    _cached = id;
    _pending = null;
    return id;
  }

  static String _generateUuidV4() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    String hex(int b) => b.toRadixString(16).padLeft(2, '0');
    final h = bytes.map(hex).toList();
    return '${h[0]}${h[1]}${h[2]}${h[3]}-'
        '${h[4]}${h[5]}-'
        '${h[6]}${h[7]}-'
        '${h[8]}${h[9]}-'
        '${h[10]}${h[11]}${h[12]}${h[13]}${h[14]}${h[15]}';
  }
}
