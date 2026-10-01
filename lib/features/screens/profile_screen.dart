import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:histar_mobile/core/config/env.dart';
import 'package:histar_mobile/core/native/histar_native.dart';
import 'package:histar_mobile/core/theme/app_theme.dart';
import 'package:histar_mobile/features/discovery/discovery_models.dart';
import 'package:histar_mobile/features/profile/passport_models.dart';
import 'package:histar_mobile/shared/providers.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

const _cuChiId = '11111111-1111-1111-1111-111111111111';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  List<UserBadge> _badges = [];
  bool _badgesLoading = true;
  List<PassportStamp> _passportStamps = [];
  bool _passportLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBadges();
    _loadPassport();
  }

  Future<void> _refresh() async {
    await ref.read(authControllerProvider.notifier).refreshProfileFromServer();
    await Future.wait([_loadBadges(), _loadPassport()]);
  }

  Future<void> _loadBadges() async {
    setState(() => _badgesLoading = true);
    try {
      final list = await ref.read(discoveryRepositoryProvider).myBadges();
      if (!mounted) return;
      setState(() {
        _badges = list;
        _badgesLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _badges = [];
        _badgesLoading = false;
      });
    }
  }

  Future<void> _sharePassportExport() async {
    final user = ref.read(authControllerProvider).user;
    final buf = StringBuffer()
      ..writeln('HistAR — Hộ chiếu số')
      ..writeln('${user?.displayName ?? '—'} · ${user?.email ?? ''}')
      ..writeln('XP: ${user?.totalPoints ?? 0} · Cấp ${user?.level ?? 1}')
      ..writeln('');
    if (_passportStamps.isEmpty) {
      buf.writeln('Chưa có tem check-in.');
    } else {
      for (final s in _passportStamps) {
        buf.writeln('- ${s.locationName ?? s.locationId}');
      }
    }
    final file = File('${Directory.systemTemp.path}/histar-passport-export.txt');
    await file.writeAsString(buf.toString());
    await HistarNative.shareFile(file.path, subject: 'Hộ chiếu số HistAR');
  }

  Future<void> _shareJourneyExport() async {
    final user = ref.read(authControllerProvider).user;
    final earned = _badges.where((b) => b.earned).map((b) => b.name).toList();
    final stampLines = _passportStamps
        .map((s) => '• ${s.locationName ?? s.locationId}')
        .join('\n');
    final buffer = StringBuffer()
      ..writeln('Hành trình HistAR — ${user?.displayName ?? 'Du khách'}')
      ..writeln('XP: ${user?.totalPoints ?? 0} · Cấp ${user?.level ?? 1}')
      ..writeln('');
    if (earned.isNotEmpty) {
      buffer.writeln('Huy hiệu: ${earned.join(', ')}');
    }
    if (_passportStamps.isNotEmpty) {
      buffer.writeln('Tem hộ chiếu số:');
      buffer.writeln(stampLines);
    }
    buffer.writeln('');
    buffer.writeln('Khám phá thêm: ${AppEnv.webAppUrl}/explore');
    buffer.writeln('#TimeLens #DiSanVietNam #CuChi');
    await HistarNative.shareText(
      subject: 'Hành trình HistAR',
      text: buffer.toString(),
    );
  }

  Future<void> _loadPassport() async {
    setState(() => _passportLoading = true);
    try {
      final direct = await ref.read(profileRepositoryProvider).passport();
      UserPassport passport;
      if (direct != null && direct.stamps.isNotEmpty) {
        passport = direct;
      } else {
        passport = await ref.read(profileRepositoryProvider).passportFromQuests(
              ref.read(locationsRepositoryProvider).list(size: 100),
              ref.read(gamificationRepositoryProvider).myCompletedQuests(size: 100),
            );
      }
      if (!mounted) return;
      setState(() {
        _passportStamps = passport.stamps;
        _passportLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _passportStamps = [];
        _passportLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final isFree = (user?.tier ?? 'FREE').toUpperCase() == 'FREE';
    final earned = _badges.where((b) => b.earned).toList();
    final dateFmt = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(user?.displayName ?? '—', style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(user?.email ?? ''),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tổng XP', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                          Text(
                            '${user?.totalPoints ?? 0}',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.gold),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Cấp', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                          Text(
                            '${user?.level ?? 1}',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 32),
            ListTile(
              title: const Text('Tier'),
              trailing: Text(user?.tier ?? 'FREE', style: const TextStyle(color: AppColors.gold)),
            ),
            ListTile(
              title: const Text('Email'),
              trailing: Text(
                user?.emailVerified == true
                    ? 'Đã xác minh'
                    : user?.emailVerified == false
                        ? 'Chưa xác minh'
                        : '—',
                style: TextStyle(
                  color: user?.emailVerified == true ? const Color(0xFF059669) : AppColors.muted,
                  fontSize: 13,
                ),
              ),
            ),
            ListTile(
              title: const Text('Role'),
              trailing: Text(user?.role ?? 'USER'),
            ),
            ListTile(
              title: const Text('Cổ vật Củ Chi'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/artifacts/$_cuChiId'),
            ),
            ListTile(
              title: const Text('Nhóm học tập (web)'),
              trailing: const Icon(Icons.open_in_new, size: 18),
              onTap: () => launchUrl(
                Uri.parse('${AppEnv.webAppUrl}/groups'),
                mode: LaunchMode.externalApplication,
              ),
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
            const SizedBox(height: 16),
            const Text('Huy hiệu đã đạt', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 8),
            if (_badgesLoading)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator(color: AppColors.orange)),
              )
            else if (earned.isEmpty)
              const Text(
                'Chưa có huy hiệu. Khám phá tour và hoàn thành nhiệm vụ để nhận.',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: earned
                    .map(
                      (b) => Chip(
                        avatar: const Icon(Icons.military_tech, size: 18, color: AppColors.gold),
                        label: Text(b.name, style: const TextStyle(fontSize: 12)),
                      ),
                    )
                    .toList(),
              ),
            if (_badges.isNotEmpty && _badges.any((b) => !b.earned)) ...[
              const SizedBox(height: 12),
              Text(
                'Còn ${_badges.where((b) => !b.earned).length} huy hiệu để săn thêm.',
                style: TextStyle(color: AppColors.muted.withValues(alpha: 0.9), fontSize: 12),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(
                  child: Text('Hộ chiếu số (tem)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                ),
                IconButton(
                  onPressed: _passportLoading ? null : _sharePassportExport,
                  icon: const Icon(Icons.share_outlined),
                  tooltip: 'Chia sẻ / xuất hộ chiếu',
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_passportLoading)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator(color: AppColors.orange)),
              )
            else if (_passportStamps.isEmpty)
              const Text(
                'Chưa có tem. Check-in tại di tích hoặc hoàn thành nhiệm vụ để đánh dấu.',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              )
            else
              ..._passportStamps.map(
                (stamp) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.verified, color: AppColors.gold),
                  title: Text(stamp.locationName ?? stamp.locationId),
                  subtitle: stamp.stampedAt != null
                      ? Text('Tem ngày ${dateFmt.format(stamp.stampedAt!.toLocal())}')
                      : null,
                ),
              ),
            if (isFree) ...[
              const SizedBox(height: 12),
              Card(
                color: AppColors.surfaceAlt,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Premium: tem AR & trải nghiệm đầy đủ',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Huy hiệu và tem số bạn đã kiếm vẫn hiển thị đầy đủ. Nâng cấp để mở stamp AR tại di tích và Time Portal.',
                        style: TextStyle(color: AppColors.muted.withValues(alpha: 0.95), fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: () => context.push('/pricing'),
                        child: const Text('Xem Premium'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _passportLoading && _badgesLoading ? null : _shareJourneyExport,
              icon: const Icon(Icons.ios_share),
              label: const Text('Chia sẻ hành trình'),
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
      ),
    );
  }
}
