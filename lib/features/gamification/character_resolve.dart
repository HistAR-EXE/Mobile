import 'package:histar_mobile/features/locations/location_models.dart';

/// Map quest unlock `dialogue:chi-nam` → character UUID from location catalog.
Character? resolveDialogueCharacter(List<Character> characters, String unlockKey) {
  var persona = unlockKey;
  if (persona.startsWith('dialogue:')) {
    persona = persona.substring('dialogue:'.length);
  }
  persona = persona.trim().toLowerCase();
  if (persona.isEmpty) return characters.isEmpty ? null : characters.first;

  for (final c in characters) {
    final name = c.name.toLowerCase();
    if (name.contains(persona.replaceAll('-', ' ')) ||
        name.contains(persona.replaceAll('-', '')) ||
        persona.contains(name.split(RegExp(r'\s+')).first)) {
      return c;
    }
  }
  // Chrono / Chi Nam common aliases
  if (persona.contains('chi') || persona.contains('chrono') || persona.contains('nam')) {
    for (final c in characters) {
      final n = c.name.toLowerCase();
      if (n.contains('chi') || n.contains('chrono') || n.contains('nam')) return c;
    }
  }
  if (persona.contains('anh') || persona.contains('ba')) {
    for (final c in characters) {
      final n = c.name.toLowerCase();
      if (n.contains('anh') || n.contains('ba')) return c;
    }
  }
  return characters.isEmpty ? null : characters.first;
}
