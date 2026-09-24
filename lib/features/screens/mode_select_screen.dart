import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:histar_mobile/core/theme/app_theme.dart';
import 'package:histar_mobile/shared/providers.dart';

class ModeSelectScreen extends ConsumerWidget {
  const ModeSelectScreen({super.key});

  Future<void> _pick(BuildContext context, WidgetRef ref, String mode) async {
    await ref.read(authControllerProvider.notifier).setAppMode(mode);
    if (!context.mounted) return;
    context.go(mode == 'offline' ? '/scan' : '/home');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn chế độ')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _ModeCard(
              title: 'Khám phá từ xa',
              subtitle: 'Tour 360°, Cổng thời gian, Chat AI, nhiệm vụ remote',
              icon: Icons.travel_explore,
              color: AppColors.blue,
              onTap: () => _pick(context, ref, 'online'),
            ),
            const SizedBox(height: 16),
            _ModeCard(
              title: 'Đang tại di tích',
              subtitle: 'Quét QR / GPS check-in, AR, khung ảnh',
              icon: Icons.qr_code_scanner,
              color: AppColors.orange,
              onTap: () => _pick(context, ref, 'offline'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.5)),
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.15), AppColors.surface],
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
