import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:histar_mobile/core/theme/app_theme.dart';
import 'package:histar_mobile/shared/providers.dart';

const cuChiId = '11111111-1111-1111-1111-111111111111';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final mode = ref.watch(authControllerProvider).appMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TimeLens'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Xin chào, ${user?.displayName ?? 'Traveler'}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            mode == 'offline' ? 'Chế độ tại di tích' : 'Chế độ khám phá từ xa',
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          Text(
            'Cấp ${user?.level ?? 1} · ${user?.totalPoints ?? 0} XP',
            style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.gold),
          ),
          const SizedBox(height: 20),
          _QuickTile(
            title: 'Tour 360° Củ Chi',
            subtitle: '14 cảnh · xem ≥15 giây nhận XP',
            icon: Icons.threesixty,
            color: AppColors.orange,
            onTap: () => context.push('/tour/360/$cuChiId'),
          ),
          _QuickTile(
            title: 'Khám phá di tích',
            subtitle: 'Bản đồ & danh sách heritage',
            icon: Icons.explore,
            color: AppColors.blue,
            onTap: () => context.go('/explore'),
          ),
          _QuickTile(
            title: 'Cổ vật Củ Chi',
            subtitle: 'Bộ sưu tập đã mở khóa',
            icon: Icons.museum_outlined,
            color: const Color(0xFF7C3AED),
            onTap: () => context.push('/artifacts/$cuChiId'),
          ),
          _QuickTile(
            title: 'Nhiệm vụ',
            subtitle: 'Quest + XP + hộ chiếu',
            icon: Icons.flag,
            color: const Color(0xFF059669),
            onTap: () => context.go('/quests'),
          ),
          if (mode == 'offline')
            _QuickTile(
              title: 'Quét / Check-in',
              subtitle: 'QR hoặc GPS tại chỗ',
              icon: Icons.qr_code_scanner,
              color: AppColors.gold,
              onTap: () => context.push('/scan'),
            ),
          _QuickTile(
            title: 'Gói Premium',
            subtitle: 'Mở Time Portal 3 kỷ nguyên & AI không giới hạn',
            icon: Icons.workspace_premium,
            color: AppColors.gold,
            onTap: () => context.push('/pricing'),
          ),
        ],
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
