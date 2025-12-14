import 'package:hive_flutter/hive_flutter.dart';

/// Static initializer for Hive storage.
///
/// Ensures Hive is initialized only once across the entire application,
/// regardless of how many repositories or modules try to initialize it.
///
/// Usage:
/// ```dart
/// await TrufiHive.ensureInitialized();
/// ```
abstract class TrufiHive {
  static bool _initialized = false;

  /// Ensures Hive is initialized.
  ///
  /// Safe to call multiple times - will only initialize once.
  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _initialized = true;
  }

  /// Returns true if Hive has been initialized.
  static bool get isInitialized => _initialized;
}
