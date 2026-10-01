class SquadCreated {
  SquadCreated({
    required this.id,
    required this.code,
    this.siteCode,
    required this.leaderUserId,
    required this.createdAt,
    required this.memberCount,
  });

  final String id;
  final String code;
  final String? siteCode;
  final String leaderUserId;
  final String createdAt;
  final int memberCount;

  factory SquadCreated.fromJson(Map<String, dynamic> json) {
    return SquadCreated(
      id: json['id'] as String,
      code: json['code'] as String,
      siteCode: json['siteCode'] as String?,
      leaderUserId: json['leaderUserId'] as String,
      createdAt: json['createdAt'] as String,
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class SquadMemberState {
  SquadMemberState({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.joinedAt,
    this.stationCode,
    this.progressPercent,
    this.progressLabel,
  });

  final String userId;
  final String displayName;
  final String? avatarUrl;
  final String joinedAt;
  final String? stationCode;
  final int? progressPercent;
  final String? progressLabel;

  factory SquadMemberState.fromJson(Map<String, dynamic> json) {
    return SquadMemberState(
      userId: json['userId'] as String,
      displayName: (json['displayName'] as String?) ?? 'Thành viên',
      avatarUrl: json['avatarUrl'] as String?,
      joinedAt: json['joinedAt'] as String,
      stationCode: json['stationCode'] as String?,
      progressPercent: (json['progressPercent'] as num?)?.toInt(),
      progressLabel: json['progressLabel'] as String?,
    );
  }
}

class SquadMe {
  SquadMe({
    required this.id,
    required this.code,
    this.siteCode,
    required this.leaderUserId,
    required this.createdAt,
    required this.members,
  });

  final String id;
  final String code;
  final String? siteCode;
  final String leaderUserId;
  final String createdAt;
  final List<SquadMemberState> members;

  factory SquadMe.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['members'] as List<dynamic>? ?? [];
    return SquadMe(
      id: json['id'] as String,
      code: json['code'] as String,
      siteCode: json['siteCode'] as String?,
      leaderUserId: json['leaderUserId'] as String,
      createdAt: json['createdAt'] as String,
      members: rawMembers
          .map((e) => SquadMemberState.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}
