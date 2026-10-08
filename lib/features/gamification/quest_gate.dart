import 'package:histar_mobile/features/gamification/cu_chi_keys.dart';
import 'package:histar_mobile/features/gamification/gamification_models.dart';

bool isDevQuest(Quest quest) => quest.id == devQuestId;

bool questMissingTourKeys(Quest quest, List<String> keys) {
  final need = quest.unlockDiscoveryKeys;
  if (need == null || need.trim().isEmpty) return false;
  final required = need.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
  return required.any((key) => !keys.contains(key));
}

String? questLockReason(Quest quest, List<String> keys) {
  if (!questMissingTourKeys(quest, keys)) return null;
  return 'Cần khám phá Bếp Hoàng Cầm và Phòng họp trong Tour 360 trước.';
}
