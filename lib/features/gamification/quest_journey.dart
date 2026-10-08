import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:histar_mobile/core/theme/app_theme.dart';
import 'package:histar_mobile/features/gamification/character_resolve.dart';
import 'package:histar_mobile/features/gamification/cu_chi_keys.dart';
import 'package:histar_mobile/features/gamification/gamification_models.dart';
import 'package:histar_mobile/shared/providers.dart';

class QuestJourney extends ConsumerWidget {
  const QuestJourney({
    super.key,
    required this.quest,
    required this.status,
    required this.currentStep,
    this.discoveryKeys = const [],
  });

  final Quest quest;
  final String status;
  final int currentStep;
  final List<String> discoveryKeys;

  bool _isPremiumPortal(QuestStep step) {
    if (step.actionType != 'portal') return false;
    final era = step.portalEra;
    return era == 1948 || era == 1968;
  }

  Future<void> _openStep(BuildContext context, WidgetRef ref, QuestStep step) async {
    final locationId = quest.locationId;
    final auth = ref.read(authControllerProvider);
    final isFree = (auth.user?.tier ?? 'FREE').toUpperCase() == 'FREE';
    final role = (auth.user?.role ?? '').toUpperCase();
    final showPaywall = isFree && role != 'ADMIN' && role != 'TEACHER';

    if (showPaywall && _isPremiumPortal(step) && status != 'completed') {
      final go = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Cổng ${step.portalEra ?? 1948} cần Premium'),
          content: const Text('Nâng cấp để mở mốc 1948 và 1968.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Đóng')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Xem Pricing'),
            ),
          ],
        ),
      );
      if (go == true && context.mounted) {
        await context.push('/pricing');
      }
      return;
    }

    switch (step.actionType) {
      case 'tour':
        final params = <String, String>{'questRecord': step.unlockKey};
        if (step.unlockKey == saBanQuestKey) {
          params['view'] = 'illustrated';
        } else if (step.unlockKey == tramXaQuestKey) {
          params['panorama'] = tramXaPanoramaId;
          params['view'] = 'panorama';
        } else if (step.unlockKey.startsWith('scene:')) {
          params['panorama'] = step.unlockKey.substring('scene:'.length);
        }
        final q = Uri(queryParameters: params).query;
        await context.push('/tour/360/$locationId?$q');
        return;
      case 'portal':
        final era = step.portalEra ?? 2026;
        final params = <String, String>{
          'era': '$era',
          if (step.unlockKey.startsWith('era:')) 'questRecord': step.unlockKey,
        };
        final q = Uri(queryParameters: params).query;
        await context.push('/web/time-portal/$locationId?$q');
        return;
      case 'minigame':
        final mid = step.minigameId;
        if (mid == null || mid.isEmpty) return;
        await context.push('/web/quests/${quest.id}/play/$mid');
        return;
      case 'dialogue':
        final chars = await ref.read(locationsRepositoryProvider).charactersByLocation(locationId);
        final character = resolveDialogueCharacter(chars, step.unlockKey);
        if (!context.mounted) return;
        if (character == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chưa có nhân vật chat cho địa điểm này.')),
          );
          return;
        }
        final params = <String, String>{
          'locationId': locationId,
          'questRecord': step.unlockKey,
          'questId': quest.id,
          if (step.chatPrompt != null && step.chatPrompt!.isNotEmpty)
            'questPrompt': step.chatPrompt!,
        };
        final q = Uri(queryParameters: params).query;
        await context.push('/chat/${character.id}?$q');
        return;
      case 'artifact':
        await context.push('/artifacts/$locationId');
        return;
      case 'checkin':
        await context.push('/scan');
        return;
      default:
        await context.push('/explore/$locationId');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final steps = quest.steps;
    if (steps.isEmpty) {
      return const Text('Chưa có chương trong mật lệnh này.', style: TextStyle(color: AppColors.muted));
    }
    final auth = ref.watch(authControllerProvider);
    final isFree = (auth.user?.tier ?? 'FREE').toUpperCase() == 'FREE';
    final role = (auth.user?.role ?? '').toUpperCase();
    final showPaywall = isFree && role != 'ADMIN' && role != 'TEACHER';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Hành trình', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        const SizedBox(height: 12),
        for (var i = 0; i < steps.length; i++) ...[
          _StepTile(
            step: steps[i],
            index: i,
            completed: status == 'completed' || currentStep > i,
            active: status == 'in_progress' && currentStep == i,
            locked: status == 'not_started' || (status == 'in_progress' && currentStep < i),
            portalLocked: showPaywall &&
                _isPremiumPortal(steps[i]) &&
                status != 'completed' &&
                !discoveryKeys.contains(steps[i].unlockKey),
            onTap: () => _openStep(context, ref, steps[i]),
          ),
          if (i < steps.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.step,
    required this.index,
    required this.completed,
    required this.active,
    required this.locked,
    required this.portalLocked,
    required this.onTap,
  });

  final QuestStep step;
  final int index;
  final bool completed;
  final bool active;
  final bool locked;
  final bool portalLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dim = locked || portalLocked;
    final label = step.actionLabel ?? 'TRUY XUẤT';
    return Opacity(
      opacity: dim ? 0.45 : 1,
      child: Material(
        color: const Color(0xFF1B1E2C),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: dim && !portalLocked ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: completed
                          ? const Color(0xFF10B981)
                          : active
                              ? AppColors.orange
                              : Colors.white24,
                    ),
                  ),
                  child: Text(
                    completed ? '✓' : '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: completed ? const Color(0xFF10B981) : AppColors.gold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(step.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(step.objective, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                      if (portalLocked)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text('Premium', style: TextStyle(color: AppColors.orange, fontSize: 11)),
                        ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onTap,
                  child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
