import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:histar_mobile/core/theme/app_theme.dart';
import 'package:histar_mobile/features/screens/home_screen.dart';
import 'package:histar_mobile/shared/providers.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  bool _busy = false;
  String? _result;
  bool _showScanner = false;
  bool _cameraDenied = false;
  String? _lastQr;
  DateTime? _lastQrAt;

  Future<void> _checkinGps() async {
    setState(() {
      _busy = true;
      _result = null;
    });
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        throw Exception('Cần quyền vị trí để check-in GPS');
      }
      final pos = await Geolocator.getCurrentPosition();
      final res = await ref.read(gamificationRepositoryProvider).checkin(
            locationId: cuChiId,
            latitude: pos.latitude,
            longitude: pos.longitude,
          );
      setState(() => _result = 'Check-in OK: ${res['message'] ?? res.toString()}');
    } catch (e) {
      setState(() => _result = 'Lỗi: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _toggleScanner() async {
    if (_showScanner) {
      setState(() => _showScanner = false);
      return;
    }
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    if (!status.isGranted) {
      setState(() {
        _cameraDenied = true;
        _showScanner = false;
        _result = status.isPermanentlyDenied
            ? 'Camera bị từ chối vĩnh viễn. Mở Cài đặt để cấp quyền.'
            : 'Cần quyền camera để quét QR.';
      });
      return;
    }
    setState(() {
      _cameraDenied = false;
      _showScanner = true;
    });
  }

  Future<void> _onQr(String raw) async {
    if (_busy) return;
    final now = DateTime.now();
    if (_lastQr == raw &&
        _lastQrAt != null &&
        now.difference(_lastQrAt!) < const Duration(seconds: 3)) {
      return;
    }
    _lastQr = raw;
    _lastQrAt = now;
    setState(() {
      _busy = true;
      _result = null;
    });
    try {
      final res = await ref.read(gamificationRepositoryProvider).checkin(
            locationId: cuChiId,
            qrPayload: raw,
          );
      setState(() {
        _result = 'QR OK: ${res['message'] ?? res.toString()}';
        _showScanner = false;
      });
    } catch (e) {
      setState(() => _result = 'Lỗi: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quét / Check-in')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Dùng khi đang tại di tích. Demo mặc định gắn Địa đạo Củ Chi. '
            'QR hợp lệ: timelens:location:11111111-1111-1111-1111-111111111111',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _busy ? null : _checkinGps,
            icon: const Icon(Icons.my_location),
            label: const Text('Check-in bằng GPS'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _busy ? null : _toggleScanner,
            icon: const Icon(Icons.qr_code_scanner),
            label: Text(_showScanner ? 'Ẩn camera QR' : 'Mở camera QR'),
          ),
          if (_cameraDenied) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: openAppSettings,
              icon: const Icon(Icons.settings),
              label: const Text('Mở cài đặt ứng dụng'),
            ),
          ],
          if (_showScanner) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 280,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: MobileScanner(
                  onDetect: (capture) {
                    final barcodes = capture.barcodes;
                    if (barcodes.isEmpty) return;
                    final raw = barcodes.first.rawValue;
                    if (raw != null) _onQr(raw);
                  },
                ),
              ),
            ),
          ],
          if (_busy) ...[
            const SizedBox(height: 16),
            const Center(child: CircularProgressIndicator(color: AppColors.orange)),
          ],
          if (_result != null) ...[
            const SizedBox(height: 16),
            Text(_result!, style: const TextStyle(height: 1.3)),
          ],
        ],
      ),
    );
  }
}
