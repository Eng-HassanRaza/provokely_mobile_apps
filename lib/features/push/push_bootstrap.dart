import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/network/dio_client.dart';
import '../../core/routing/app_router.dart';

Future<void> initializePushIfEnabled(ProviderContainer container) async {
  if (!AppConfig.enableFcm) return;
  try {
    await Firebase.initializeApp();
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    final token = await messaging.getToken();
    if (token != null) {
      await _registerDevice(container, token);
    }
    FirebaseMessaging.onTokenRefresh.listen((t) => _registerDevice(container, t));

    FirebaseMessaging.onMessage.listen((message) {
      final ctx = rootNavigatorKey.currentContext;
      if (ctx != null && message.notification != null) {
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(message.notification!.title ?? 'New notification')));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final data = message.data;
      final commentId = data['comment_id']?.toString();
      final ctx = rootNavigatorKey.currentContext;
      if (ctx != null && commentId != null) {
        GoRouter.of(ctx).push('/approval/$commentId');
      }
    });
  } catch (_) {
    // Ignore push errors in MVP when disabled/misconfigured.
  }
}

Future<void> _registerDevice(ProviderContainer container, String token) async {
  final dio = container.read(dioProvider);
  final platform = Platform.isIOS ? 'ios' : 'android';
  try {
    await dio.post('/api/v1/core/devices/', data: {'platform': platform, 'token': token});
  } catch (_) {
    // ignore
  }
}


