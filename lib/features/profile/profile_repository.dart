import 'package:histar_mobile/core/api/api_client.dart';
import 'package:histar_mobile/features/locations/location_models.dart';
import 'package:histar_mobile/features/profile/passport_models.dart';
import 'package:histar_mobile/features/profile/profile_models.dart';

class ProfileRepository {
  ProfileRepository(this._api);
  final ApiClient _api;

  Future<ProfileMe> me() => _api.getData(
        '/api/profile/me',
        parse: (raw) => ProfileMe.fromJson(Map<String, dynamic>.from(raw as Map)),
      );

  Future<UserPassport?> passport() async {
    try {
      return await _api.getData(
        '/api/me/passport',
        parse: (raw) => UserPassport.fromJson(Map<String, dynamic>.from(raw as Map)),
      );
    } catch (_) {
      return null;
    }
  }

  /// Derives passport stamps from completed quests + location catalog when `/api/me/passport` is unavailable.
  Future<UserPassport> passportFromQuests(
    Future<List<HeritageLocation>> locationsFuture,
    Future<List<Map<String, dynamic>>> completedQuestsFuture,
  ) async {
    final locations = await locationsFuture;
    final quests = await completedQuestsFuture;
    final locById = {for (final l in locations) l.id: l};
    final stampedIds = <String>{};
    final stamps = <PassportStamp>[];

    for (final q in quests) {
      final locationId = q['locationId'] as String? ?? '';
      if (locationId.isEmpty || stampedIds.contains(locationId)) continue;
      stampedIds.add(locationId);
      final loc = locById[locationId];
      final completedAt = q['completedAt'];
      stamps.add(
        PassportStamp(
          locationId: locationId,
          locationName: loc?.name,
          stampedAt: completedAt is String ? DateTime.tryParse(completedAt) : null,
        ),
      );
    }

    stamps.sort((a, b) => (b.stampedAt ?? DateTime(1970)).compareTo(a.stampedAt ?? DateTime(1970)));
    return UserPassport(stamps: stamps);
  }
}
