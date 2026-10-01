import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:torch_light/torch_light.dart';

/// E2 native bridges: share, torch, mock-location hint (Android channel when available).
abstract final class HistarNative {
  static const MethodChannel _channel = MethodChannel('vn.histar.timelens/native');

  static bool get supportsTorch => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static Future<bool> isTorchAvailable() async {
    if (!supportsTorch) return false;
    try {
      return await TorchLight.isTorchAvailable();
    } catch (_) {
      return false;
    }
  }

  static Future<bool> setTorchEnabled(bool enabled) async {
    if (!supportsTorch) return false;
    try {
      if (enabled) {
        await TorchLight.enableTorch();
      } else {
        await TorchLight.disableTorch();
      }
      return true;
    } catch (e) {
      debugPrint('HistarNative.setTorchEnabled: $e');
      return false;
    }
  }

  /// Toggles torch; returns the new on-state, or [currentlyOn] if hardware refused.
  static Future<bool> toggleTorch({required bool currentlyOn}) async {
    final next = !currentlyOn;
    final ok = await setTorchEnabled(next);
    return ok ? next : currentlyOn;
  }

  static Future<void> disableTorchIfNeeded() async {
    await setTorchEnabled(false);
  }

  static Future<void> shareFile(String path, {String? subject}) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(path)], subject: subject, text: subject),
    );
  }

  static Future<void> shareText({required String text, String? subject}) async {
    await SharePlus.instance.share(ShareParams(text: text, subject: subject));
  }

  static Future<String?> warnMockLocation() async {
    if (!Platform.isAndroid) return null;
    try {
      final mock = await _channel.invokeMethod<bool>('isMockLocationEnabled');
      if (mock == true) {
        return 'Phát hiện mock location (cài đặt nhà phát triển). Check-in GPS có thể không được chấp nhận.';
      }
    } on MissingPluginException {
      // Desktop / tests
    } on PlatformException catch (e) {
      debugPrint('HistarNative.warnMockLocation: $e');
    }
    return null;
  }
}
