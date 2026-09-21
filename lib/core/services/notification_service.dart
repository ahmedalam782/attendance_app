import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class NotificationService {
  NotificationService() : _messaging = FirebaseMessaging.instance;

  NotificationService.custom(this._messaging);

  final FirebaseMessaging _messaging;

  Future<void> initialize({
    void Function(RemoteMessage message)? onForegroundMessage,
    void Function(RemoteMessage message)? onNotificationOpened,
  }) async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (kDebugMode) {
        log('FCM Permission status: ${settings.authorizationStatus}');
      }

      // Foreground handler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          log('Received foreground notification: ${message.notification?.title}');
        }
        onForegroundMessage?.call(message);
      });

      // Background tap handler
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          log('Notification opened from background: ${message.notification?.title}');
        }
        onNotificationOpened?.call(message);
      });
    } catch (e, st) {
      if (kDebugMode) {
        log('Failed to initialize NotificationService: $e', stackTrace: st);
      }
    }
  }

  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (_) {
      return null;
    }
  }

  Future<void> subscribeToProgram(String programId) async {
    try {
      final topic = 'program_${programId.replaceAll(RegExp(r'[^a-zA-Z0-9-_.~%]'), '_')}';
      await _messaging.subscribeToTopic(topic);
    } catch (_) {}
  }

  Future<void> unsubscribeFromProgram(String programId) async {
    try {
      final topic = 'program_${programId.replaceAll(RegExp(r'[^a-zA-Z0-9-_.~%]'), '_')}';
      await _messaging.unsubscribeFromTopic(topic);
    } catch (_) {}
  }
}
