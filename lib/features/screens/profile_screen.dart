import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:histar_mobile/core/theme/app_theme.dart';
import 'package:histar_mobile/shared/providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(user?.displayName ?? '—', style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(user?.email ?? ''),
          ),
          const Divider(),
          ListTile(
            title: const Text('Tier'),
            trailing: Text(user?.tier ?? 'FREE', style: const TextStyle(color: AppColors.gold)),
          ),
          ListTile(
            title: const Text('Role'),
            trailing: Text(user?.role ?? 'USER'),
          ),
          ListTile(
            title: const Text('Premium'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/pricing'),
          ),
          if (user?.isTeacher == true)
            ListTile(
              title: const Text('Teacher dashboard'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/teacher'),
            ),
          if (user?.isAdmin == true)
            ListTile(
              title: const Text('Admin'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/admin'),
            ),
          ListTile(
            title: const Text('Cài đặt'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings'),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go('/onboarding');
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
