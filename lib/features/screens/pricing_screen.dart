import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:histar_mobile/core/config/env.dart';
import 'package:histar_mobile/core/theme/app_theme.dart';
import 'package:histar_mobile/features/billing/billing_models.dart';
import 'package:histar_mobile/shared/providers.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class PricingScreen extends ConsumerWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gói dịch vụ')),
      body: FutureBuilder<PublicPricing>(
        future: ref.read(billingRepositoryProvider).publicPricing(),
        builder: (context, snap) {
          if (!snap.hasData) {
            if (snap.hasError) {
              return Center(
                child: Text('Không tải giá (fallback 79.000đ).\n${snap.error}'),
              );
            }
            return const Center(child: CircularProgressIndicator(color: AppColors.orange));
          }
          final p = snap.data!;
          final fmt = NumberFormat.decimalPattern('vi_VN');
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.workspace_premium, color: AppColors.orange, size: 40),
                      const SizedBox(height: 8),
                      const Text('Premium cá nhân', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      Text(
                        '${fmt.format(p.b2cPremiumPriceVnd)}đ / tháng',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.gold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Time Portal 3 kỷ nguyên · Chat AI không giới hạn · Gamification đầy đủ',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Time Portal & nhóm học tập: mở trên web ${AppEnv.webAppUrl}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.muted.withValues(alpha: 0.9), fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.push('/checkout/b2c?next=${Uri.encodeComponent('/home')}'),
                        child: const Text('Thanh toán SePay'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Gói trường học', style: TextStyle(fontWeight: FontWeight.w800)),
              ...p.orgPlans.map(
                (plan) => Card(
                  child: ListTile(
                    title: Text(plan.label),
                    subtitle: Text(plan.planType),
                    trailing: Text('${fmt.format(plan.priceVnd)}đ'),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => launchUrl(
                  Uri.parse('${AppEnv.webAppUrl}/checkout/b2b'),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.school_outlined),
                label: const Text('Đăng ký gói trường (web)'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => launchUrl(
                  Uri.parse('${AppEnv.webAppUrl}/checkout/b2b2c'),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.museum_outlined),
                label: const Text('Tư vấn số hóa di tích (web)'),
              ),
            ],
          );
        },
      ),
    );
  }
}
