class Quest {
  const Quest({
    required this.id,
    required this.locationId,
    required this.title,
    required this.description,
    required this.pointsReward,
    this.requireOnsiteCheckin,
    this.stepsTotal,
    this.coverImage,
  });

  final String id;
  final String locationId;
  final String title;
  final String description;
  final int pointsReward;
  final bool? requireOnsiteCheckin;
  final int? stepsTotal;
  final String? coverImage;

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'] as String? ?? '',
      locationId: json['locationId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      pointsReward: (json['pointsReward'] as num?)?.toInt() ?? 0,
      requireOnsiteCheckin: json['requireOnsiteCheckin'] as bool?,
      stepsTotal: (json['stepsTotal'] as num?)?.toInt(),
      coverImage: json['coverImage'] as String?,
    );
  }
}

class QuestProgress {
  const QuestProgress({
    required this.questId,
    required this.title,
    required this.status,
    required this.currentStep,
    required this.stepsTotal,
    required this.pointsReward,
  });

  final String questId;
  final String title;
  final String status;
  final int currentStep;
  final int stepsTotal;
  final int pointsReward;

  factory QuestProgress.fromJson(Map<String, dynamic> json) {
    return QuestProgress(
      questId: json['questId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? 'not_started',
      currentStep: (json['currentStep'] as num?)?.toInt() ?? 0,
      stepsTotal: (json['stepsTotal'] as num?)?.toInt() ?? 0,
      pointsReward: (json['pointsReward'] as num?)?.toInt() ?? 0,
    );
  }
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.displayName,
    required this.totalPoints,
    required this.rank,
  });

  final String displayName;
  final int totalPoints;
  final int rank;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      displayName: json['displayName'] as String? ?? json['name'] as String? ?? '—',
      totalPoints: (json['totalPoints'] as num?)?.toInt() ?? (json['points'] as num?)?.toInt() ?? 0,
      rank: (json['rank'] as num?)?.toInt() ?? 0,
    );
  }
}
