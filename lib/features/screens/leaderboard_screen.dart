import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:histar_mobile/core/theme/app_theme.dart';
import 'package:histar_mobile/features/gamification/gamification_models.dart';
import 'package:histar_mobile/shared/providers.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bảng xếp hạng')),
      body: FutureBuilder<List<LeaderboardEntry>>(
        future: ref.read(gamificationRepositoryProvider).leaderboard(),
        builder: (context, snap) {
          if (!snap.hasData) {
            if (snap.hasError) return Center(child: Text('${snap.error}'));
            return const Center(child: CircularProgressIndicator(color: AppColors.orange));
          }
          final items = snap.data!;
          if (items.isEmpty) return const Center(child: Text('Chưa có dữ liệu'));
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final e = items[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.orange.withValues(alpha: 0.2),
                  child: Text('${e.rank == 0 ? i + 1 : e.rank}'),
                ),
                title: Text(e.displayName, style: const TextStyle(fontWeight: FontWeight.w700)),
                trailing: Text('${e.totalPoints} XP', style: const TextStyle(color: AppColors.gold)),
              );
            },
          );
        },
      ),
    );
  }
}
