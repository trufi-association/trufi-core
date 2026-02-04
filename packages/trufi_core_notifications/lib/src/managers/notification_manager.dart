import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification.dart';
import '../models/notification_settings.dart';
import '../services/notification_service.dart';

/// Manages notification state and coordinates with the backend service
class NotificationManager extends ChangeNotifier {
  static const _settingsKey = 'trufi_notification_settings';
  static const _cachedNotificationsKey = 'trufi_cached_notifications';

  final NotificationService? _service;
  final Duration? _pollInterval;

  List<TrufiNotification> _notifications = [];
  NotificationSettings _settings = NotificationSettings.defaults;
  NotificationPermissionStatus _permissionStatus =
      NotificationPermissionStatus.notDetermined;

  bool _isLoading = false;
  bool _isInitialized = false;
  bool _hasMore = false;
  String? _nextCursor;
  int _unreadCount = 0;
  Timer? _pollTimer;
  bool _isDisposed = false;

  /// Callback when a new notification is received (for in-app display)
  final void Function(TrufiNotification notification)? onNotificationReceived;

  NotificationManager({
    NotificationService? service,
    Duration? pollInterval,
    this.onNotificationReceived,
  })  : _service = service,
        _pollInterval = pollInterval {
    _initialize();
  }

  // ============================================
  // GETTERS
  // ============================================

  /// All notifications
  List<TrufiNotification> get notifications =>
      List.unmodifiable(_notifications);

  /// Unread notifications only
  List<TrufiNotification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  /// Current notification settings
  NotificationSettings get settings => _settings;

  /// Current permission status
  NotificationPermissionStatus get permissionStatus => _permissionStatus;

  /// Whether notifications are currently loading
  bool get isLoading => _isLoading;

  /// Whether the manager has been initialized
  bool get isInitialized => _isInitialized;

  /// Whether there are more notifications to load
  bool get hasMore => _hasMore;

  /// Number of unread notifications
  int get unreadCount => _unreadCount;

  /// Whether in-app notifications should be shown
  bool get shouldShowInApp =>
      _settings.enabled && _settings.showInApp && !_settings.isQuietHours;

  // ============================================
  // INITIALIZATION
  // ============================================

