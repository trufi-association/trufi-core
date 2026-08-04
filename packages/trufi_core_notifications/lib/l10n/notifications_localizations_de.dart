// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'notifications_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class NotificationsLocalizationsDe extends NotificationsLocalizations {
  NotificationsLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get notificationsTitle => 'Benachrichtigungen';

  @override
  String get markAllAsRead => 'Alle als gelesen markieren';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get notificationsDisabled => 'Benachrichtigungen deaktiviert';

  @override
  String get enableInSystemSettings =>
      'Aktiviere Benachrichtigungen in den Systemeinstellungen';

  @override
  String get allowNotifications =>
      'Erlaube Benachrichtigungen, um auf dem Laufenden zu bleiben';

  @override
  String get openSettings => 'Einstellungen';

  @override
  String get enable => 'Aktivieren';

  @override
  String get noNotifications => 'Keine Benachrichtigungen';

  @override
  String get allCaughtUp => 'Du bist auf dem Laufenden!';

  @override
  String get justNow => 'Gerade eben';

  @override
  String minutesAgo(int minutes) {
    return 'vor $minutes Min.';
  }

  @override
  String hoursAgo(int hours) {
    return 'vor $hours Std.';
  }

  @override
  String daysAgo(int days) {
    return 'vor $days Tagen';
  }

  @override
  String unreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ungelesen',
      one: '1 ungelesen',
    );
    return '$_temp0';
  }
}
