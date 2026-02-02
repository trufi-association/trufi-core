/// JSON parsing utilities for cross-platform compatibility.
///
/// In Dart web (compiled to JavaScript), all numbers are represented as
/// IEEE 754 doubles. This causes `json['field'] as int` to fail when the
/// runtime type is double, even if the value is a whole number like 2282.0.
///
/// These extensions provide safe type conversions that work on both
/// native and web platforms.
///
/// See: https://dart.dev/resources/language/number-representation
/// See: https://github.com/dart-lang/sdk/issues/46883

/// Extension on Map<String, dynamic> for safe JSON value extraction.
extension JsonMapExtension on Map<String, dynamic> {
  /// Gets an int value, handling both int and double representations.
  /// Returns null if the key doesn't exist or value is null.
  int? getInt(String key) {
    final value = this[key];
    if (value == null) return null;
    try {
      return (value as num).toInt();
    } catch (e) {
      print('[JsonUtils] getInt error for key "$key": value=$value (${value.runtimeType}), error=$e');
      rethrow;
    }
  }

  /// Gets a double value, handling both int and double representations.
  /// Returns null if the key doesn't exist or value is null.
  double? getDouble(String key) {
    final value = this[key];
    if (value == null) return null;
    try {
      return (value as num).toDouble();
    } catch (e) {
      print('[JsonUtils] getDouble error for key "$key": value=$value (${value.runtimeType}), error=$e');
      rethrow;
    }
  }

  /// Gets an int value with a default, handling both int and double.
  int getIntOr(String key, int defaultValue) {
    final value = this[key];
    if (value == null) return defaultValue;
    try {
      return (value as num).toInt();
    } catch (e) {
      print('[JsonUtils] getIntOr error for key "$key": value=$value (${value.runtimeType}), error=$e');
      rethrow;
    }
  }

  /// Gets a double value with a default, handling both int and double.
  double getDoubleOr(String key, double defaultValue) {
    final value = this[key];
    if (value == null) return defaultValue;
    try {
      return (value as num).toDouble();
    } catch (e) {
      print('[JsonUtils] getDoubleOr error for key "$key": value=$value (${value.runtimeType}), error=$e');
      rethrow;
    }
  }

  /// Gets a DateTime from milliseconds since epoch.
  /// Returns null if the key doesn't exist or value is null.
  DateTime? getDateTime(String key) {
    final value = this[key];
    if (value == null) return null;
    try {
      final millis = (value as num).toInt();
      return DateTime.fromMillisecondsSinceEpoch(millis);
    } catch (e) {
      print('[JsonUtils] getDateTime error for key "$key": value=$value (${value.runtimeType}), error=$e');
      rethrow;
    }
  }

  /// Gets a DateTime from milliseconds since epoch, with a default.
  DateTime getDateTimeOr(String key, DateTime defaultValue) {
    final value = this[key];
    if (value == null) return defaultValue;
    try {
      final millis = (value as num).toInt();
      return DateTime.fromMillisecondsSinceEpoch(millis);
    } catch (e) {
      print('[JsonUtils] getDateTimeOr error for key "$key": value=$value (${value.runtimeType}), error=$e');
      rethrow;
    }
  }

  /// Gets a Duration from seconds.
  /// Returns null if the key doesn't exist or value is null.
  Duration? getDuration(String key) {
    final value = this[key];
    if (value == null) return null;
    try {
      final seconds = (value as num).toInt();
      return Duration(seconds: seconds);
    } catch (e) {
      print('[JsonUtils] getDuration error for key "$key": value=$value (${value.runtimeType}), error=$e');
      rethrow;
    }
  }

  /// Gets a Duration from seconds, with a default.
  Duration getDurationOr(String key, [Duration defaultValue = Duration.zero]) {
    final value = this[key];
    if (value == null) return defaultValue;
    try {
      final seconds = (value as num).toInt();
      return Duration(seconds: seconds);
    } catch (e) {
      print('[JsonUtils] getDurationOr error for key "$key": value=$value (${value.runtimeType}), error=$e');
      rethrow;
    }
  }
}
