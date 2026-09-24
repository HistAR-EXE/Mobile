import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:histar_mobile/core/config/env.dart';
import 'package:histar_mobile/core/theme/app_theme.dart';
import 'package:histar_mobile/shared/providers.dart';
import 'package:url_launcher/url_launcher.dart';

class VerifyEmailScreen extends ConsumerWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(authControllerProvider).user?.email ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Xác thực email')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.mark_email_unread, size: 64, color: AppColors.gold),
            const SizedBox(height: 16),
            Text(
              'Chúng tôi đã gửi liên kết xác thực tới\n$email',
              textAlign: TextAlign.center,
              style: const TextStyle(height: 1.4),
            ),
            const SizedBox(height: 12),
            const Text(
              'Sau khi xác thực trên web, mở lại app hoặc bấm “Đã xác thực”.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: () => launchUrl(
                Uri.parse('${AppEnv.webAppUrl}/verify-email/pending'),
                mode: LaunchMode.externalApplication,
              ),
              child: const Text('Mở trang xác thực (web)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).bootstrap();
                if (!context.mounted) return;
                final auth = ref.read(authControllerProvider);
                if (auth.user?.needsEmailVerification != true) {
                  context.go(auth.appMode == null ? '/mode-select' : '/home');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email chưa được xác thực trên server')),
                  );
                }
              },
              child: const Text('Đã xác thực — tiếp tục'),
            ),
            TextButton(
              onPressed: () => ref.read(authControllerProvider.notifier).logout(),
              child: const Text('Đăng xuất'),
            ),
          ],
        ),
      ),
    );
  }
}
