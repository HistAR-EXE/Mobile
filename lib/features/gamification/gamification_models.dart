class QuestStep {
  const QuestStep({
    required this.id,
    required this.stepOrder,
    required this.unlockKey,
    required this.title,
    required this.objective,
    this.description,
    this.hint,
    required this.actionType,
    this.minigameId,
    this.actionLabel,
    this.xpPartial,
    this.chatPrompt,
    this.portalEra,
    this.previewImage,
  });

  final String id;
  final int stepOrder;
  final String unlockKey;
  final String title;
  final String objective;
  final String? description;
  final String? hint;
  final String actionType;
  final String? minigameId;
  final String? actionLabel;
  final int? xpPartial;
  final String? chatPrompt;
  final int? portalEra;
  final String? previewImage;

  factory QuestStep.fromJson(Map<String, dynamic> json) {
    return QuestStep(
      id: json['id'] as String? ?? '',
      stepOrder: (json['stepOrder'] as num?)?.toInt() ?? 0,
      unlockKey: json['unlockKey'] as String? ?? '',
      title: json['title'] as String? ?? '',
      objective: json['objective'] as String? ?? '',
      description: json['description'] as String?,
      hint: json['hint'] as String?,
      actionType: json['actionType'] as String? ?? 'tour',
      minigameId: json['minigameId'] as String?,
      actionLabel: json['actionLabel'] as String?,
      xpPartial: (json['xpPartial'] as num?)?.toInt(),
      chatPrompt: json['chatPrompt'] as String?,
      portalEra: (json['portalEra'] as num?)?.toInt(),
      previewImage: json['previewImage'] as String?,
    );
  }
}

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
    this.story,
    this.unlockDiscoveryKeys,
    this.steps = const [],
  });

  final String id;
  final String locationId;
  final String title;
  final String description;
  final int pointsReward;
  final bool? requireOnsiteCheckin;
  final int? stepsTotal;
  final String? coverImage;
  final String? story;
  final String? unlockDiscoveryKeys;
  final List<QuestStep> steps;

  factory Quest.fromJson(Map<String, dynamic> json) {
    final rawSteps = json['steps'];
    final steps = rawSteps is List
        ? rawSteps
            .whereType<Map>()
            .map((e) => QuestStep.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <QuestStep>[];
    steps.sort((a, b) => a.stepOrder.compareTo(b.stepOrder));
    return Quest(
      id: json['id'] as String? ?? '',
      locationId: json['locationId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      pointsReward: (json['pointsReward'] as num?)?.toInt() ?? 0,
      requireOnsiteCheckin: json['requireOnsiteCheckin'] as bool?,
      stepsTotal: (json['stepsTotal'] as num?)?.toInt(),
      coverImage: json['coverImage'] as String?,
      story: json['story'] as String?,
      unlockDiscoveryKeys: json['unlockDiscoveryKeys'] as String?,
      steps: steps,
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

class ChapterBonusResult {
  const ChapterBonusResult({
    required this.awarded,
    required this.alreadyClaimed,
  });

  final int awarded;
  final bool alreadyClaimed;

  factory ChapterBonusResult.fromJson(Map<String, dynamic> json) {
    return ChapterBonusResult(
      awarded: (json['awarded'] as num?)?.toInt() ?? 0,
      alreadyClaimed: json['alreadyClaimed'] as bool? ?? false,
    );
  }
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.displayName,
    required this.totalPoints,
    required this.rank,
    this.currentUser = false,
  });

  final String displayName;
  final int totalPoints;
  final int rank;
  final bool currentUser;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      displayName: json['displayName'] as String? ?? json['name'] as String? ?? '—',
      totalPoints: (json['totalPoints'] as num?)?.toInt() ?? (json['points'] as num?)?.toInt() ?? 0,
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      currentUser: json['currentUser'] as bool? ?? false,
    );
  }
}

class LeaderboardResult {
  const LeaderboardResult({
    required this.entries,
    this.scope,
    this.city,
    this.viewerRankLocked = false,
    this.viewerRank,
  });

  final List<LeaderboardEntry> entries;
  final String? scope;
  final String? city;
  final bool viewerRankLocked;
  final int? viewerRank;

  factory LeaderboardResult.fromJson(Map<String, dynamic> json) {
    final rawEntries = json['entries'];
    final entries = rawEntries is List
        ? rawEntries
            .whereType<Map>()
            .map((e) => LeaderboardEntry.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <LeaderboardEntry>[];
    return LeaderboardResult(
      entries: entries,
      scope: json['scope'] as String?,
      city: json['city'] as String?,
      viewerRankLocked: json['viewerRankLocked'] as bool? ?? false,
      viewerRank: (json['viewerRank'] as num?)?.toInt(),
    );
  }
}

class CheckinResult {
  const CheckinResult({
    required this.success,
    required this.xpEarned,
    required this.bonusXpAwarded,
    required this.badgesEarned,
    required this.secretUnlocked,
  });

  final bool success;
  final int xpEarned;
  final int bonusXpAwarded;
  final List<String> badgesEarned;
  final bool secretUnlocked;

  int get totalXp => xpEarned + bonusXpAwarded;

  factory CheckinResult.fromJson(Map<String, dynamic> json) {
    final rawBadges = json['badgesEarned'];
    final badgeNames = <String>[];
    if (rawBadges is List) {
      for (final b in rawBadges) {
        if (b is Map) {
          final name = b['name'] as String?;
          if (name != null && name.isNotEmpty) badgeNames.add(name);
        }
      }
    }
    return CheckinResult(
      success: json['success'] as bool? ?? true,
      xpEarned: (json['xpEarned'] as num?)?.toInt() ?? 0,
      bonusXpAwarded: (json['bonusXpAwarded'] as num?)?.toInt() ?? 0,
      badgesEarned: badgeNames,
      secretUnlocked: json['secretUnlocked'] as bool? ?? false,
    );
  }
}
