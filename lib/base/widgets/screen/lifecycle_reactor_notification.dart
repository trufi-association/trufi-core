import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trufi_core/base/widgets/alerts/alert_notification.dart';

import 'package:trufi_core/base/widgets/screen/lifecycle_reactor_wrapper.dart';

final notification = {
  "id": "dsadas3213122e",
  "title": "Eres un usuario de trufi?\n esta es la oportunidad de ganar",
  "description":
      "Si vives en la ciudad de oruro, puedes participar de nuestra campania ofreciada por [Universidad de Alemania](https://www.studying-in-germany.org/list-of-universities-in-germany/) por medio del llenado de un formularioo.\n\nDicho esto, puede pasar a registrar sus datos, no llene dos veces el [formulario](https://www.google.com/forms/about/) para no quedar descalificado.",
  "url": "https://www.trufi-association.org/"
};

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
    // final response = await http.get(Uri.parse(url));

    // if (response.statusCode == 200) {
    // final data = jsonDecode(response.body);
    // final notifications = data["notifications"] as List;
    // if (notifications.isNotEmpty) {
    // final notification = notifications[0];
    final notificationId = notification["id"];
    final isOtherNotification = getLastId() != notificationId;
    if (getShowNotification() || isOtherNotification) {
      if (isOtherNotification) {
        await saveCurrentId(notificationId);
        await saveShowNotification(true);
      }
      await AlertNotification.showNotification(
          context: context,
          title: notification["title"] ?? '',
          description: notification["description"],
          uri: notification["url"],
          makeDoNotShowAgain: () async {
            await saveShowNotification(false);
          });
    }
    //   }
    // }
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
