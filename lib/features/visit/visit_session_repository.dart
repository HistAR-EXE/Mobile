import 'package:histar_mobile/core/api/api_client.dart';
import 'package:histar_mobile/features/visit/visit_session_models.dart';

class VisitSessionRepository {
  VisitSessionRepository(this._api);
  final ApiClient _api;

  /// Starts analytics visit session (`POST /api/me/visit-sessions/start`).
  Future<VisitSession> start({
    required String locationId,
    required String mode,
  }) =>
      _api.postData(
        '/api/me/visit-sessions/start',
        data: {
          'locationId': locationId,
          'mode': mode,
        },
        parse: (raw) => VisitSession.fromJson(Map<String, dynamic>.from(raw as Map)),
      );

  Future<void> end(String sessionId, {String reason = 'USER_EXIT'}) async {
    try {
      await _api.patchData(
        '/api/me/visit-sessions/$sessionId/end',
        data: {'reason': reason},
        parse: (_) {},
      );
    } catch (_) {
      // Best-effort on screen exit.
    }
  }
}
