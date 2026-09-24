import 'package:histar_mobile/core/api/api_client.dart';
import 'package:histar_mobile/features/locations/location_models.dart';

class LocationsRepository {
  LocationsRepository(this._api);
  final ApiClient _api;

  Future<List<HeritageLocation>> list({int page = 0, int size = 50}) =>
      _api.getList(
        '/api/locations',
        query: {'page': page, 'size': size},
        parseItem: HeritageLocation.fromJson,
      );

  Future<HeritageLocation> getById(String id) => _api.getData(
        '/api/locations/$id',
        parse: (raw) => HeritageLocation.fromJson(Map<String, dynamic>.from(raw as Map)),
      );

  Future<List<Character>> charactersByLocation(String locationId) =>
      _api.getList(
        '/api/characters/by-location/$locationId',
        parseItem: Character.fromJson,
      );
}
