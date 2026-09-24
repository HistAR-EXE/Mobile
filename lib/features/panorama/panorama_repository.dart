import 'package:histar_mobile/core/api/api_client.dart';
import 'package:histar_mobile/features/panorama/panorama_models.dart';

class PanoramaRepository {
  PanoramaRepository(this._api);
  final ApiClient _api;

  Future<List<Panorama>> byLocation(String locationId) => _api.getList(
        '/api/panoramas/by-location/$locationId',
        parseItem: Panorama.fromJson,
      );

  Future<List<Hotspot>> hotspotsByPanorama(String panoramaId) => _api.getList(
        '/api/hotspots/by-panorama/$panoramaId',
        parseItem: Hotspot.fromJson,
      );
}
