class ProfileMe {
  const ProfileMe({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.role,
    this.tier,
    this.orgId,
    this.orgName,
    this.orgSubscription,
    this.level = 1,
    this.totalPoints = 0,
    this.emailVerified,
  });

  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String? role;
  final String? tier;
  final String? orgId;
  final String? orgName;
  final String? orgSubscription;
  final int level;
  final int totalPoints;
  final bool? emailVerified;

  factory ProfileMe.fromJson(Map<String, dynamic> json) {
    return ProfileMe(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String?,
      tier: json['tier'] as String?,
      orgId: json['orgId'] as String?,
      orgName: json['orgName'] as String?,
      orgSubscription: json['orgSubscription'] as String?,
      level: (json['level'] as num?)?.toInt() ?? 1,
      totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
      emailVerified: json['emailVerified'] as bool?,
    );
  }
}
