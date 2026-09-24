import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Session keys aligned with FE localStorage `timelens_*`.
///
/// On Windows, [FlutterSecureStorage] can hang indefinitely. Token reads/writes
/// therefore use a short timeout and fall back to SharedPreferences.
class SessionStorage {
  SessionStorage({
    FlutterSecureStorage? secure,
    SharedPreferences? prefs,
  })  : _secure = secure ?? const FlutterSecureStorage(),
        _prefs = prefs;

  final FlutterSecureStorage _secure;
  SharedPreferences? _prefs;

  static const _tokenTimeout = Duration(seconds: 2);

  Future<SharedPreferences> get _p async =>
      _prefs ??= await SharedPreferences.getInstance();

  Future<T?> _secureOrNull<T>(Future<T?> Function() action) async {
    try {
      return await action().timeout(_tokenTimeout);
    } catch (e, st) {
      debugPrint('SessionStorage secure I/O failed: $e\n$st');
      return null;
    }
  }

  Future<void> _writeToken(String key, String value) async {
    final ok = await _secureOrNull(() async {
      await _secure.write(key: key, value: value);
      return true;
    });
    // Always mirror to prefs so Windows/desktop can restore without secure store.
    final p = await _p;
    await p.setString(key, value);
    if (ok == null) {
      debugPrint('SessionStorage: wrote $key to SharedPreferences only');
    }
  }

  Future<String?> _readToken(String key) async {
    final fromSecure = await _secureOrNull(() => _secure.read(key: key));
    if (fromSecure != null && fromSecure.isNotEmpty) return fromSecure;
    return (await _p).getString(key);
  }

  Future<void> saveSession({
    required String accessToken,
    String? refreshToken,
    required String userId,
    required String displayName,
    String? email,
    String? role,
    String? tier,
    String? orgId,
    String? orgSubscription,
    String? avatarUrl,
    bool? emailVerified,
  }) async {
    await _writeToken('access_token', accessToken);
    if (refreshToken != null) {
      await _writeToken('refresh_token', refreshToken);
    }
    final p = await _p;
    await p.setString('user_id', userId);
    await p.setString('display_name', displayName);
    if (email != null) await p.setString('email', email);
    if (role != null) await p.setString('role', role);
    if (tier != null) await p.setString('tier', tier);
    if (orgId != null) await p.setString('org_id', orgId);
    if (orgSubscription != null) {
      await p.setString('org_subscription', orgSubscription);
    }
    if (avatarUrl != null) await p.setString('avatar_url', avatarUrl);
    if (emailVerified != null) {
      await p.setBool('email_verified', emailVerified);
    }
  }

  Future<String?> getAccessToken() => _readToken('access_token');
  Future<String?> getRefreshToken() => _readToken('refresh_token');

  Future<String?> getUserId() async => (await _p).getString('user_id');
  Future<String?> getDisplayName() async => (await _p).getString('display_name');
  Future<String?> getEmail() async => (await _p).getString('email');
  Future<String?> getRole() async => (await _p).getString('role');
  Future<String?> getTier() async => (await _p).getString('tier');
  Future<bool?> getEmailVerified() async => (await _p).getBool('email_verified');

  Future<String?> getAppMode() async => (await _p).getString('app_mode');
  Future<void> setAppMode(String mode) async {
    await (await _p).setString('app_mode', mode);
  }

  Future<void> clear() async {
    await _secureOrNull(() async {
      await _secure.deleteAll();
      return true;
    });
    final p = await _p;
    await p.remove('access_token');
    await p.remove('refresh_token');
    await p.remove('user_id');
    await p.remove('display_name');
    await p.remove('email');
    await p.remove('role');
    await p.remove('tier');
    await p.remove('org_id');
    await p.remove('org_subscription');
    await p.remove('avatar_url');
    await p.remove('email_verified');
    await p.remove('app_mode');
  }
}
