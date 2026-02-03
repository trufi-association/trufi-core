import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trufi_core_notifications/trufi_core_notifications.dart';

void main() {
  runApp(const NotificationsExampleApp());
}

class NotificationsExampleApp extends StatelessWidget {
  const NotificationsExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationManager(
        service: MockNotificationService(),
        pollInterval: const Duration(seconds: 30),
        onNotificationReceived: (notification) {
          // In a real app, this would show an in-app banner via overlay
          debugPrint('New notification: ${notification.title}');
        },
      ),
      child: MaterialApp(
        title: 'Notifications Example',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const ExampleHomePage(),
      ),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  @override
  void initState() {
    super.initState();
    // Fetch notifications on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationManager.read(context).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final manager = NotificationManager.watch(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications Example'),
        actions: [
          // Notification bell with badge
          NotificationBell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: manager,
                    child: NotificationsScreen(
                      onNotificationTap: (notification) {
                        Navigator.pop(context);
                        _showNotificationDetails(notification);
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stats card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notification Stats',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow('Total', manager.notifications.length),
                    _buildStatRow('Unread', manager.unreadCount),
                    _buildStatRow(
                      'Permission',
                      manager.permissionStatus.name,
                    ),
                    _buildStatRow(
                      'In-App Enabled',
                      manager.settings.showInApp ? 'Yes' : 'No',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Actions card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: manager.refresh,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: _addMockNotification,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Mock'),
                        ),
                        OutlinedButton.icon(
                          onPressed: manager.unreadCount > 0
                              ? manager.markAllAsRead
                              : null,
                          icon: const Icon(Icons.done_all),
                          label: const Text('Mark All Read'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Settings card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('Notifications Enabled'),
                      value: manager.settings.enabled,
                      onChanged: (value) => manager.setEnabled(value),
                    ),
                    SwitchListTile(
                      title: const Text('Show In-App'),
                      value: manager.settings.showInApp,
                      onChanged: (value) => manager.setShowInApp(value),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // In-app banner preview
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'In-App Banner Preview',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    NotificationBanner(
                      notification: TrufiNotification(
                        id: 'preview',
                        title: 'Your bus is arriving!',
                        body: 'Line 12 will arrive in 3 minutes at Main St.',
                        createdAt: DateTime.now(),
                        priority: NotificationPriority.high,
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Banner tapped!')),
                        );
                      },
                      onDismiss: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Banner dismissed!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Recent notifications preview
            if (manager.notifications.isNotEmpty) ...[
              Text(
                'Recent Notifications',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (final notification
                        in manager.notifications.take(3)) ...[
                      NotificationTile(
                        notification: notification,
                        showDismiss: false,
                        onTap: () => _showNotificationDetails(notification),
                      ),
                      if (notification != manager.notifications.take(3).last)
                        const Divider(height: 1),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value.toString(),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _addMockNotification() {
    final manager = NotificationManager.read(context);
    final random = Random();
    final priorities = NotificationPriority.values;

    final titles = [
      'Bus arriving soon!',
      'Route change detected',
      'New transit alert',
      'Service update',
      'Special announcement',
    ];

    final bodies = [
      'Your bus Line 12 will arrive in 5 minutes.',
      'Route 45 has been diverted due to construction.',
      'Metro line A is experiencing delays.',
      'Weekend schedule is now in effect.',
      'Free rides this Saturday for the city festival!',
    ];

    manager.addNotification(
      TrufiNotification(
        id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
        title: titles[random.nextInt(titles.length)],
        body: bodies[random.nextInt(bodies.length)],
        createdAt: DateTime.now(),
        priority: priorities[random.nextInt(priorities.length)],
        category: 'transit',
      ),
    );
  }

  void _showNotificationDetails(TrufiNotification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            const SizedBox(height: 16),
            Text(
              'Priority: ${notification.priority.name}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Created: ${notification.createdAt}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Read: ${notification.isRead ? "Yes" : "No"}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Mock notification service for testing
class MockNotificationService implements NotificationService {
  final List<TrufiNotification> _notifications = [];
  bool _isDisposed = false;

  MockNotificationService() {
    // Generate some initial mock notifications
    _notifications.addAll([
      TrufiNotification(
        id: '1',
        title: 'Welcome to Transit!',
        body: 'Thanks for using our app. Enable notifications to stay updated.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        priority: NotificationPriority.normal,
      ),
      TrufiNotification(
        id: '2',
        title: 'Route 45 Delayed',
        body: 'Due to traffic, Route 45 is running 10 minutes behind schedule.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        priority: NotificationPriority.high,
      ),
      TrufiNotification(
        id: '3',
        title: 'Weekend Service',
        body: 'Reminder: Weekend schedule starts tomorrow.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        priority: NotificationPriority.low,
        isRead: true,
      ),
    ]);
  }

  @override
  Future<NotificationFetchResult> fetchNotifications({
    String? cursor,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    if (_isDisposed) {
      return const NotificationFetchResult(notifications: []);
    }

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    var notifications = _notifications;
    if (unreadOnly) {
      notifications = notifications.where((n) => !n.isRead).toList();
    }

    return NotificationFetchResult(
      notifications: notifications,
      hasMore: false,
      unreadCount: _notifications.where((n) => !n.isRead).length,
    );
  }

  @override
  Future<bool> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
    return true;
  }

  @override
  Future<bool> markAllAsRead() async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    return true;
  }

  @override
  Future<bool> deleteNotification(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _notifications.removeWhere((n) => n.id == notificationId);
    return true;
  }

  @override
  Future<bool> registerDevice({
    required String pushToken,
    required String platform,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }

  @override
  Future<bool> unregisterDevice() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }

  @override
  Future<int> getUnreadCount() async {
    return _notifications.where((n) => !n.isRead).length;
  }

  @override
  void dispose() {
    _isDisposed = true;
  }
}
