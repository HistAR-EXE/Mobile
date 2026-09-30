import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:histar_mobile/core/config/env.dart';
import 'package:histar_mobile/core/theme/app_theme.dart';
import 'package:histar_mobile/features/discovery/discovery_models.dart';
import 'package:histar_mobile/shared/providers.dart';

class ArtifactsScreen extends ConsumerStatefulWidget {
  const ArtifactsScreen({super.key, required this.locationId});

  final String locationId;

  @override
  ConsumerState<ArtifactsScreen> createState() => _ArtifactsScreenState();
}

class _ArtifactsScreenState extends ConsumerState<ArtifactsScreen> {
  List<ArtifactItem> _items = [];
  int _collected = 0;
  int _total = 0;
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final mine = await ref.read(discoveryRepositoryProvider).myArtifacts(widget.locationId);
      if (!mounted) return;
      setState(() {
        _items = mine.items;
        _collected = mine.collected;
        _total = mine.total;
        _loading = false;
      });
    } catch (e) {
      try {
        final catalog = await ref.read(discoveryRepositoryProvider).catalog(widget.locationId);
        if (!mounted) return;
        setState(() {
          _items = catalog;
          _collected = 0;
          _total = catalog.length;
          _loading = false;
        });
      } catch (e2) {
        if (!mounted) return;
        setState(() {
          _error = e2;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cổ vật')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
          : _error != null
              ? Center(child: Text('$_error'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        'Đã thu thập $_collected / $_total',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Mở khóa khi khám phá tour 360 hoặc hotspot liên quan.',
                        style: TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      if (_items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Center(child: Text('Chưa có cổ vật cho địa điểm này')),
                        ),
                      ..._items.map((a) {
                        final img = AppEnv.resolveMedia(a.imageUrl);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 56,
                                height: 56,
                                child: a.unlocked && img.isNotEmpty
                                    ? CachedNetworkImage(imageUrl: img, fit: BoxFit.cover)
                                    : Container(
                                        color: AppColors.surfaceAlt,
                                        child: Icon(
                                          a.unlocked ? Icons.museum : Icons.lock_outline,
                                          color: AppColors.muted,
                                        ),
                                      ),
                              ),
                            ),
                            title: Text(
                              a.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: a.unlocked ? null : AppColors.muted,
                              ),
                            ),
                            subtitle: Text(
                              a.unlocked ? a.description : 'Chưa mở khóa',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: a.unlocked
                                ? const Icon(Icons.check_circle, color: AppColors.gold)
                                : const Icon(Icons.lock, size: 18, color: AppColors.muted),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
    );
  }
}
