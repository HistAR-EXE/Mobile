import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:histar_mobile/core/config/env.dart';
import 'package:histar_mobile/core/theme/app_theme.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(Icons.workspace_premium, size: 72, color: AppColors.orange),
              const SizedBox(height: 16),
              const Text(
                'TimeLens',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Text(
                'Khám phá di sản Việt Nam qua Tour 360°, Cổng thời gian và AI Story Guide.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, height: 1.4),
              ),
              const SizedBox(height: 8),
              Text(
                'Time Portal đa kỷ nguyên và nhóm học tập có trên web: ${AppEnv.webAppUrl}',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted.withValues(alpha: 0.85), fontSize: 12, height: 1.35),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Đăng nhập'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go('/register'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: const Text('Tạo tài khoản'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
