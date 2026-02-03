import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/notification.dart';

/// In-app notification banner for displaying notifications as overlays
class NotificationBanner extends StatelessWidget {
  /// The notification to display
  final TrufiNotification notification;

  /// Callback when the banner is tapped
  final VoidCallback? onTap;

  /// Callback when the banner is dismissed
  final VoidCallback? onDismiss;

  /// Duration to show the banner (null = don't auto-dismiss)
  final Duration? autoDismissDuration;

  const NotificationBanner({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
    this.autoDismissDuration = const Duration(seconds: 4),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Auto-dismiss logic is handled externally via overlay manager

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onTap?.call();
            },
            onVerticalDragEnd: (details) {
              // Swipe up to dismiss
              if (details.velocity.pixelsPerSecond.dy < -100) {
                onDismiss?.call();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(30),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: colorScheme.outlineVariant.withAlpha(50),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Priority indicator bar
                    _buildPriorityBar(colorScheme),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Icon
                          _buildIcon(colorScheme),
                          const SizedBox(width: 12),
                          // Text content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  notification.title,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  notification.body,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Close button
                          IconButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              onDismiss?.call();
                            },
                            icon: Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBar(ColorScheme colorScheme) {
    Color color;
    switch (notification.priority) {
      case NotificationPriority.urgent:
        color = colorScheme.error;
      case NotificationPriority.high:
        color = colorScheme.tertiary;
      case NotificationPriority.low:
        color = colorScheme.outline;
      case NotificationPriority.normal:
        color = colorScheme.primary;
    }

    return Container(
      height: 3,
      color: color,
    );
  }

  Widget _buildIcon(ColorScheme colorScheme) {
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
}

/// Helper class for showing notification banners via overlay
class NotificationBannerHelper {
  /// Show a notification banner using the provided overlay push callback
  ///
  /// This is designed to work with trufi_core_ui's OverlayManager:
  /// ```dart
  /// NotificationBannerHelper.show(
  ///   context: context,
  ///   notification: notification,
  ///   pushOverlay: (child, id) => overlayManager.push(
  ///     AppOverlayEntry(
  ///       child: child,
  ///       config: OverlayConfig(
  ///         type: OverlayType.topBanner,
  ///         id: id,
  ///       ),
  ///     ),
  ///   ),
  ///   popOverlay: (id) => overlayManager.popById(id),
  /// );
  /// ```
  static void show({
    required BuildContext context,
    required TrufiNotification notification,
    required void Function(Widget child, String id) pushOverlay,
    required void Function(String id) popOverlay,
    VoidCallback? onTap,
    Duration autoDismissDuration = const Duration(seconds: 4),
  }) {
    final id = 'notification_banner_${notification.id}';

    void dismiss() {
      popOverlay(id);
    }

    pushOverlay(
      NotificationBanner(
        notification: notification,
        onTap: () {
          dismiss();
          onTap?.call();
        },
        onDismiss: dismiss,
        autoDismissDuration: autoDismissDuration,
      ),
      id,
    );

    // Auto-dismiss
    Future.delayed(autoDismissDuration, dismiss);
  }
}
