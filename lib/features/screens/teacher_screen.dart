import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:histar_mobile/core/config/env.dart';
import 'package:histar_mobile/core/theme/app_theme.dart';
import 'package:histar_mobile/shared/providers.dart';
import 'package:url_launcher/url_launcher.dart';

class TeacherScreen extends ConsumerWidget {
  const TeacherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    if (user?.isTeacher != true && user?.isAdmin != true) {
      return const Scaffold(body: Center(child: Text('Cần quyền Teacher / Org')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Teacher')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Teacher dashboard MVP — mở web để giao bài / roster đầy đủ.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: const Text('Mở Teacher Dashboard (web)'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => launchUrl(
                Uri.parse('${AppEnv.webAppUrl}/teacher'),
                mode: LaunchMode.externalApplication,
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Assignments (web)'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => launchUrl(
                Uri.parse('${AppEnv.webAppUrl}/teacher/assignments'),
                mode: LaunchMode.externalApplication,
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Live Board (web)'),
              subtitle: const Text('SSE tiến độ đoàn tại điểm'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => launchUrl(
                Uri.parse('${AppEnv.webAppUrl}/teacher/live-board'),
                mode: LaunchMode.externalApplication,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
