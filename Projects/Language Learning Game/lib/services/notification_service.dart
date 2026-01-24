// TODO: Add iOS implementation for notifications
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Initialize the notification plugin.
  ///
  /// If [requestPermissions] is true (default) the service will attempt to
  /// request notification permissions (interactive) which must only be done
  /// from the foreground UI. When initializing from a background isolate
  /// (Workmanager callback), pass `requestPermissions: false` to avoid
  /// prompting the user from background.
  Future<void> init({bool requestPermissions = true}) async {
  // Use the same icon resource used by the app manifest (launcher_icon)
  // so the resource exists in release builds and isn't stripped.
  const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('launcher_icon');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    // Only request permissions when explicitly allowed (avoids background prompts)
    if (requestPermissions) {
      await _requestPermissions();
    }
  }

  Future<void> _requestPermissions() async {
    final PermissionStatus status = await Permission.notification.status;
    if (kDebugMode) {
      print("Notification permission status: $status");
    }
    if (status.isDenied) {
      if (kDebugMode) {
        print("Requesting notification permission...");
      }
      await Permission.notification.request();
    }
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics,
        payload: 'item x');
  }
}