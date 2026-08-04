import 'package:flutter/material.dart';

import '../../managers/notification_manager.dart';
import '../../models/notification.dart';
import '../../models/notification_settings.dart';
import '../widgets/notification_list.dart';

import '../../../l10n/notifications_localizations.dart';

/// Full-screen view for notifications
class NotificationsScreen extends StatelessWidget {
  /// Callback when a notification is tapped
  final void Function(TrufiNotification notification)? onNotificationTap;

  /// Title for the app bar
  /// Screen title; defaults to the localized "Notifications".
  final String? title;

  /// Whether to show the settings button
  final bool showSettings;

  /// Callback when settings button is tapped
  final VoidCallback? onSettingsTap;

  const NotificationsScreen({
    super.key,
    this.onNotificationTap,
    this.title,
    this.showSettings = false,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final manager = NotificationManager.watch(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title ?? NotificationsLocalizations.of(context).notificationsTitle,
        ),
        actions: [
          if (showSettings)
            IconButton(
              onPressed: onSettingsTap,
              icon: const Icon(Icons.settings_outlined),
            ),
          if (manager.unreadCount > 0)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'mark_all_read':
                    manager.markAllAsRead();
                    break;
                  case 'refresh':
                    manager.refresh();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'mark_all_read',
                  child: Row(
                    children: [
                      const Icon(Icons.done_all),
                      const SizedBox(width: 12),
                      Text(
                        NotificationsLocalizations.of(context).markAllAsRead,
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'refresh',
                  child: Row(
                    children: [
                      const Icon(Icons.refresh),
                      const SizedBox(width: 12),
                      Text(NotificationsLocalizations.of(context).refresh),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Permission warning if not granted
          if (manager.permissionStatus == NotificationPermissionStatus.denied ||
              manager.permissionStatus ==
                  NotificationPermissionStatus.permanentlyDenied)
            _buildPermissionWarning(context, manager),

          // Notification list
          Expanded(
            child: NotificationList(
              onNotificationTap: onNotificationTap,
              showMarkAllAsRead: false, // Already in app bar
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionWarning(
    BuildContext context,
    NotificationManager manager,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPermanent =
        manager.permissionStatus ==
        NotificationPermissionStatus.permanentlyDenied;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_off_rounded,
            color: colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  NotificationsLocalizations.of(context).notificationsDisabled,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onErrorContainer,
                  ),
                ),
                Text(
                  isPermanent
                      ? NotificationsLocalizations.of(
                          context,
                        ).enableInSystemSettings
                      : NotificationsLocalizations.of(
                          context,
                        ).allowNotifications,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onErrorContainer.withAlpha(200),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Platform-specific permission request handled by the app
            },
            child: Text(
              isPermanent
                  ? NotificationsLocalizations.of(context).openSettings
                  : NotificationsLocalizations.of(context).enable,
            ),
          ),
        ],
      ),
    );
  }
}
