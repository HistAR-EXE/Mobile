class Panorama {
  const Panorama({
    required this.id,
    required this.locationId,
    required this.imageUrl,
    required this.title,
    this.areaSlug,
    this.sortOrder,
    this.defaultYaw,
    this.defaultPitch,
  });

  final String id;
  final String locationId;
  final String imageUrl;
  final String title;
  final String? areaSlug;
  final int? sortOrder;
  final double? defaultYaw;
  final double? defaultPitch;

  factory Panorama.fromJson(Map<String, dynamic> json) {
    return Panorama(
      id: json['id'] as String? ?? '',
      locationId: json['locationId'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      title: json['title'] as String? ?? '',
      areaSlug: json['areaSlug'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
      defaultYaw: (json['defaultYaw'] as num?)?.toDouble(),
      defaultPitch: (json['defaultPitch'] as num?)?.toDouble(),
    );
  }
}

class Hotspot {
  const Hotspot({
    required this.id,
    required this.panoramaId,
    required this.yaw,
    required this.pitch,
    required this.type,
    required this.contentRef,
    required this.label,
    this.markerStyle,
  });

  final String id;
  final String panoramaId;
  final double yaw;
  final double pitch;
  final String type; // info | scene
  final String contentRef;
  final String label;
  final String? markerStyle;

  factory Hotspot.fromJson(Map<String, dynamic> json) {
    return Hotspot(
      id: json['id'] as String? ?? '',
      panoramaId: json['panoramaId'] as String? ?? '',
      yaw: (json['yaw'] as num?)?.toDouble() ?? 0,
      pitch: (json['pitch'] as num?)?.toDouble() ?? 0,
      type: json['type'] as String? ?? 'info',
      contentRef: json['contentRef'] as String? ?? '',
      label: json['label'] as String? ?? '',
      markerStyle: json['markerStyle'] as String?,
    );
  }
}
