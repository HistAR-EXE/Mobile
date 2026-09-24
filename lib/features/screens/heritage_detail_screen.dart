import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:histar_mobile/core/theme/app_theme.dart';
import 'package:histar_mobile/features/locations/location_models.dart';
import 'package:histar_mobile/shared/providers.dart';

class HeritageDetailScreen extends ConsumerStatefulWidget {
  const HeritageDetailScreen({super.key, required this.locationId});

  final String locationId;

  @override
  ConsumerState<HeritageDetailScreen> createState() => _HeritageDetailScreenState();
}

class _HeritageDetailScreenState extends ConsumerState<HeritageDetailScreen> {
  HeritageLocation? _loc;
  List<Character> _chars = [];
  Object? _error;
  bool _loading = true;

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
      final loc = await ref.read(locationsRepositoryProvider).getById(widget.locationId);
      final chars =
          await ref.read(locationsRepositoryProvider).charactersByLocation(widget.locationId);
      if (!mounted) return;
      setState(() {
        _loc = loc;
        _chars = chars;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_loc?.name ?? 'Chi tiết di tích')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
          : _error != null
              ? Center(child: Text('$_error'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(_loc!.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Text(_loc!.description, style: const TextStyle(color: AppColors.muted, height: 1.4)),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/tour/360/${widget.locationId}'),
                      icon: const Icon(Icons.threesixty),
                      label: const Text('Mở Tour 360°'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/quests'),
                      icon: const Icon(Icons.flag),
                      label: const Text('Xem nhiệm vụ'),
                    ),
                    const SizedBox(height: 24),
                    const Text('Nhân vật AI', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 8),
                    if (_chars.isEmpty)
                      const Text('Chưa có nhân vật', style: TextStyle(color: AppColors.muted))
                    else
                      ..._chars.map(
                        (c) => Card(
                          child: ListTile(
                            title: Text(c.name),
                            subtitle: Text(c.era),
                            trailing: const Icon(Icons.chat_bubble_outline),
                            onTap: () => context.push('/chat/${c.id}'),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}
