class PassportStamp {
  const PassportStamp({
    required this.locationId,
    this.locationName,
    this.stampedAt,
  });

  final String locationId;
  final String? locationName;
  final DateTime? stampedAt;

  factory PassportStamp.fromJson(Map<String, dynamic> json) {
    final at = json['stampedAt'] ?? json['completedAt'];
    return PassportStamp(
      locationId: json['locationId'] as String? ?? '',
      locationName: json['locationName'] as String? ?? json['name'] as String?,
      stampedAt: at is String ? DateTime.tryParse(at) : null,
    );
  }
}

class UserPassport {
  const UserPassport({required this.stamps});

  final List<PassportStamp> stamps;

  factory UserPassport.fromJson(Map<String, dynamic> json) {
    final raw = json['stamps'] ?? json['entries'] ?? json['items'];
    if (raw is! List) {
      return const UserPassport(stamps: []);
    }
    return UserPassport(
      stamps: raw
          .whereType<Map>()
          .map((e) => PassportStamp.fromJson(Map<String, dynamic>.from(e)))
          .where((s) => s.locationId.isNotEmpty)
          .toList(),
    );
  }
}
