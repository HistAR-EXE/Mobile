import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:histar_mobile/core/api/api_client.dart';
import 'package:histar_mobile/features/device/device_repository.dart';

/// FCM registration stub when `google-services.json` is not present (see mobile/README.md).
class HistarPush {
  HistarPush(this._repo);

  final DeviceRepository _repo;

  static Future<HistarPush?> tryCreate(ApiClient client) async {
    // firebase_messaging is optional until Firebase Android/iOS app is wired.
    return HistarPush(DeviceRepository(client));
  }

  Future<void> registerIfAuthenticated() async {
    final platform = Platform.isAndroid
        ? 'ANDROID'
        : Platform.isIOS
            ? 'IOS'
            : 'WEB';
    final token = await _resolveFcmToken();
    if (token == null || token.isEmpty) {
      debugPrint('HistarPush: skip register (no FCM token — add google-services.json for prod)');
      return;
    }
    try {
      await _repo.registerPushToken(token: token, platform: platform);
    } catch (e) {
      debugPrint('HistarPush.register: $e');
    }
  }

  Future<String?> _resolveFcmToken() async {
    // Stub: real implementation uses firebase_messaging after google-services.json is added.
    return null;
  }
}
