import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:histar_mobile/core/api/api_error.dart';
import 'package:histar_mobile/core/theme/app_theme.dart';
import 'package:histar_mobile/features/gamification/gamification_models.dart';
import 'package:histar_mobile/shared/providers.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  LeaderboardResult? _data;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ref.read(gamificationRepositoryProvider).leaderboard();
      if (!mounted) return;
      setState(() {
        _data = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  bool get _isPremium {
    final tier = ref.read(authControllerProvider).user?.tier?.toUpperCase();
    return tier == 'PREMIUM';
  }

  @override
  Widget build(BuildContext context) {
    final items = _data?.entries ?? const <LeaderboardEntry>[];
    final locked = _data?.viewerRankLocked == true;
    final viewerRank = _data?.viewerRank;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng xếp hạng'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading && _data == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
          : _error != null && _data == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _error is ApiError && (_error as ApiError).status == 403
                              ? 'Bảng xếp hạng đầy đủ dành cho Premium.\n${(_error as ApiError).message}'
                              : '$_error',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        if (_error is ApiError && (_error as ApiError).status == 403)
                          ElevatedButton(
                            onPressed: () => context.push('/pricing'),
                            child: const Text('Xem gói Premium'),
                          )
                        else
                          ElevatedButton(onPressed: _load, child: const Text('Thử lại')),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      if (locked && !_isPremium)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Card(
                            color: AppColors.surfaceAlt,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Top 10 cộng đồng',
                                    style: TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    viewerRank != null
                                        ? 'Thứ hạng của bạn bị ẩn trên gói Miễn phí (ước tính #$viewerRank).'
                                        : 'Thứ hạng cá nhân bị ẩn trên gói Miễn phí.',
                                    style: const TextStyle(color: AppColors.muted, fontSize: 13),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: () => context.push('/pricing'),
                                    child: const Text('Mở xếp hạng đầy đủ — Premium'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (items.isEmpty)
                        const SizedBox(
                          height: 120,
                          child: Center(child: Text('Chưa có dữ liệu')),
                        )
                      else
                        ...List.generate(items.length, (i) {
                          final e = items[i];
                          final rank = e.rank == 0 ? i + 1 : e.rank;
                          return Column(
                            children: [
                              if (i > 0) const Divider(height: 1),
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: e.currentUser
                                      ? AppColors.gold.withValues(alpha: 0.35)
                                      : AppColors.orange.withValues(alpha: 0.2),
                                  child: Text('$rank'),
                                ),
                                title: Text(
                                  e.displayName,
                                  style: TextStyle(
                                    fontWeight: e.currentUser ? FontWeight.w900 : FontWeight.w700,
                                  ),
                                ),
                                trailing: Text(
                                  '${e.totalPoints} XP',
                                  style: const TextStyle(color: AppColors.gold),
                                ),
                              ),
                            ],
                          );
                        }),
                    ],
                  ),
                ),
    );
  }
}
