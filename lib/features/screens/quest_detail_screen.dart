import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:histar_mobile/core/theme/app_theme.dart';
import 'package:histar_mobile/features/gamification/gamification_models.dart';
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
      if (!mounted) return;
      setState(() {
        _quest = q;
        _progress = p;
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
    return Scaffold(
      appBar: AppBar(title: Text(_quest?.title ?? 'Nhiệm vụ')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(_quest!.description, style: const TextStyle(color: AppColors.muted, height: 1.4)),
                    const SizedBox(height: 12),
                    Text('Thưởng: ${_quest!.pointsReward} XP', style: const TextStyle(fontWeight: FontWeight.w700)),
                    if (_progress != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Tiến độ: ${_progress!.currentStep}/${_progress!.stepsTotal} · ${_progress!.status}',
                      ),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _start,
                      child: Text(_progress == null ? 'Bắt đầu' : 'Tiếp tục / Start lại'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => context.push('/tour/360/${_quest!.locationId}'),
                      child: const Text('Mở Tour 360° liên quan'),
                    ),
                  ],
                ),
    );
  }
}
