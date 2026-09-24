class HeritageLocation {
  const HeritageLocation({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.coverImage,
    this.isUnlocked,
    this.googleMapsUrl,
  });

  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String city;
  final String coverImage;
  final bool? isUnlocked;
  final String? googleMapsUrl;

  factory HeritageLocation.fromJson(Map<String, dynamic> json) {
    return HeritageLocation(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      city: json['city'] as String? ?? '',
      coverImage: json['coverImage'] as String? ?? '',
      isUnlocked: json['isUnlocked'] as bool?,
      googleMapsUrl: json['googleMapsUrl'] as String?,
    );
  }
}

class Character {
  const Character({
    required this.id,
    required this.locationId,
    required this.name,
    required this.era,
    required this.portraitUrl,
  });

  final String id;
  final String locationId;
  final String name;
  final String era;
  final String portraitUrl;

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as String? ?? '',
      locationId: json['locationId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      era: json['era'] as String? ?? '',
      portraitUrl: json['portraitUrl'] as String? ?? '',
    );
  }
}
