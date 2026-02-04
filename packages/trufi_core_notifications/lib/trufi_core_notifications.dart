/// Push and in-app notifications for Trufi Core apps.
///
/// This package provides:
/// - Backend notification fetching with polling support
/// - In-app notification banners (integrates with overlay system)
/// - Notification bell widget with badge
/// - Full notifications list screen
/// - Notification settings management
/// - Permission status tracking
///
/// ## Quick Start
///
/// 1. Create a NotificationManager and provide it:
/// ```dart
/// NotificationManager(
///   service: HttpNotificationService(
///     config: NotificationServiceConfig(
///       baseUrl: 'https://api.example.com',
///       getAuthToken: () async => authService.token,
///     ),
///   ),
///   pollInterval: Duration(minutes: 5),
/// )
/// ```
///
/// 2. Use NotificationBell in your app bar:
/// ```dart
/// NotificationBell(
///   onTap: () => Navigator.push(context, NotificationsScreen()),
/// )
/// ```
///
/// 3. Show in-app notifications via overlay:
/// ```dart
/// manager.onNotificationReceived = (notification) {
///   overlayManager.push(
///     AppOverlayEntry(
///       child: NotificationBanner(notification: notification),
///       config: OverlayConfig(type: OverlayType.topBanner),
///     ),
///   );
/// };
/// ```
library;

// ============================================
// MODELS
// ============================================
export 'src/models/notification.dart'
    show TrufiNotification, NotificationPriority, NotificationAction;
export 'src/models/notification_settings.dart'
    show NotificationSettings, NotificationPermissionStatus;

// ============================================
// SERVICES
// ============================================
export 'src/services/notification_service.dart'
    show
        NotificationService,
        NotificationServiceConfig,
        NotificationFetchResult,
        NotificationCallback;
export 'src/services/http_notification_service.dart' show HttpNotificationService;

// ============================================
// MANAGERS
// ============================================
export 'src/managers/notification_manager.dart' show NotificationManager;

// ============================================
// PRESENTATION - WIDGETS
// ============================================
export 'src/presentation/widgets/notification_bell.dart' show NotificationBell;
export 'src/presentation/widgets/notification_tile.dart' show NotificationTile;
export 'src/presentation/widgets/notification_list.dart' show NotificationList;
export 'src/presentation/widgets/notification_banner.dart'
    show NotificationBanner, NotificationBannerHelper;

// ============================================
// PRESENTATION - SCREENS
// ============================================
export 'src/presentation/screens/notifications_screen.dart'
    show NotificationsScreen;
