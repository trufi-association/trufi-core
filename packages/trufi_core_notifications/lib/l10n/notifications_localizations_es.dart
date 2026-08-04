// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'notifications_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class NotificationsLocalizationsEs extends NotificationsLocalizations {
  NotificationsLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get markAllAsRead => 'Marcar todo como leído';

  @override
  String get refresh => 'Actualizar';

  @override
  String get notificationsDisabled => 'Notificaciones desactivadas';

  @override
  String get enableInSystemSettings =>
      'Activa las notificaciones en los ajustes del sistema';

  @override
  String get allowNotifications =>
      'Permite las notificaciones para estar al día';

  @override
  String get openSettings => 'Ajustes';

  @override
  String get enable => 'Activar';

  @override
  String get noNotifications => 'Sin notificaciones';

  @override
  String get allCaughtUp => '¡Estás al día!';

  @override
  String get justNow => 'Ahora mismo';

  @override
  String minutesAgo(int minutes) {
    return 'hace $minutes min';
  }

  @override
  String hoursAgo(int hours) {
    return 'hace $hours h';
  }

  @override
  String daysAgo(int days) {
    return 'hace $days días';
  }

  @override
  String unreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sin leer',
      one: '1 sin leer',
    );
    return '$_temp0';
  }
}
