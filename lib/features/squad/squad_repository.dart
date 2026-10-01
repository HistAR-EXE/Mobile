import 'package:histar_mobile/core/api/api_client.dart';
import 'package:histar_mobile/features/squad/squad_models.dart';

/// REST tiểu đội (B7). WebSocket co-op: dùng FE `/squad` hoặc `web_socket_channel` sau.
class SquadRepository {
  SquadRepository(this._api);

  final ApiClient _api;

  Future<SquadCreated> create({String? siteCode}) => _api.postData(
        '/api/squads',
        data: siteCode != null && siteCode.isNotEmpty ? {'siteCode': siteCode} : {},
        parse: (raw) => SquadCreated.fromJson(Map<String, dynamic>.from(raw as Map)),
      );

  Future<SquadCreated> join(String code) => _api.postData(
        '/api/squads/join',
        data: {'code': code.trim().toUpperCase()},
        parse: (raw) => SquadCreated.fromJson(Map<String, dynamic>.from(raw as Map)),
      );

  Future<SquadMe?> me() async {
    try {
      return await _api.getData(
        '/api/squads/me',
        parse: (raw) => SquadMe.fromJson(Map<String, dynamic>.from(raw as Map)),
      );
    } catch (_) {
      return null;
    }
  }
}
