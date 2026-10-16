import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:komutan/app/dashboard/notification/notification_controller.dart';
import 'package:komutan/app/dashboard/notification/notification_screen.dart';

import 'ApiService.dart';
import 'auth_service.dart';

/// Set to true after you buy the Apple Developer account and finish iOS setup.
const bool kEnableIosPush = false;

@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  // Top-level function. Keep it light.
  // Messages that contain a `notification` block are shown by the system.
}

class PushService {
  static final _fcm = FirebaseMessaging.instance;
  static final _local = FlutterLocalNotificationsPlugin();
  static final _box = GetStorage();

  /// Token that the backend currently has for this device + logged-in driver.
  static const _tokenKey = 'fcm_token_registered';

  /// Set when the app was opened from a notification while still on the splash.
  static bool _pendingTap = false;

  static const _channel = AndroidNotificationChannel('high_importance_channel', 'High Importance Notifications', importance: Importance.high);

  static bool get _enabled => defaultTargetPlatform == TargetPlatform.android || (defaultTargetPlatform == TargetPlatform.iOS && kEnableIosPush);

  // ---------------------------------------------------------------- init

  /// Call once from main(). Safe to call without await.
  static Future<void> init() async {
    if (!_enabled) {
      debugPrint('Push disabled on this platform.');
      return;
    }

    try {
      await _fcm.requestPermission(alert: true, badge: true, sound: true);
      await _fcm.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

      await _local.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(requestAlertPermission: false, requestBadgePermission: false, requestSoundPermission: false),
        ),
        // Tap on a notification that was shown while the app was in foreground.
        onDidReceiveNotificationResponse: (_) => _openNotifications(),
      );

      await _local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(_channel);

      // App in foreground: Android does not draw it by itself, so show it
      // ourselves and refresh the bell badge / list.
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      // App in background, user taps the notification.
      FirebaseMessaging.onMessageOpenedApp.listen((_) => _openNotifications());

      // App was terminated, user taps the notification. The splash screen is
      // still running, so remember it and open it after splash navigation.
      final initial = await _fcm.getInitialMessage();
      if (initial != null) _pendingTap = true;

      // Token changed (reinstall, restore, Google rotated it) -> update backend.
      _fcm.onTokenRefresh.listen(_onTokenRefresh);

      // App start with an existing login session.
      await registerToken();
    } catch (e) {
      debugPrint('PushService init error: $e');
    }
  }

  // --------------------------------------------------------- token <-> API

  /// Sends the device FCM token to the backend for the logged-in driver.
  /// Call right after login (OTP verify). App start is handled by init().
  static Future<void> registerToken() async {
    if (!_enabled) return;
    try {
      if (!Get.find<AuthService>().isLoggedIn) return;

      final token = await _getToken();
      if (token == null) return;
      if (kDebugMode) debugPrint('FCM TOKEN: $token');

      // Already registered for this login session.
      if (_box.read<String>(_tokenKey) == token) return;

      await _sendToken(token);
    } catch (e) {
      debugPrint('registerToken error: $e');
    }
  }

  /// Removes the token from the backend and invalidates it on the device.
  /// Call on logout BEFORE the auth token is cleared (the API needs the JWT).
  static Future<void> unregisterToken() async {
    if (!_enabled) return;
    try {
      final token = _box.read<String>(_tokenKey) ?? await _getToken();
      if (token != null) {
        final res = await Get.find<ApiService>().removeFcmToken(token).timeout(const Duration(seconds: 6));
        debugPrint('removeFcmToken -> ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      debugPrint('unregisterToken error: $e');
    } finally {
      await _box.remove(_tokenKey);
      // A fresh token is generated for the next login, so this device can
      // never receive the previous driver's notifications.
      try {
        await _fcm.deleteToken();
      } catch (_) {}
    }
  }

  static Future<void> _sendToken(String token) async {
    final res = await Get.find<ApiService>().saveFcmToken(token);
    debugPrint('saveFcmToken -> ${res.statusCode} ${res.body}');
    if (res.isOk && res.body?['success'] != false) {
      await _box.write(_tokenKey, token);
    }
  }

  static Future<void> _onTokenRefresh(String newToken) async {
    debugPrint('FCM TOKEN REFRESHED: $newToken');
    try {
      if (!Get.find<AuthService>().isLoggedIn) return;
      final old = _box.read<String>(_tokenKey);
      await _sendToken(newToken);
      if (old != null && old != newToken) {
        await Get.find<ApiService>().removeFcmToken(old);
      }
    } catch (e) {
      debugPrint('onTokenRefresh error: $e');
    }
  }

  static Future<String?> _getToken() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        String? apns;
        for (var i = 0; i < 10 && apns == null; i++) {
          apns = await _fcm.getAPNSToken();
          if (apns == null) await Future.delayed(const Duration(milliseconds: 500));
        }
        if (apns == null) {
          debugPrint('APNs token not available.');
          return null;
        }
      }
      return await _fcm.getToken();
    } catch (e) {
      debugPrint('FCM token error: $e');
      return null;
    }
  }

  // ------------------------------------------------------ message handling

  static void _onForegroundMessage(RemoteMessage m) {
    _refreshNotifications();

    if (defaultTargetPlatform != TargetPlatform.android) return; // iOS draws it itself

    // Works for "notification" messages and for data-only messages.
    final title = m.notification?.title ?? m.data['title']?.toString();
    final body = m.notification?.body ?? m.data['message']?.toString() ?? m.data['body']?.toString();
    if (title == null && body == null) return;

    _local.show(
      id: m.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(_channel.id, _channel.name, importance: Importance.high, priority: Priority.high),
      ),
      payload: jsonEncode(m.data),
    );
  }

  /// Reloads the bell badge + list so new pushes show up without a manual refresh.
  static void _refreshNotifications() {
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().fetchNotifications(silent: true);
    }
  }

  static void _openNotifications() {
    if (!Get.isRegistered<AuthService>() || !Get.find<AuthService>().isLoggedIn) return;
    _refreshNotifications();
    Get.to(() => const NotificationScreen());
  }

  /// Called by the splash controller after it navigated to the home screen.
  static void handlePendingTap() {
    if (!_pendingTap) return;
    _pendingTap = false;
    _openNotifications();
  }
}
