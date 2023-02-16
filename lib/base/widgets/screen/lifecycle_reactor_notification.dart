import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trufi_core/base/utils/packge_info_platform.dart';
import 'package:trufi_core/base/utils/trufi_app_id.dart';
import 'package:trufi_core/base/widgets/alerts/alert_notification.dart';

import 'package:trufi_core/base/widgets/screen/lifecycle_reactor_wrapper.dart';

class LifecycleReactorNotifications implements LifecycleReactorHandler {
  static const String path = "LifecycleReactorNotifications";
  static const String _lastId = 'lastId';
  static const String _showNotification = 'showNotification';

  final String url;
  late Box _box;

  LifecycleReactorNotifications({
    required this.url,
  }) {
    _box = Hive.box(path);
  }

  @override
  void onInitState(context) {
    handlerOnStartNotifications(context)
        .then((value) => null)
        .catchError((error) {});
  }

  @override
  void onDispose() {}

  Future<void> handlerOnStartNotifications(BuildContext context) async {
    final packageInfoVersion = await PackageInfoPlatform.version();
    final uniqueId = TrufiAppId.getUniqueId;
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "User-Agent": "Trufi/$packageInfoVersion/$uniqueId",
        },
      );
      if (response.statusCode == 200) {
        final notification = jsonDecode(utf8.decode(response.bodyBytes));
        final notificationId = notification["id"]!;
        final isOtherNotification = getLastId() != notificationId;
        if (getShowNotification() || isOtherNotification) {
          if (isOtherNotification) {
            await saveCurrentId(notificationId);
            await saveShowNotification(true);
          }
          await AlertNotification.showNotification(
            context: context,
            title: notification["title"]!,
            description: notification["description"],
            bttnText: notification["actionButton"]?["name"],
            bttnUrl: notification["actionButton"]?["url"],
            imageUrl: notification["imageUrl"],
            makeDoNotShowAgain: () async {
              await saveShowNotification(false);
            },
          );
        }
      }
    } catch (_) {}
  }

  String? getLastId() {
    if (!_box.containsKey(_lastId)) return null;
    _box.get(_lastId);
    return _box.get(_lastId);
  }

  Future<void> saveCurrentId(String? id) async {
    await _box.put(_lastId, id);
  }

  bool getShowNotification() {
    if (!_box.containsKey(_showNotification)) return true;
    return _box.get(_showNotification);
  }

  Future<void> saveShowNotification(bool id) async {
    await _box.put(_showNotification, id);
  }
}
