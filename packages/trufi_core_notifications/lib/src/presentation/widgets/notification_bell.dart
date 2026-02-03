import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../managers/notification_manager.dart';

/// A bell icon button with notification badge
class NotificationBell extends StatelessWidget {
  /// Callback when the bell is tapped
  final VoidCallback? onTap;

  /// Icon size
  final double iconSize;

  /// Badge background color (defaults to error color)
  final Color? badgeColor;

  /// Whether to show the badge even when count is 0
  final bool alwaysShowBadge;

  /// Maximum count to display (shows "99+" if exceeded)
  final int maxCount;

  const NotificationBell({
    super.key,
    this.onTap,
    this.iconSize = 24,
    this.badgeColor,
    this.alwaysShowBadge = false,
    this.maxCount = 99,
  });

  @override
  Widget build(BuildContext context) {
    final manager = NotificationManager.maybeWatch(context);
    final unreadCount = manager?.unreadCount ?? 0;
    final colorScheme = Theme.of(context).colorScheme;

    final showBadge = alwaysShowBadge || unreadCount > 0;
    final displayCount =
        unreadCount > maxCount ? '$maxCount+' : unreadCount.toString();

    return IconButton(
      onPressed: onTap != null
          ? () {
              HapticFeedback.lightImpact();
              onTap!();
            }
          : null,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            unreadCount > 0
                ? Icons.notifications_rounded
                : Icons.notifications_outlined,
            size: iconSize,
          ),
          if (showBadge && unreadCount > 0)
            Positioned(
              right: -6,
              top: -4,
              child: _NotificationBadge(
                count: displayCount,
                color: badgeColor ?? colorScheme.error,
                textColor: colorScheme.onError,
              ),
            ),
        ],
      ),
    );
  }
}

/// Badge showing notification count
class _NotificationBadge extends StatelessWidget {
  final String count;
  final Color color;
  final Color textColor;

  const _NotificationBadge({
    required this.count,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = count.length == 1;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 0 : 4,
        vertical: 0,
      ),
      constraints: BoxConstraints(
        minWidth: isSmall ? 16 : 18,
        minHeight: 16,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(100),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          count,
          style: TextStyle(
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
