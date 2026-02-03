import '../models/notification.dart';

/// Result of fetching notifications from the backend
class NotificationFetchResult {
  /// List of notifications
  final List<TrufiNotification> notifications;

  /// Whether there are more notifications to fetch
  final bool hasMore;

  /// Cursor for pagination (pass to next fetch)
  final String? nextCursor;

  /// Total unread count (if provided by backend)
  final int? unreadCount;

  const NotificationFetchResult({
    required this.notifications,
    this.hasMore = false,
    this.nextCursor,
    this.unreadCount,
  });
}

/// Configuration for the notification service
class NotificationServiceConfig {
  /// Base URL for the notifications API
  final String baseUrl;

  /// Authentication token getter
  final Future<String?> Function()? getAuthToken;

  /// Device ID for push notification registration
  final Future<String> Function()? getDeviceId;

  /// Poll interval for fetching new notifications (null = no polling)
  final Duration? pollInterval;

  /// Headers to include in all requests
  final Map<String, String>? headers;

  const NotificationServiceConfig({
    required this.baseUrl,
    this.getAuthToken,
    this.getDeviceId,
    this.pollInterval,
    this.headers,
  });
}

/// Abstract interface for notification backend service
abstract class NotificationService {
  /// Fetch notifications from the backend
  ///
  /// [cursor] - Pagination cursor from previous fetch
  /// [limit] - Maximum number of notifications to fetch
  /// [unreadOnly] - Only fetch unread notifications
  Future<NotificationFetchResult> fetchNotifications({
    String? cursor,
    int limit = 20,
    bool unreadOnly = false,
  });

  /// Mark a notification as read
  Future<bool> markAsRead(String notificationId);

  /// Mark all notifications as read
  Future<bool> markAllAsRead();

  /// Delete a notification
  Future<bool> deleteNotification(String notificationId);

  /// Register device for push notifications
  ///
  /// [pushToken] - The push notification token from FCM/APNs
  /// [platform] - Platform identifier (ios, android, web)
  Future<bool> registerDevice({
    required String pushToken,
    required String platform,
  });

  /// Unregister device from push notifications
  Future<bool> unregisterDevice();

  /// Get current unread count
  Future<int> getUnreadCount();

  /// Dispose resources
  void dispose();
}

/// Callback for handling incoming notifications
typedef NotificationCallback = void Function(TrufiNotification notification);
