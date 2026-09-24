import 'package:histar_mobile/core/api/api_client.dart';
import 'package:histar_mobile/core/storage/session_storage.dart';
import 'package:histar_mobile/features/auth/auth_state.dart';

class AuthRepository {
  AuthRepository(this._api, this._session);

  final ApiClient _api;
  final SessionStorage _session;

  Future<AuthPayload> login(String email, String password) async {
    final payload = await _api.postData(
      '/api/auth/login',
      data: {'email': email, 'password': password},
      parse: (raw) => AuthPayload.fromJson(Map<String, dynamic>.from(raw as Map)),
    );
    await _persist(payload);
    return payload;
  }

  Future<AuthPayload> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final payload = await _api.postData(
      '/api/auth/register',
      data: {'email': email, 'password': password, 'displayName': displayName},
      parse: (raw) => AuthPayload.fromJson(Map<String, dynamic>.from(raw as Map)),
    );
    await _persist(payload);
    return payload;
  }

  Future<void> logout() async {
    final refresh = await _session.getRefreshToken();
    try {
      await _api.postData(
        '/api/auth/logout',
        data: {'refreshToken': refresh},
        parse: (_) => true,
      );
    } catch (_) {
      // ignore network on logout
    }
    await _session.clear();
  }

  Future<AuthUser?> restoreUser() async {
    final token = await _session.getAccessToken();
    final userId = await _session.getUserId();
    final name = await _session.getDisplayName();
    if (token == null || userId == null || name == null) return null;
    return AuthUser(
      userId: userId,
      displayName: name,
      email: await _session.getEmail(),
      role: await _session.getRole(),
      tier: await _session.getTier(),
      emailVerified: await _session.getEmailVerified(),
    );
  }

  Future<void> _persist(AuthPayload p) async {
    await _session.saveSession(
      accessToken: p.bearer,
      refreshToken: p.refreshToken,
      userId: p.userId,
      displayName: p.displayName,
      email: p.email,
      role: p.role,
      tier: p.tier,
      orgId: p.orgId,
      orgSubscription: p.orgSubscription,
      avatarUrl: p.avatarUrl,
      emailVerified: p.emailVerified,
    );
  }
}
