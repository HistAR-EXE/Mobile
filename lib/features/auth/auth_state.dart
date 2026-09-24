class AuthPayload {
  const AuthPayload({
    required this.token,
    required this.userId,
    required this.displayName,
    this.accessToken,
    this.refreshToken,
    this.email,
    this.role,
    this.tier,
    this.orgId,
    this.orgSubscription,
    this.avatarUrl,
    this.emailVerified,
  });

  final String token;
  final String? accessToken;
  final String? refreshToken;
  final String userId;
  final String displayName;
  final String? email;
  final String? role;
  final String? tier;
  final String? orgId;
  final String? orgSubscription;
  final String? avatarUrl;
  final bool? emailVerified;

  String get bearer => accessToken ?? token;

  factory AuthPayload.fromJson(Map<String, dynamic> json) {
    return AuthPayload(
      token: (json['token'] as String?) ?? (json['accessToken'] as String?) ?? '',
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      userId: json['userId'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      email: json['email'] as String?,
      role: json['role'] as String?,
      tier: json['tier'] as String?,
      orgId: json['orgId'] as String?,
      orgSubscription: json['orgSubscription'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      emailVerified: json['emailVerified'] as bool?,
    );
  }
}

class AuthUser {
  const AuthUser({
    required this.userId,
    required this.displayName,
    this.email,
    this.role,
    this.tier,
    this.emailVerified,
    this.avatarUrl,
  });

  final String userId;
  final String displayName;
  final String? email;
  final String? role;
  final String? tier;
  final bool? emailVerified;
  final String? avatarUrl;

  bool get isAdmin => role?.toUpperCase() == 'ADMIN';
  bool get isTeacher =>
      role?.toUpperCase() == 'TEACHER' || role?.toUpperCase() == 'ORG_ADMIN';
  bool get needsEmailVerification => emailVerified == false;
}

class AuthState {
  const AuthState({
    this.user,
    this.loading = false,
    this.bootstrapped = false,
    this.error,
    this.appMode,
  });

  final AuthUser? user;
  final bool loading;
  final bool bootstrapped;
  final String? error;
  /// `online` | `offline` | null
  final String? appMode;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    AuthUser? user,
    bool? loading,
    bool? bootstrapped,
    String? error,
    String? appMode,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      loading: loading ?? this.loading,
      bootstrapped: bootstrapped ?? this.bootstrapped,
      error: clearError ? null : (error ?? this.error),
      appMode: appMode ?? this.appMode,
    );
  }
}
