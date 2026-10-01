import 'package:histar_mobile/core/api/api_client.dart';

class DeviceRepository {
  DeviceRepository(this._api);

  final ApiClient _api;

  Future<void> registerPushToken({required String token, required String platform}) async {
    await _api.postData<void>(
      '/api/devices/push-token',
      data: {'token': token, 'platform': platform},
      parse: (_) {},
    );
  }
}
