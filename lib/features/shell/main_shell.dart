import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:histar_mobile/core/theme/app_theme.dart';
import 'package:histar_mobile/shared/providers.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(authControllerProvider).appMode;
    final destinations = <NavigationDestination>[
      const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
      NavigationDestination(
        icon: Icon(mode == 'offline' ? Icons.qr_code_scanner_outlined : Icons.explore_outlined),
        selectedIcon: Icon(mode == 'offline' ? Icons.qr_code_scanner : Icons.explore),
        label: mode == 'offline' ? 'Quét' : 'Khám phá',
      ),
      const NavigationDestination(icon: Icon(Icons.flag_outlined), selectedIcon: Icon(Icons.flag), label: 'Nhiệm vụ'),
      const NavigationDestination(icon: Icon(Icons.emoji_events_outlined), selectedIcon: Icon(Icons.emoji_events), label: 'BXH'),
      const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Hồ sơ'),
    ];

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: destinations,
        onDestinationSelected: (index) {
          if (index == 1 && mode == 'offline') {
            context.push('/scan');
            return;
          }
          navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
        },
        indicatorColor: AppColors.orange.withValues(alpha: 0.25),
      ),
    );
  }
}
