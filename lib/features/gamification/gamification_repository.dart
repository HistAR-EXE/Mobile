import 'package:histar_mobile/core/api/api_client.dart';
import 'package:histar_mobile/features/gamification/gamification_models.dart';

class GamificationRepository {
  GamificationRepository(this._api);
  final ApiClient _api;

  Future<List<Quest>> listQuests() => _api.getList(
        '/api/quests',
        parseItem: Quest.fromJson,
      );

  Future<Quest> getQuest(String questId) => _api.getData(
        '/api/quests/$questId',
        parse: (raw) => Quest.fromJson(Map<String, dynamic>.from(raw as Map)),
      );

  Future<QuestProgress> startQuest(String questId) => _api.postData(
        '/api/me/quests/$questId/start',
        parse: (raw) => QuestProgress.fromJson(Map<String, dynamic>.from(raw as Map)),
      );

  Future<QuestProgress?> myProgress(String questId) async {
    try {
      return await _api.getData(
        '/api/me/quests/$questId',
        parse: (raw) => QuestProgress.fromJson(Map<String, dynamic>.from(raw as Map)),
      );
    } catch (_) {
      return null;
    }
  }

  Future<CheckinResult> checkin({
    required String locationId,
    double? latitude,
    double? longitude,
    String? qrPayload,
  }) {
    return _api.postData(
      '/api/checkins',
      data: {
        'locationId': locationId,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (qrPayload != null) 'qrPayload': qrPayload,
      },
      parse: (raw) => CheckinResult.fromJson(Map<String, dynamic>.from(raw as Map)),
    );
  }

  Future<LeaderboardResult> leaderboard({
    String scope = 'all',
    String? city,
    int limit = 20,
  }) async {
    try {
      return await _api.getData(
        '/api/leaderboard',
        query: {
          'scope': scope,
          if (city != null && city.isNotEmpty) 'city': city,
          'limit': limit,
        },
        parse: (raw) {
          if (raw is Map) {
            return LeaderboardResult.fromJson(Map<String, dynamic>.from(raw));
          }
          if (raw is List) {
            final entries = raw
                .whereType<Map>()
                .map((e) => LeaderboardEntry.fromJson(Map<String, dynamic>.from(e)))
                .toList();
            return LeaderboardResult(entries: entries, scope: scope, city: city);
          }
          return LeaderboardResult(entries: const [], scope: scope, city: city);
        },
      );
    } catch (_) {
      if (scope != 'week') {
        return leaderboard(scope: 'week', city: city, limit: limit);
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> myCompletedQuests({int size = 50}) async {
    final page = await _api.getPage<Map<String, dynamic>>(
      '/api/me/quests',
      query: {'status': 'completed', 'size': size},
      parseItem: (json) => json,
    );
    return page.items;
  }
}
