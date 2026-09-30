class VisitSession {
  const VisitSession({
    required this.id,
    required this.locationId,
    required this.mode,
  });

  final String id;
  final String locationId;
  final String mode;

  factory VisitSession.fromJson(Map<String, dynamic> json) {
    return VisitSession(
      id: json['id'] as String? ?? '',
      locationId: json['locationId'] as String? ?? '',
      mode: json['mode'] as String? ?? 'online',
    );
  }
}
