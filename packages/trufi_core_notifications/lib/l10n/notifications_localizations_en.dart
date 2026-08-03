// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'notifications_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class NotificationsLocalizationsEn extends NotificationsLocalizations {
  NotificationsLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get refresh => 'Refresh';

  @override
  String get notificationsDisabled => 'Notifications disabled';

  @override
  String get enableInSystemSettings =>
      'Enable notifications in system settings';

  @override
  String get allowNotifications => 'Allow notifications to stay updated';

  @override
  String get openSettings => 'Settings';

  @override
  String get enable => 'Enable';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get allCaughtUp => 'You\'re all caught up!';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String hoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String daysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String unreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread',
      one: '1 unread',
    );
    return '$_temp0';
  }
}
