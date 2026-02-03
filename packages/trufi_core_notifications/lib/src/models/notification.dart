import 'package:flutter/foundation.dart';

/// Priority level for notifications
enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

/// Action that can be performed when tapping a notification
@immutable
class NotificationAction {
  /// Unique identifier for the action
  final String id;

  /// Display label for the action
  final String label;

  /// Optional deep link URL to navigate to
  final String? deepLink;

  /// Optional payload data
  final Map<String, dynamic>? payload;

  const NotificationAction({
    required this.id,
    required this.label,
    this.deepLink,
    this.payload,
  });

  factory NotificationAction.fromJson(Map<String, dynamic> json) {
    return NotificationAction(
      id: json['id'] as String,
      label: json['label'] as String,
      deepLink: json['deepLink'] as String?,
      payload: json['payload'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        if (deepLink != null) 'deepLink': deepLink,
        if (payload != null) 'payload': payload,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationAction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// A notification in the Trufi app
@immutable
class TrufiNotification {
  /// Unique identifier
  final String id;

  /// Notification title
  final String title;

  /// Notification body/message
  final String body;

  /// Optional image URL
  final String? imageUrl;

  /// When the notification was created
  final DateTime createdAt;

  /// When the notification expires (optional)
  final DateTime? expiresAt;

  /// Whether the notification has been read
  final bool isRead;

  /// Priority level
  final NotificationPriority priority;

  /// Category/channel for grouping
  final String? category;

  /// Primary action when tapping the notification
  final NotificationAction? action;

  /// Additional actions (e.g., buttons)
  final List<NotificationAction> additionalActions;

  /// Raw payload data from backend
  final Map<String, dynamic>? data;

  const TrufiNotification({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.createdAt,
    this.expiresAt,
    this.isRead = false,
    this.priority = NotificationPriority.normal,
    this.category,
    this.action,
    this.additionalActions = const [],
    this.data,
  });

  /// Whether this notification has expired
  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// Create a copy with updated fields
  TrufiNotification copyWith({
    String? id,
    String? title,
    String? body,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isRead,
    NotificationPriority? priority,
    String? category,
    NotificationAction? action,
    List<NotificationAction>? additionalActions,
    Map<String, dynamic>? data,
  }) {
    return TrufiNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isRead: isRead ?? this.isRead,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      action: action ?? this.action,
      additionalActions: additionalActions ?? this.additionalActions,
      data: data ?? this.data,
    );
  }

  factory TrufiNotification.fromJson(Map<String, dynamic> json) {
    return TrufiNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      isRead: json['isRead'] as bool? ?? false,
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => NotificationPriority.normal,
      ),
      category: json['category'] as String?,
      action: json['action'] != null
          ? NotificationAction.fromJson(json['action'] as Map<String, dynamic>)
          : null,
      additionalActions: (json['additionalActions'] as List<dynamic>?)
              ?.map((e) => NotificationAction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'createdAt': createdAt.toIso8601String(),
        if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
        'isRead': isRead,
        'priority': priority.name,
        if (category != null) 'category': category,
        if (action != null) 'action': action!.toJson(),
        if (additionalActions.isNotEmpty)
          'additionalActions': additionalActions.map((e) => e.toJson()).toList(),
        if (data != null) 'data': data,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrufiNotification &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'TrufiNotification(id: $id, title: $title, isRead: $isRead)';
}
