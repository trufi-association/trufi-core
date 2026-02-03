import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/notification.dart';
import 'notification_service.dart';

/// HTTP-based implementation of NotificationService
class HttpNotificationService implements NotificationService {
  final NotificationServiceConfig config;
  final http.Client _client;

  bool _isDisposed = false;

  HttpNotificationService({
    required this.config,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      ...?config.headers,
    };

    if (config.getAuthToken != null) {
      final token = await config.getAuthToken!();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    final baseUri = Uri.parse(config.baseUrl);
    return baseUri.replace(
      path: '${baseUri.path}$path',
      queryParameters: queryParams,
    );
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

    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        if (cursor != null) 'cursor': cursor,
        if (unreadOnly) 'unread': 'true',
      };

      final response = await _client.get(
        _buildUri('/notifications', queryParams),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final notifications = (data['notifications'] as List<dynamic>?)
                ?.map((e) => TrufiNotification.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];

        return NotificationFetchResult(
          notifications: notifications,
          hasMore: data['hasMore'] as bool? ?? false,
          nextCursor: data['nextCursor'] as String?,
          unreadCount: data['unreadCount'] as int?,
        );
      }

      return const NotificationFetchResult(notifications: []);
    } catch (e) {
      // Log error in production
      return const NotificationFetchResult(notifications: []);
    }
  }

  @override
  Future<bool> markAsRead(String notificationId) async {
    if (_isDisposed) return false;

    try {
      final response = await _client.post(
        _buildUri('/notifications/$notificationId/read'),
        headers: await _getHeaders(),
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> markAllAsRead() async {
    if (_isDisposed) return false;

    try {
      final response = await _client.post(
        _buildUri('/notifications/read-all'),
        headers: await _getHeaders(),
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteNotification(String notificationId) async {
    if (_isDisposed) return false;

    try {
      final response = await _client.delete(
        _buildUri('/notifications/$notificationId'),
        headers: await _getHeaders(),
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> registerDevice({
    required String pushToken,
    required String platform,
  }) async {
    if (_isDisposed) return false;

    try {
      String? deviceId;
      if (config.getDeviceId != null) {
        deviceId = await config.getDeviceId!();
      }

      final response = await _client.post(
        _buildUri('/devices/register'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'pushToken': pushToken,
          'platform': platform,
          if (deviceId != null) 'deviceId': deviceId,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> unregisterDevice() async {
    if (_isDisposed) return false;

    try {
      String? deviceId;
      if (config.getDeviceId != null) {
        deviceId = await config.getDeviceId!();
      }

      final response = await _client.post(
        _buildUri('/devices/unregister'),
        headers: await _getHeaders(),
        body: jsonEncode({
          if (deviceId != null) 'deviceId': deviceId,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<int> getUnreadCount() async {
    if (_isDisposed) return 0;

    try {
      final response = await _client.get(
        _buildUri('/notifications/unread-count'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['count'] as int? ?? 0;
      }

      return 0;
    } catch (e) {
      return 0;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _client.close();
  }
}
