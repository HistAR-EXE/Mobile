import 'package:dio/dio.dart';
import 'package:histar_mobile/core/api/api_error.dart';
import 'package:histar_mobile/core/api/api_response.dart';
import 'package:histar_mobile/core/config/env.dart';
import 'package:histar_mobile/core/storage/session_storage.dart';

/// Dio client mirroring FE `httpClient` (Bearer + refresh on 401).
class ApiClient {
  ApiClient(this._session) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppEnv.apiBaseUrl,
        connectTimeout: const Duration(seconds: 45),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _session.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (err, handler) async {
          if (err.response?.statusCode == 401 && !_isRefreshCall(err.requestOptions)) {
            final refreshed = await _tryRefresh();
            if (refreshed) {
              final req = err.requestOptions;
              final token = await _session.getAccessToken();
              req.headers['Authorization'] = 'Bearer $token';
              try {
                final clone = await _dio.fetch(req);
                return handler.resolve(clone);
              } catch (e) {
                return handler.next(err);
              }
            }
          }
          handler.next(err);
        },
      ),
    );
  }

  final SessionStorage _session;
  late final Dio _dio;
  bool _refreshing = false;

  Dio get dio => _dio;

  bool _isRefreshCall(RequestOptions o) => o.path.contains('/api/auth/refresh');

  Future<bool> _tryRefresh() async {
    if (_refreshing) return false;
    final refresh = await _session.getRefreshToken();
    if (refresh == null || refresh.isEmpty) return false;
    _refreshing = true;
    try {
      final res = await Dio(
        BaseOptions(baseUrl: AppEnv.apiBaseUrl),
      ).post('/api/auth/refresh', data: {'refreshToken': refresh});
      final body = res.data;
      if (body is! Map<String, dynamic>) return false;
      final data = body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : body;
      final next = (data['accessToken'] as String?) ?? (data['token'] as String?);
      if (next == null) return false;
      final userId = await _session.getUserId() ?? '';
      final name = await _session.getDisplayName() ?? '';
      await _session.saveSession(
        accessToken: next,
        refreshToken: (data['refreshToken'] as String?) ?? refresh,
        userId: userId,
        displayName: name,
        email: await _session.getEmail(),
        role: await _session.getRole(),
        tier: await _session.getTier(),
        emailVerified: await _session.getEmailVerified(),
      );
      return true;
    } catch (_) {
      return false;
    } finally {
      _refreshing = false;
    }
  }

  Future<T> getData<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(Object? raw) parse,
  }) async {
    try {
      final res = await _dio.get(path, queryParameters: query);
      final data = res.data;
      return _unwrap(data, parse);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<List<T>> getList<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(Map<String, dynamic>) parseItem,
  }) async {
    return getData(path, query: query, parse: (raw) {
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map((e) => parseItem(Map<String, dynamic>.from(e)))
            .toList();
      }
      // PageResponse shape
      if (raw is Map && raw['items'] is List) {
        return (raw['items'] as List)
            .whereType<Map>()
            .map((e) => parseItem(Map<String, dynamic>.from(e)))
            .toList();
      }
      return <T>[];
    });
  }

  Future<PageResponse<T>> getPage<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(Map<String, dynamic>) parseItem,
  }) async {
    return getData(path, query: query, parse: (raw) {
      if (raw is Map<String, dynamic>) {
        return PageResponse.fromJson(raw, parseItem);
      }
      if (raw is Map) {
        return PageResponse.fromJson(Map<String, dynamic>.from(raw), parseItem);
      }
      return PageResponse<T>(items: [], page: 0, size: 0, totalItems: 0, totalPages: 0);
    });
  }

  Future<T> postData<T>(
    String path, {
    Object? data,
    required T Function(Object? raw) parse,
  }) async {
    try {
      final res = await _dio.post(path, data: data);
      final body = res.data;
      return _unwrap(body, parse);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<T> patchData<T>(
    String path, {
    Object? data,
    required T Function(Object? raw) parse,
  }) async {
    try {
      final res = await _dio.patch(path, data: data);
      final body = res.data;
      return _unwrap(body, parse);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  T _unwrap<T>(dynamic body, T Function(Object? raw) parse) {
    if (body is Map<String, dynamic>) {
      if (body.containsKey('success') && body.containsKey('data')) {
        if (body['success'] != true) {
          throw ApiError.fromBody(body, 400);
        }
        return parse(body['data']);
      }
      return parse(body);
    }
    return parse(body);
  }

  ApiError _mapDio(DioException e) {
    final status = e.response?.statusCode ?? 500;
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return ApiError.fromBody(data, status);
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiError(
        message: 'Máy chủ phản hồi chậm (cold start). Thử lại sau vài giây.',
        code: 'TIMEOUT',
        status: status,
      );
    }
    return ApiError(
      message: e.message ?? 'Không kết nối được máy chủ',
      code: 'NETWORK',
      status: status,
    );
  }
}
