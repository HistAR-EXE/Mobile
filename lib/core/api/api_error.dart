class ApiError implements Exception {
  ApiError({
    required this.message,
    this.code = 'INTERNAL_ERROR',
    this.status = 500,
    this.upgradeUrl,
    this.quotaType,
    this.upgradePackage,
  });

  final String message;
  final String code;
  final int status;
  final String? upgradeUrl;
  final String? quotaType;
  final String? upgradePackage;

  factory ApiError.fromBody(Map<String, dynamic>? body, int status) {
    return ApiError(
      message: (body?['message'] as String?) ?? 'Đã xảy ra lỗi',
      code: (body?['code'] as String?) ?? 'INTERNAL_ERROR',
      status: status,
      upgradeUrl: body?['upgradeUrl'] as String?,
      quotaType: body?['type'] as String?,
      upgradePackage: body?['upgradePackage'] as String?,
    );
  }

  bool get isQuota => status == 422 && (quotaType != null || code.contains('QUOTA'));

  @override
  String toString() => 'ApiError($status $code): $message';
}
