class DiscoverySummary {
  const DiscoverySummary({
    required this.discovered,
    required this.total,
    required this.keys,
  });

  final int discovered;
  final int total;
  final List<String> keys;

  factory DiscoverySummary.fromJson(Map<String, dynamic> json) {
    final rawKeys = json['keys'];
    return DiscoverySummary(
      discovered: (json['discovered'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      keys: rawKeys is List ? rawKeys.map((e) => e.toString()).toList() : const [],
    );
  }
}

class RecordDiscoveryResult {
  const RecordDiscoveryResult({
    required this.recorded,
    required this.xpEarned,
  });

  final bool recorded;
  final int xpEarned;

  factory RecordDiscoveryResult.fromJson(Map<String, dynamic> json) {
    return RecordDiscoveryResult(
      recorded: json['recorded'] as bool? ?? false,
      xpEarned: (json['xpEarned'] as num?)?.toInt() ?? 0,
    );
  }
}

class ArtifactItem {
  const ArtifactItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.unlockKey,
    required this.unlocked,
  });

  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final String unlockKey;
  final bool unlocked;

  factory ArtifactItem.fromJson(Map<String, dynamic> json) {
    return ArtifactItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      description: json['description'] as String? ?? '',
      unlockKey: json['unlockKey'] as String? ?? '',
      unlocked: json['unlocked'] as bool? ?? false,
    );
  }
}

class MyArtifactsResponse {
  const MyArtifactsResponse({
    required this.items,
    required this.collected,
    required this.total,
  });

  final List<ArtifactItem> items;
  final int collected;
  final int total;

  factory MyArtifactsResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['items'];
    return MyArtifactsResponse(
      items: raw is List
          ? raw
              .whereType<Map>()
              .map((e) => ArtifactItem.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      collected: (json['collected'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

class UserBadge {
  const UserBadge({
    required this.id,
    required this.name,
    this.iconUrl,
    required this.earned,
  });

  final String id;
  final String name;
  final String? iconUrl;
  final bool earned;

  factory UserBadge.fromJson(Map<String, dynamic> json) {
    return UserBadge(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      iconUrl: json['iconUrl'] as String?,
      earned: json['earned'] as bool? ?? false,
    );
  }
}
