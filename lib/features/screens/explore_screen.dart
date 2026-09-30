import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:histar_mobile/core/config/env.dart';
import 'package:histar_mobile/core/theme/app_theme.dart';
import 'package:histar_mobile/features/locations/location_models.dart';
import 'package:histar_mobile/shared/providers.dart';

final _locationsProvider = FutureProvider.autoDispose<List<HeritageLocation>>((ref) {
  return ref.watch(locationsRepositoryProvider).list();
});

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_locationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Khám phá')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.orange)),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Không tải được danh sách.\n$e', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.invalidate(_locationsProvider),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Chưa có di tích'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_locationsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final loc = items[i];
                final cover = AppEnv.resolveMedia(loc.coverImage);
                const cuChiId = '11111111-1111-1111-1111-111111111111';
                final isCuChi = loc.id == cuChiId;
                final comingSoon = !isCuChi && loc.isUnlocked == false;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => context.push('/explore/${loc.id}'),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 96,
                          height: 96,
                          child: cover.isEmpty
                              ? Container(color: AppColors.surfaceAlt, child: const Icon(Icons.place))
                              : CachedNetworkImage(imageUrl: cover, fit: BoxFit.cover),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(loc.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                                const SizedBox(height: 4),
                                Text(loc.city, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                                if (comingSoon)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 6),
                                    child: Text('Sắp mở — nội dung đang bổ sung', style: TextStyle(fontSize: 12, color: AppColors.gold)),
                                  )
                                else if (loc.isUnlocked == false)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 6),
                                    child: Text('Chưa mở khóa', style: TextStyle(fontSize: 12, color: AppColors.gold)),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
