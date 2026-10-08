import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:histar_mobile/core/theme/app_theme.dart';
import 'package:histar_mobile/features/gamification/gamification_models.dart';
import 'package:histar_mobile/features/gamification/quest_gate.dart';
import 'package:histar_mobile/features/gamification/quest_journey.dart';
import 'package:histar_mobile/shared/providers.dart';

class QuestDetailScreen extends ConsumerStatefulWidget {
  const QuestDetailScreen({super.key, required this.questId});

  final String questId;

  @override
  ConsumerState<QuestDetailScreen> createState() => _QuestDetailScreenState();
}

class _QuestDetailScreenState extends ConsumerState<QuestDetailScreen> {
  Quest? _quest;
  QuestProgress? _progress;
  List<String> _keys = [];
  bool _loading = true;
  String? _error;

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
      final q = await ref.read(gamificationRepositoryProvider).getQuest(widget.questId);
      final p = await ref.read(gamificationRepositoryProvider).myProgress(widget.questId);
      var keys = <String>[];
      try {
        final summary = await ref.read(discoveryRepositoryProvider).summary(q.locationId);
        keys = summary.keys;
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _quest = q;
        _progress = p;
        _keys = keys;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _start() async {
    try {
      final p = await ref.read(gamificationRepositoryProvider).startQuest(widget.questId);
      setState(() => _progress = p);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã bắt đầu nhiệm vụ')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final quest = _quest;
    final lockReason = quest == null ? null : questLockReason(quest, _keys);

    return Scaffold(
      appBar: AppBar(title: Text(quest?.title ?? 'Nhiệm vụ')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(quest!.description, style: const TextStyle(color: AppColors.muted, height: 1.4)),
                    if (quest.story != null && quest.story!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(quest.story!, style: const TextStyle(height: 1.4)),
                    ],
                    const SizedBox(height: 12),
                    Text('Thưởng: ${quest.pointsReward} XP', style: const TextStyle(fontWeight: FontWeight.w700)),
                    if (_progress != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Tiến độ: ${_progress!.currentStep}/${_progress!.stepsTotal} · ${_progress!.status}',
                      ),
                    ],
                    if (lockReason != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.orange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.orange.withValues(alpha: 0.4)),
                        ),
                        child: Text(lockReason, style: const TextStyle(color: AppColors.gold)),
                      ),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: lockReason != null ? null : _start,
                      child: Text(_progress == null ? 'Bắt đầu' : 'Tiếp tục / Start lại'),
                    ),
                    const SizedBox(height: 20),
                    QuestJourney(
                      quest: quest,
                      status: _progress?.status ?? 'not_started',
                      currentStep: _progress?.currentStep ?? 0,
                      discoveryKeys: _keys,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () async {
                        await context.push('/tour/360/${quest.locationId}');
                        if (mounted) await _load();
                      },
                      child: const Text('Mở Tour 360° liên quan'),
                    ),
                    TextButton(onPressed: _load, child: const Text('Làm mới tiến độ')),
                  ],
                ),
    );
  }
}
