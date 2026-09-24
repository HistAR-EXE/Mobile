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

  Future<Map<String, dynamic>> checkin({
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
      parse: (raw) => Map<String, dynamic>.from(raw as Map),
    );
  }

  Future<List<LeaderboardEntry>> leaderboard({int limit = 20}) => _api.getList(
        '/api/leaderboard',
        query: {'limit': limit},
        parseItem: LeaderboardEntry.fromJson,
      );
}
