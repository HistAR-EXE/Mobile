import 'package:histar_mobile/core/api/api_client.dart';
import 'package:histar_mobile/features/discovery/discovery_models.dart';

class DiscoveryRepository {
  DiscoveryRepository(this._api);
  final ApiClient _api;

  Future<DiscoverySummary> summary(String locationId) => _api.getData(
        '/api/me/discoveries/summary',
        query: {'locationId': locationId},
        parse: (raw) => DiscoverySummary.fromJson(Map<String, dynamic>.from(raw as Map)),
      );

  Future<RecordDiscoveryResult> record({
    required String unlockKey,
    required String locationId,
    String source = 'tour_panorama',
  }) =>
      _api.postData(
        '/api/me/discoveries',
        data: {
          'unlockKey': unlockKey,
          'source': source,
          'locationId': locationId,
        },
        parse: (raw) => RecordDiscoveryResult.fromJson(Map<String, dynamic>.from(raw as Map)),
      );

  Future<MyArtifactsResponse> myArtifacts(String locationId) => _api.getData(
        '/api/me/artifacts',
        query: {'locationId': locationId},
        parse: (raw) => MyArtifactsResponse.fromJson(Map<String, dynamic>.from(raw as Map)),
      );

  Future<List<ArtifactItem>> catalog(String locationId) => _api.getList(
        '/api/artifacts',
        query: {'locationId': locationId},
        parseItem: ArtifactItem.fromJson,
      );

  Future<List<UserBadge>> myBadges() => _api.getList(
        '/api/me/badges',
        parseItem: UserBadge.fromJson,
      );
}
