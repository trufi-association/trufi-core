import 'package:flutter/foundation.dart';

/// Permission status for notifications
enum NotificationPermissionStatus {
  /// Permission has not been requested yet
  notDetermined,

  /// Permission was denied by the user
  denied,

  /// Permission was denied permanently (user needs to go to settings)
  permanentlyDenied,

  /// Permission was granted
  granted,
}

/// User settings for notifications
@immutable
class NotificationSettings {
  /// Whether notifications are enabled globally
  final bool enabled;

  /// Whether to show in-app notifications
  final bool showInApp;

  /// Whether to play sounds
  final bool soundEnabled;

  /// Whether to vibrate
  final bool vibrationEnabled;

  /// Categories that are enabled (null = all enabled)
  final Set<String>? enabledCategories;

  /// Time of day to start quiet hours (null = no quiet hours)
  final Duration? quietHoursStart;

  /// Time of day to end quiet hours
  final Duration? quietHoursEnd;

  const NotificationSettings({
    this.enabled = true,
    this.showInApp = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.enabledCategories,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  /// Default settings
  static const NotificationSettings defaults = NotificationSettings();

  /// Check if a category is enabled
  bool isCategoryEnabled(String category) {
    if (enabledCategories == null) return true;
    return enabledCategories!.contains(category);
  }

  /// Check if currently in quiet hours
  bool get isQuietHours {
    if (quietHoursStart == null || quietHoursEnd == null) return false;

    final now = DateTime.now();
    final currentTime = Duration(hours: now.hour, minutes: now.minute);

    if (quietHoursStart! < quietHoursEnd!) {
      // Same day range (e.g., 22:00 - 23:00)
      return currentTime >= quietHoursStart! && currentTime < quietHoursEnd!;
    } else {
      // Overnight range (e.g., 22:00 - 07:00)
      return currentTime >= quietHoursStart! || currentTime < quietHoursEnd!;
    }
  }

  NotificationSettings copyWith({
    bool? enabled,
    bool? showInApp,
    bool? soundEnabled,
    bool? vibrationEnabled,
    Set<String>? enabledCategories,
    Duration? quietHoursStart,
    Duration? quietHoursEnd,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      showInApp: showInApp ?? this.showInApp,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      enabledCategories: enabledCategories ?? this.enabledCategories,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enabled: json['enabled'] as bool? ?? true,
      showInApp: json['showInApp'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      enabledCategories: (json['enabledCategories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toSet(),
      quietHoursStart: json['quietHoursStart'] != null
          ? Duration(minutes: json['quietHoursStart'] as int)
          : null,
      quietHoursEnd: json['quietHoursEnd'] != null
          ? Duration(minutes: json['quietHoursEnd'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'showInApp': showInApp,
        'soundEnabled': soundEnabled,
        'vibrationEnabled': vibrationEnabled,
        if (enabledCategories != null)
          'enabledCategories': enabledCategories!.toList(),
        if (quietHoursStart != null)
          'quietHoursStart': quietHoursStart!.inMinutes,
        if (quietHoursEnd != null) 'quietHoursEnd': quietHoursEnd!.inMinutes,
      };
}
