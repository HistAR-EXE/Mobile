import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Runtime env for HistAR mobile — mirrors FE `appEnv`.
class AppEnv {
  AppEnv._();

  static String get apiBaseUrl {
    final raw = dotenv.env['API_BASE_URL']?.trim() ?? '';
    if (raw.isEmpty) return 'https://histar-postgre.onrender.com';
    return raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
  }

  static String get mediaBaseUrl {
    final raw = dotenv.env['MEDIA_BASE_URL']?.trim() ?? '';
    if (raw.isEmpty) return 'https://fe-lake-five.vercel.app';
    return raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
  }

  /// Logs a warning when a base URL is not HTTPS. Does not throw.
  static void warnIfInsecure() {
    for (final entry in {
      'API_BASE_URL': apiBaseUrl,
      'MEDIA_BASE_URL': mediaBaseUrl,
      'WEB_APP_URL': webAppUrl,
    }.entries) {
      if (!entry.value.startsWith('https://')) {
        debugPrint('AppEnv: ${entry.key} should be https, got ${entry.value}');
      }
    }
  }

  static String get webAppUrl {
    final raw = dotenv.env['WEB_APP_URL']?.trim() ?? '';
    if (raw.isEmpty) return mediaBaseUrl;
    return raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
  }

  /// Resolve relative `/media/...` URLs against MEDIA_BASE_URL.
  static String resolveMedia(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/')) return '$mediaBaseUrl$url';
    return '$mediaBaseUrl/$url';
  }
}
