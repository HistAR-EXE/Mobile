import 'package:histar_mobile/core/api/api_client.dart';
import 'package:histar_mobile/features/profile/profile_models.dart';

class ProfileRepository {
  ProfileRepository(this._api);
  final ApiClient _api;

  Future<ProfileMe> me() => _api.getData(
        '/api/profile/me',
        parse: (raw) => ProfileMe.fromJson(Map<String, dynamic>.from(raw as Map)),
      );
}
