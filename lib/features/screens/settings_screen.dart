import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:histar_mobile/core/config/env.dart';
import 'package:histar_mobile/core/theme/app_theme.dart';
import 'package:histar_mobile/shared/providers.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(authControllerProvider).appMode;
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Đổi chế độ Online / Offline'),
            subtitle: Text(mode ?? 'chưa chọn'),
            onTap: () => context.push('/mode-select'),
          ),
          ListTile(
            title: const Text('Chính sách quyền riêng tư'),
            onTap: () => launchUrl(
              Uri.parse('${AppEnv.webAppUrl}/privacy'),
              mode: LaunchMode.externalApplication,
            ),
          ),
          ListTile(
            title: const Text('Điều khoản sử dụng'),
            onTap: () => launchUrl(
              Uri.parse('${AppEnv.webAppUrl}/terms'),
              mode: LaunchMode.externalApplication,
            ),
          ),
          ListTile(
            title: const Text('Mở web app'),
            subtitle: Text(AppEnv.webAppUrl, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            onTap: () => launchUrl(Uri.parse(AppEnv.webAppUrl), mode: LaunchMode.externalApplication),
          ),
          const Divider(),
          ListTile(
            title: const Text('API'),
            subtitle: Text(AppEnv.apiBaseUrl, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