  Future<void> _initialize() async {
    await _loadSettings();
    await _loadCachedNotifications();
    _isInitialized = true;
    _safeNotifyListeners();

    // Start polling if configured
    _startPolling();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      if (settingsJson != null) {
        _settings = NotificationSettings.fromJson(
          jsonDecode(settingsJson) as Map<String, dynamic>,
        );
      }
    } catch (e) {
      // Use defaults on error
    }
  }

  Future<void> _loadCachedNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cachedNotificationsKey);
      if (cachedJson != null) {
        final list = jsonDecode(cachedJson) as List<dynamic>;
        _notifications = list
            .map((e) => TrufiNotification.fromJson(e as Map<String, dynamic>))
            .toList();
        _updateUnreadCount();
      }
    } catch (e) {
      // Use empty list on error
    }
  }

  Future<void> _cacheNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(_notifications.map((n) => n.toJson()).toList());
      await prefs.setString(_cachedNotificationsKey, json);
    } catch (e) {
      // Ignore cache errors
    }
  }

  void _startPolling() {
    final pollInterval = _pollInterval;
    final service = _service;
    if (pollInterval == null || service == null) return;

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(pollInterval, (_) => refresh());
  }

  // ============================================
  // NOTIFICATION OPERATIONS
  // ============================================

  /// Fetch notifications from the backend
  Future<void> fetchNotifications({bool loadMore = false}) async {
    final service = _service;
    if (service == null || _isLoading) return;
    if (loadMore && !_hasMore) return;

    _isLoading = true;
    _safeNotifyListeners();

    try {
      final result = await service.fetchNotifications(
        cursor: loadMore ? _nextCursor : null,
        limit: 20,
      );

      if (loadMore) {
        _notifications.addAll(result.notifications);
      } else {
        _notifications = result.notifications;
      }

      _hasMore = result.hasMore;
      _nextCursor = result.nextCursor;
      final unreadCount = result.unreadCount;
      if (unreadCount != null) {
        _unreadCount = unreadCount;
      } else {
        _updateUnreadCount();
      }

      await _cacheNotifications();
    } catch (e) {
      // Keep existing notifications on error
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  /// Refresh notifications (fetch from start)
  Future<void> refresh() async {
    _nextCursor = null;
    await fetchNotifications();
  }

  /// Load more notifications (pagination)
  Future<void> loadMore() async {
    await fetchNotifications(loadMore: true);
  }

  /// Mark a notification as read
  Future<bool> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return false;

    // Optimistic update
    final notification = _notifications[index];
    if (notification.isRead) return true;

    _notifications[index] = notification.copyWith(isRead: true);
    _updateUnreadCount();
    _safeNotifyListeners();

    // Sync with backend
    final service = _service;
    if (service != null) {
      final success = await service.markAsRead(notificationId);
      if (!success) {
        // Revert on failure
        _notifications[index] = notification;
        _updateUnreadCount();
        _safeNotifyListeners();
        return false;
      }
    }

    await _cacheNotifications();
    return true;
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    // Optimistic update
    final oldNotifications = List<TrufiNotification>.from(_notifications);
    _notifications = _notifications
        .map((n) => n.isRead ? n : n.copyWith(isRead: true))
        .toList();
    _unreadCount = 0;
    _safeNotifyListeners();

    // Sync with backend
    final service = _service;
    if (service != null) {
      final success = await service.markAllAsRead();
      if (!success) {
        // Revert on failure
        _notifications = oldNotifications;
        _updateUnreadCount();
        _safeNotifyListeners();
        return false;
      }
    }

    await _cacheNotifications();
    return true;
  }

  /// Delete a notification
  Future<bool> deleteNotification(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return false;

    // Optimistic update
    final notification = _notifications.removeAt(index);
    _updateUnreadCount();
    _safeNotifyListeners();

    // Sync with backend
    final service = _service;
    if (service != null) {
      final success = await service.deleteNotification(notificationId);
      if (!success) {
        // Revert on failure
        _notifications.insert(index, notification);
        _updateUnreadCount();
        _safeNotifyListeners();
        return false;
      }
    }

    await _cacheNotifications();
    return true;
  }

  /// Add a notification locally (e.g., from push)
  void addNotification(TrufiNotification notification) {
    // Check if already exists
    if (_notifications.any((n) => n.id == notification.id)) return;

    _notifications.insert(0, notification);
    _updateUnreadCount();
    _safeNotifyListeners();

    // Notify callback for in-app display
    if (shouldShowInApp && onNotificationReceived != null) {
      onNotificationReceived!(notification);
    }

    _cacheNotifications();
  }

  // ============================================
  // SETTINGS
  // ============================================

  /// Update notification settings
  Future<void> updateSettings(NotificationSettings newSettings) async {
    _settings = newSettings;
    _safeNotifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, jsonEncode(_settings.toJson()));
    } catch (e) {
      // Ignore persistence errors
    }
  }

  /// Enable/disable notifications
  Future<void> setEnabled(bool enabled) async {
    await updateSettings(_settings.copyWith(enabled: enabled));
  }

  /// Enable/disable in-app notifications
  Future<void> setShowInApp(bool showInApp) async {
    await updateSettings(_settings.copyWith(showInApp: showInApp));
  }

  // ============================================
  // PERMISSIONS
  // ============================================

  /// Update permission status (called from platform-specific code)
  void setPermissionStatus(NotificationPermissionStatus status) {
    if (_permissionStatus == status) return;
    _permissionStatus = status;
    _safeNotifyListeners();
  }

  // ============================================
  // DEVICE REGISTRATION
  // ============================================

  /// Register device for push notifications
  Future<bool> registerDevice({
    required String pushToken,
    required String platform,
  }) async {
    final service = _service;
    if (service == null) return false;
    return service.registerDevice(
      pushToken: pushToken,
      platform: platform,
    );
  }

  /// Unregister device from push notifications
  Future<bool> unregisterDevice() async {
    final service = _service;
    if (service == null) return false;
    return service.unregisterDevice();
  }

  // ============================================
  // HELPERS
  // ============================================

  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pollTimer?.cancel();
    _service?.dispose();
    super.dispose();
  }

  // ============================================
  // PROVIDER HELPERS
  // ============================================

  static NotificationManager read(BuildContext context) =>
      context.read<NotificationManager>();

  static NotificationManager watch(BuildContext context) =>
      context.watch<NotificationManager>();

  static NotificationManager? maybeWatch(BuildContext context) =>
      context.watch<NotificationManager?>();
}
