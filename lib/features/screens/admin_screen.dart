import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:histar_mobile/core/config/env.dart';
import 'package:histar_mobile/core/theme/app_theme.dart';
import 'package:histar_mobile/shared/providers.dart';
import 'package:url_launcher/url_launcher.dart';

/// Phase-3 stub: deep-link to FE admin for full CRUD; shows role gate.
class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    if (user?.isAdmin != true) {
      return const Scaffold(body: Center(child: Text('Cần quyền ADMIN')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Admin')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Admin đầy đủ đang trên web. Mobile mở deep-link các module chính.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          ...[
            ('Người dùng', '/admin/users'),
            ('Nội dung', '/admin/content'),
            ('Analytics', '/admin/analytics'),
            ('Billing', '/admin/billing'),
            ('Organizations', '/admin/organizations'),
          ].map(
            (e) => Card(
              child: ListTile(
                title: Text(e.$1),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => launchUrl(
                  Uri.parse('${AppEnv.webAppUrl}${e.$2}'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
