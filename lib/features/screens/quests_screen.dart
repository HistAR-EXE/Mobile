import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:histar_mobile/core/theme/app_theme.dart';
import 'package:histar_mobile/features/gamification/cu_chi_keys.dart';
import 'package:histar_mobile/features/gamification/gamification_models.dart';
import 'package:histar_mobile/features/gamification/quest_gate.dart';
import 'package:histar_mobile/shared/providers.dart';

class QuestsScreen extends ConsumerStatefulWidget {
  const QuestsScreen({super.key});

  @override
  ConsumerState<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends ConsumerState<QuestsScreen> {
  late Future<({List<Quest> quests, List<String> keys})> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<({List<Quest> quests, List<String> keys})> _load() async {
    final quests = await ref.read(gamificationRepositoryProvider).listQuests();
    var keys = <String>[];
    try {
      final summary = await ref.read(discoveryRepositoryProvider).summary(cuChiLocationId);
      keys = summary.keys;
    } catch (_) {}
    final filtered = quests.where((q) {
      if (isDevQuest(q) && !kDebugMode) return false;
      return true;
    }).toList();
    return (quests: filtered, keys: keys);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nhiệm vụ')),
      body: FutureBuilder<({List<Quest> quests, List<String> keys})>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(color: AppColors.orange));
          }
          if (snap.hasError) {
            return Center(child: Text('${snap.error}'));
          }
          final data = snap.data!;
          final items = data.quests;
          if (items.isEmpty) return const Center(child: Text('Chưa có nhiệm vụ'));
          return RefreshIndicator(
            onRefresh: () async {
              setState(() => _future = _load());
              await _future;
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final q = items[i];
                final locked = questMissingTourKeys(q, data.keys);
                final reason = questLockReason(q, data.keys);
                return Card(
                  child: ListTile(
                    title: Text(q.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text(
                      locked
                          ? (reason ?? 'Chưa mở khóa')
                          : '${q.pointsReward} XP · ${q.requireOnsiteCheckin == true ? 'Tại di tích' : 'Remote'}',
                    ),
                    trailing: Icon(locked ? Icons.lock : Icons.chevron_right),
                    onTap: () => context.push('/quests/${q.id}'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
