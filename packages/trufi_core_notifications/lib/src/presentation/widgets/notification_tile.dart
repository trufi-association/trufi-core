import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/notification.dart';

/// A tile displaying a single notification
class NotificationTile extends StatelessWidget {
  /// The notification to display
  final TrufiNotification notification;

  /// Callback when the tile is tapped
  final VoidCallback? onTap;

  /// Callback when the tile is dismissed (swipe to delete)
  final VoidCallback? onDismiss;

  /// Callback when marked as read
  final VoidCallback? onMarkAsRead;

  /// Whether to show the dismiss action
  final bool showDismiss;

  /// Whether to show the time ago
  final bool showTimeAgo;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
    this.onMarkAsRead,
    this.showDismiss = true,
    this.showTimeAgo = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget tile = Material(
      color: notification.isRead
          ? Colors.transparent
          : colorScheme.primaryContainer.withAlpha(30),
      child: InkWell(
        onTap: onTap != null
            ? () {
                HapticFeedback.selectionClick();
                onTap!();
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unread indicator
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6, right: 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: notification.isRead
                      ? Colors.transparent
                      : colorScheme.primary,
                ),
              ),
              // Priority icon
              _buildPriorityIcon(colorScheme),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      notification.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Body
                    Text(
                      notification.body,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (showTimeAgo) ...[
                      const SizedBox(height: 6),
                      // Time
                      Text(
                        _formatTimeAgo(notification.createdAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withAlpha(180),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Image if present
              if (notification.imageUrl != null) ...[
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    notification.imageUrl!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    // Wrap with Dismissible if onDismiss is provided
    if (showDismiss && onDismiss != null) {
      tile = Dismissible(
        key: Key(notification.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDismiss!(),
        background: Container(
          color: colorScheme.error,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          child: Icon(
            Icons.delete_outline,
            color: colorScheme.onError,
          ),
        ),
        child: tile,
      );
    }

    return tile;
  }

  Widget _buildPriorityIcon(ColorScheme colorScheme) {
    IconData icon;
    Color color;

    switch (notification.priority) {
      case NotificationPriority.urgent:
        icon = Icons.priority_high_rounded;
        color = colorScheme.error;
      case NotificationPriority.high:
        icon = Icons.notifications_active_rounded;
        color = colorScheme.tertiary;
      case NotificationPriority.low:
        icon = Icons.notifications_paused_rounded;
        color = colorScheme.outline;
      case NotificationPriority.normal:
        icon = Icons.notifications_rounded;
        color = colorScheme.primary;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
