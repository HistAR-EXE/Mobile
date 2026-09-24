import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:histar_mobile/core/theme/app_theme.dart';
import 'package:histar_mobile/features/auth/auth_state.dart';
import 'package:histar_mobile/shared/providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = ref.read(authControllerProvider);
      if (auth.bootstrapped) {
        _go(auth);
      }
    });
  }

  void _go(AuthState auth) {
    if (!auth.isAuthenticated) {
      context.go('/onboarding');
    } else if (auth.user!.needsEmailVerification) {
      context.go('/verify-email');
    } else if (auth.appMode == null) {
      context.go('/mode-select');
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (_, next) {
      if (next.bootstrapped) _go(next);
    });

    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.workspace_premium, size: 64, color: AppColors.orange),
            SizedBox(height: 16),
            Text('TimeLens', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            SizedBox(height: 24),
            CircularProgressIndicator(color: AppColors.orange),
          ],
        ),
      ),
    );
  }
}
