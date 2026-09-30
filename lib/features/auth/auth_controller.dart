import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:histar_mobile/features/auth/auth_state.dart';
import 'package:histar_mobile/features/profile/profile_models.dart';
import 'package:histar_mobile/shared/providers.dart';

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(const AuthState()) {
    bootstrap();
  }

  final Ref _ref;

  Future<void> bootstrap() async {
    state = state.copyWith(loading: true);
    try {
      final session = _ref.read(sessionStorageProvider);
      final user = await _ref
          .read(authRepositoryProvider)
          .restoreUser()
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
      final mode = await session
          .getAppMode()
          .timeout(const Duration(seconds: 3), onTimeout: () => null);
      state = state.copyWith(
        user: user,
        appMode: mode,
        bootstrapped: true,
        loading: false,
        clearError: true,
      );
      if (user != null) {
        try {
          final me = await _ref.read(profileRepositoryProvider).me();
          await _applyProfile(me);
        } catch (_) {
          // keep session until forced logout
        }
      }
    } catch (_) {
      // Never leave the UI stuck on splash if storage/network fails.
      state = state.copyWith(bootstrapped: true, loading: false);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final payload = await _ref.read(authRepositoryProvider).login(email, password);
      state = state.copyWith(
        user: AuthUser(
          userId: payload.userId,
          displayName: payload.displayName,
          email: payload.email ?? email,
          role: payload.role,
          tier: payload.tier,
          emailVerified: payload.emailVerified,
          avatarUrl: payload.avatarUrl,
        ),
        loading: false,
      );
      final me = await _ref.read(profileRepositoryProvider).me();
      await _applyProfile(me);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final payload = await _ref.read(authRepositoryProvider).register(
            email: email,
            password: password,
            displayName: displayName,
          );
      state = state.copyWith(
        user: AuthUser(
          userId: payload.userId,
          displayName: payload.displayName,
          email: payload.email ?? email,
          role: payload.role,
          tier: payload.tier,
          emailVerified: payload.emailVerified ?? false,
        ),
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    await _ref.read(authRepositoryProvider).logout();
    state = const AuthState(bootstrapped: true);
  }

  /// Reloads `/api/profile/me` into session storage and auth state (e.g. after SePay PAID).
  Future<void> refreshProfileFromServer() async {
    final me = await _ref.read(profileRepositoryProvider).me();
    await _applyProfile(me);
  }

  Future<void> setAppMode(String mode) async {
    await _ref.read(sessionStorageProvider).setAppMode(mode);
    state = state.copyWith(appMode: mode);
  }

  Future<void> _applyProfile(ProfileMe me) async {
    final session = _ref.read(sessionStorageProvider);
    final token = await session.getAccessToken();
    if (token != null) {
      await session.saveSession(
        accessToken: token,
        refreshToken: await session.getRefreshToken(),
        userId: me.id,
        displayName: me.displayName,
        email: me.email,
        role: me.role,
        tier: me.tier,
        orgId: me.orgId,
        orgSubscription: me.orgSubscription,
        avatarUrl: me.avatarUrl,
        emailVerified: me.emailVerified,
      );
    }
    state = state.copyWith(
      user: AuthUser(
        userId: me.id,
        displayName: me.displayName,
        email: me.email,
        role: me.role,
        tier: me.tier,
        emailVerified: me.emailVerified,
        avatarUrl: me.avatarUrl,
        level: me.level,
        totalPoints: me.totalPoints,
      ),
    );
  }
}
