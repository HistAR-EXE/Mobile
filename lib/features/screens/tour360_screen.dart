import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:histar_mobile/core/config/env.dart';
import 'package:histar_mobile/core/theme/app_theme.dart';
import 'package:histar_mobile/features/panorama/panorama_models.dart';
import 'package:histar_mobile/features/visit/screen_visit_session.dart';
import 'package:histar_mobile/shared/providers.dart';
import 'package:panorama_viewer/panorama_viewer.dart' as pv;
import 'package:webview_flutter/webview_flutter.dart';

/// Phase-1 Tour 360: native scenes + dwell discovery XP (parity with FE Tour360Page).
class Tour360Screen extends ConsumerStatefulWidget {
  const Tour360Screen({super.key, required this.locationId});

  final String locationId;

  @override
  ConsumerState<Tour360Screen> createState() => _Tour360ScreenState();
}

class _Tour360ScreenState extends ConsumerState<Tour360Screen> with WidgetsBindingObserver {
  List<Panorama> _panos = [];
  List<Hotspot> _hotspots = [];
  int _index = 0;
  bool _loading = true;
  Object? _error;
  bool _webMode = false;
  String? _webError;
  WebViewController? _web;
  bool _flatFallback = false;

  final Set<String> _recordedScenes = {};
  Timer? _dwellTimer;
  bool _recording = false;
  late final ScreenVisitSession _visitSession;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _visitSession = ScreenVisitSession(ref);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_visitSession.startIfAuthenticated(
        locationId: widget.locationId,
        mode: 'online',
      ));
    });
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clearDwell();
    unawaited(_visitSession.end());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _clearDwell();
      return;
    }
    if (!_webMode && _panos.isNotEmpty) _armSceneDwell();
  }

  void _clearDwell() {
    _dwellTimer?.cancel();
    _dwellTimer = null;
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await ref.read(panoramaRepositoryProvider).byLocation(widget.locationId);
      list.sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0));
      try {
        final summary = await ref.read(discoveryRepositoryProvider).summary(widget.locationId);
        for (final key in summary.keys) {
          if (key.startsWith('scene:')) {
            _recordedScenes.add(key.substring('scene:'.length));
          }
        }
      } catch (_) {
        // Offline / unauth — dwell will no-op on POST failure.
      }
      if (!mounted) return;
      setState(() {
        _panos = list;
        _loading = false;
      });
      if (list.isNotEmpty) {
        await _loadHotspots(list.first.id);
        _armSceneDwell();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _loadHotspots(String panoramaId) async {
    try {
      final hs = await ref.read(panoramaRepositoryProvider).hotspotsByPanorama(panoramaId);
      if (!mounted) return;
      setState(() => _hotspots = hs);
    } catch (_) {
      if (!mounted) return;
      setState(() => _hotspots = []);
    }
  }

  Future<void> _goScene(int i) async {
    _clearDwell();
    setState(() {
      _index = i;
      _flatFallback = false;
    });
    await _loadHotspots(_panos[i].id);
    _precacheNext();
    _armSceneDwell();
  }

  void _precacheNext() {
    final next = _index + 1;
    if (next >= _panos.length || !mounted) return;
    final url = AppEnv.resolveMedia(_panos[next].imageUrl);
    if (url.isEmpty) return;
    precacheImage(NetworkImage(url), context);
  }

  /// Photo Sphere stores yaw/pitch in radians. Values already outside ±2π stay as degrees.
  double _toDegrees(double value) {
    if (value.abs() > math.pi * 2) return value;
    return value * 180 / math.pi;
  }

  void _armSceneDwell() {
    _clearDwell();
    if (_webMode || _panos.isEmpty) return;
    final pano = _panos[_index];
    if (_recordedScenes.contains(pano.id)) return;

    final dwellMs = AppEnv.discoveryDwellMs;
    if (dwellMs <= 0) {
      unawaited(_recordScene(pano.id));
      return;
    }
    _dwellTimer = Timer(Duration(milliseconds: dwellMs), () {
      unawaited(_recordScene(pano.id));
    });
  }

  Future<void> _recordScene(String panoramaId) async {
    if (_recording || _recordedScenes.contains(panoramaId) || _webMode) return;
    _recording = true;
    try {
      final result = await ref.read(discoveryRepositoryProvider).record(
            unlockKey: 'scene:$panoramaId',
            locationId: widget.locationId,
            source: 'tour_panorama',
          );
      _recordedScenes.add(panoramaId);
      if (result.recorded && result.xpEarned > 0 && mounted) {
        await ref.read(authControllerProvider.notifier).refreshProfileFromServer();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('+${result.xpEarned} XP — đã khám phá cảnh')),
        );
      }
    } catch (_) {
      // Keep silent; user can retry by re-entering scene.
    } finally {
      _recording = false;
    }
  }

  void _openWebTour({bool mapView = false}) {
    final path = mapView
        ? '/tour/360/${widget.locationId}?view=map'
        : '/tour/360/${widget.locationId}';
    final url = '${AppEnv.webAppUrl}$path';
    if (!url.startsWith('https://')) {
      setState(() {
        _webMode = true;
        _webError = 'Tour web cần HTTPS. Kiểm tra WEB_APP_URL.';
        _web = null;
      });
      return;
    }
    _clearDwell();
    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {
            if (!mounted) return;
            setState(() => _webError = error.description);
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
    setState(() {
      _webError = null;
      _webMode = true;
    });
  }

  Widget _flatViewer(String url) {
    return InteractiveViewer(
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.contain,
        width: double.infinity,
        placeholder: (_, _) => const Center(child: CircularProgressIndicator(color: AppColors.orange)),
        errorWidget: (_, _, _) => const Center(child: Icon(Icons.broken_image)),
      ),
    );
  }

  Widget _sceneViewer() {
    final pano = _panos[_index];
    final url = AppEnv.resolveMedia(pano.imageUrl);
    if (_flatFallback || url.isEmpty) return _flatViewer(url);
    final sceneHotspots = _hotspots.where((h) => h.type == 'scene').toList();
    return pv.PanoramaViewer(
      key: ValueKey(pano.id),
      latitude: _toDegrees(pano.defaultPitch ?? 0),
      longitude: _toDegrees(pano.defaultYaw ?? 0),
      sensorControl: pv.SensorControl.none,
      hotspots: [
        for (final h in sceneHotspots)
          pv.Hotspot(
            name: h.id,
            latitude: _toDegrees(h.pitch),
            longitude: _toDegrees(h.yaw),
            width: 140,
            height: 36,
            widget: ActionChip(
              label: Text(h.label, style: const TextStyle(fontSize: 12)),
              onPressed: () {
                final idx = _panos.indexWhere((p) => p.id == h.contentRef);
                if (idx >= 0) _goScene(idx);
              },
            ),
          ),
      ],
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _flatFallback = true);
          });
          return const SizedBox.shrink();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_webMode) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tour 360° (Web)'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => _webMode = false);
                _armSceneDwell();
              },
              child: const Text('Native'),
            ),
          ],
        ),
        body: Column(
          children: [
            if (_webError != null)
              MaterialBanner(
                content: Text('Không tải được tour web: $_webError'),
                actions: [
                  TextButton(
                    onPressed: () => setState(() => _webError = null),
                    child: const Text('Đóng'),
                  ),
                ],
              ),
            Expanded(
              child: _web == null
                  ? const Center(child: Text('Không mở được viewer web.'))
                  : WebViewWidget(controller: _web!),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_panos.isEmpty ? 'Tour 360°' : '${_index + 1}/${_panos.length}'),
        actions: [
          IconButton(
            tooltip: 'Bản đồ tour (web)',
            onPressed: () => _openWebTour(mapView: true),
            icon: const Icon(Icons.map_outlined),
          ),
          IconButton(
            tooltip: 'Mở viewer web đầy đủ',
            onPressed: () => _openWebTour(),
            icon: const Icon(Icons.open_in_browser),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
          : _error != null
              ? Center(child: Text('$_error'))
              : _panos.isEmpty
                  ? const Center(child: Text('Chưa có panorama'))
                  : Column(
                      children: [
                        Expanded(child: _sceneViewer()),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          color: AppColors.surfaceAlt,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _panos[_index].title,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                              Text(
                                _recordedScenes.contains(_panos[_index].id)
                                    ? 'Đã khám phá · ${_panos.length} cảnh'
                                    : 'Xem ≥15 giây để nhận XP · ${_panos.length} cảnh',
                                style: const TextStyle(color: AppColors.muted, fontSize: 12),
                              ),
                              if (_panos[_index].areaSlug != null)
                                Text('Khu: ${_panos[_index].areaSlug}', style: const TextStyle(color: AppColors.muted)),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 36,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: _hotspots
                                      .where((h) => h.type == 'scene')
                                      .map(
                                        (h) => Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: ActionChip(
                                            label: Text(h.label, style: const TextStyle(fontSize: 12)),
                                            onPressed: () {
                                              final idx = _panos.indexWhere((p) => p.id == h.contentRef);
                                              if (idx >= 0) _goScene(idx);
                                            },
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: _index > 0 ? () => _goScene(_index - 1) : null,
                                    icon: const Icon(Icons.chevron_left),
                                  ),
                                  const Text('Scene'),
                                  IconButton(
                                    onPressed:
                                        _index < _panos.length - 1 ? () => _goScene(_index + 1) : null,
                                    icon: const Icon(Icons.chevron_right),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () => _openWebTour(mapView: true),
                                    child: const Text('Bản đồ'),
                                  ),
                                  TextButton(
                                    onPressed: () => _openWebTour(),
                                    child: const Text('Viewer đầy đủ'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }
}
