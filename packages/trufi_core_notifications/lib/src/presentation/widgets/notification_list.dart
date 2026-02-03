import 'package:flutter/material.dart';

import '../../managers/notification_manager.dart';
import '../../models/notification.dart';
import 'notification_tile.dart';

/// A list view displaying notifications with pull-to-refresh and pagination
class NotificationList extends StatelessWidget {
  /// Callback when a notification is tapped
  final void Function(TrufiNotification notification)? onNotificationTap;

  /// Callback when action button is tapped (e.g., deep link)
  final void Function(TrufiNotification notification, NotificationAction action)?
      onActionTap;

  /// Widget to show when there are no notifications
  final Widget? emptyWidget;

  /// Whether to show the "Mark all as read" button
  final bool showMarkAllAsRead;

  /// ScrollController for external control
  final ScrollController? scrollController;

  /// Padding around the list
  final EdgeInsets padding;

  const NotificationList({
    super.key,
    this.onNotificationTap,
    this.onActionTap,
    this.emptyWidget,
    this.showMarkAllAsRead = true,
    this.scrollController,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final manager = NotificationManager.watch(context);
    final notifications = manager.notifications;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (notifications.isEmpty && !manager.isLoading) {
      return emptyWidget ??
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 64,
                  color: colorScheme.onSurfaceVariant.withAlpha(100),
                ),
                const SizedBox(height: 16),
                Text(
                  'No notifications',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'re all caught up!',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withAlpha(180),
                  ),
                ),
              ],
            ),
          );
    }

    return RefreshIndicator(
      onRefresh: manager.refresh,
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Header with mark all as read
          if (showMarkAllAsRead && manager.unreadCount > 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                child: Row(
                  children: [
                    Text(
                      '${manager.unreadCount} unread',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: manager.markAllAsRead,
                      child: const Text('Mark all as read'),
                    ),
                  ],
                ),
              ),
            ),

          // Notification list
          SliverPadding(
            padding: padding,
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == notifications.length) {
                    // Load more indicator
                    if (manager.hasMore) {
                      // Trigger load more
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        manager.loadMore();
                      });
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }
                    return null;
                  }

                  final notification = notifications[index];
                  return Column(
                    children: [
                      NotificationTile(
                        notification: notification,
                        onTap: () {
                          // Mark as read on tap
                          if (!notification.isRead) {
                            manager.markAsRead(notification.id);
                          }
                          onNotificationTap?.call(notification);
                        },
                        onDismiss: () {
                          manager.deleteNotification(notification.id);
                        },
                      ),
                      if (index < notifications.length - 1)
                        Divider(
                          height: 1,
                          indent: 76,
                          color: colorScheme.outlineVariant.withAlpha(100),
                        ),
                    ],
                  );
                },
                childCount: notifications.length + (manager.hasMore ? 1 : 0),
              ),
            ),
          ),

          // Loading indicator for initial load
          if (manager.isLoading && notifications.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
