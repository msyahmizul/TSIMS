import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final providerNotificationList =
    StateNotifierProvider<NotificationListService, Map<String, Widget>>(
        (ref) => NotificationListService(ref));

class NotificationListService extends StateNotifier<Map<String, Widget>> {
  final Ref ref;

  NotificationListService(this.ref) : super({});

  addToNotification(Widget widget, String key) {
    var t = state;
    if (t.containsKey(key)) {
      return;
    }
    t[key] = widget;
    state = t;
  }

  Map<String, Widget> getData() {
    return state;
  }

  deleteKey(String key) {
    var t = state;
    t.remove(key);
    state = t;
  }
}
