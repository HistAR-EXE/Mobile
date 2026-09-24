import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:histar_mobile/core/theme/app_theme.dart';
import 'package:histar_mobile/features/gamification/gamification_models.dart';
import 'package:histar_mobile/shared/providers.dart';

class QuestsScreen extends ConsumerWidget {
  const QuestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nhiệm vụ')),
      body: FutureBuilder<List<Quest>>(
        future: ref.read(gamificationRepositoryProvider).listQuests(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(color: AppColors.orange));
          }
          if (snap.hasError) {
            return Center(child: Text('${snap.error}'));
          }
          final items = snap.data ?? [];
          if (items.isEmpty) return const Center(child: Text('Chưa có nhiệm vụ'));
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final q = items[i];
              return Card(
                child: ListTile(
                  title: Text(q.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text(
                    '${q.pointsReward} XP · ${q.requireOnsiteCheckin == true ? 'Tại di tích' : 'Remote'}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/quests/${q.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
