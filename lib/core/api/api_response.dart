class ApiResponse<T> {
  const ApiResponse({required this.success, required this.data, this.message});

  final bool success;
  final T data;
  final String? message;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? raw) parseData,
  ) {
    return ApiResponse(
      success: json['success'] == true,
      message: json['message'] as String?,
      data: parseData(json['data']),
    );
  }
}

class PageResponse<T> {
  const PageResponse({
    required this.items,
    required this.page,
    required this.size,
    required this.totalItems,
    required this.totalPages,
  });

  final List<T> items;
  final int page;
  final int size;
  final int totalItems;
  final int totalPages;

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemFromJson,
  ) {
    final rawItems = json['items'];
    final list = <T>[];
    if (rawItems is List) {
      for (final e in rawItems) {
        if (e is Map<String, dynamic>) list.add(itemFromJson(e));
      }
    }
    return PageResponse(
      items: list,
      page: (json['page'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? list.length,
      totalItems: (json['totalItems'] as num?)?.toInt() ?? list.length,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}
