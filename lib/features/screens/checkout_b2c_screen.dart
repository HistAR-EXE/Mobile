import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:histar_mobile/core/theme/app_theme.dart';
import 'package:histar_mobile/features/billing/billing_models.dart';
import 'package:histar_mobile/shared/providers.dart';
import 'package:intl/intl.dart';

/// B2C SePay checkout. Bank transfer notifies the backend via webhook;
/// this screen polls status (and keeps a manual refresh) then refreshes the profile.
class CheckoutB2cScreen extends ConsumerStatefulWidget {
  const CheckoutB2cScreen({super.key, this.returnToPath = '/home'});

  final String returnToPath;

  @override
  ConsumerState<CheckoutB2cScreen> createState() => _CheckoutB2cScreenState();
}

class _CheckoutB2cScreenState extends ConsumerState<CheckoutB2cScreen> {
  B2cPaymentIntent? _payment;
  bool _loading = false;
  String? _status;
  Map<String, dynamic>? _statusDetail;
  String? _error;
  Timer? _poll;
  bool _navigated = false;

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  String get _safeReturn {
    final raw = widget.returnToPath;
    if (raw.startsWith('/') && !raw.startsWith('//')) return raw;
    return '/home';
  }

  void _ensurePoll() {
    final status = _status;
    if (_payment == null || _navigated || status == 'EXPIRED' || status == 'FAILED') {
      _poll?.cancel();
      _poll = null;
      return;
    }
    _poll ??= Timer.periodic(const Duration(seconds: 5), (_) {
      _refresh(silent: true);
    });
  }

  Future<void> _create() async {
    final user = ref.read(authControllerProvider).user;
    if (user?.needsEmailVerification == true) {
      setState(() => _error = 'Hãy xác minh email trước khi thanh toán Premium.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final p = await ref.read(billingRepositoryProvider).createB2cPayment(returnToPath: _safeReturn);
      if (!mounted) return;
      setState(() {
        _payment = p;
        _status = p.status;
      });
      _ensurePoll();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh({bool silent = false}) async {
    final code = _payment?.orderCode;
    if (code == null || _navigated) return;
    if (!silent) setState(() => _loading = true);
    try {
      final s = await ref.read(billingRepositoryProvider).b2cPaymentStatus(code);
      if (!mounted) return;
      final status = s['status']?.toString();
      setState(() {
        _status = status;
        _statusDetail = s;
      });
      _ensurePoll();
      final upgraded = s['upgraded'] == true;
      if (status == 'PAID' && !upgraded) {
        return;
      }
      if (status == 'PAID' && upgraded) {
        _poll?.cancel();
        _poll = null;
        await ref.read(authControllerProvider.notifier).refreshProfileFromServer();
        if (!mounted || _navigated) return;
        _navigated = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Premium đã kích hoạt!')),
        );
        final next = s['returnToPath']?.toString();
        final target = (next != null && next.startsWith('/') && !next.startsWith('//')) ? next : _safeReturn;
        context.go(target);
      }
    } catch (e) {
      if (!silent && mounted) setState(() => _error = e.toString());
    } finally {
      if (!silent && mounted) setState(() => _loading = false);
    }
  }

  /// UNDERPAID: show received vs expected, remaining top-up amount and the (same) transfer content.
  Widget _buildUnderpaidNotice(NumberFormat fmt) {
    final detail = _statusDetail;
    final amount = (detail?['amountVnd'] as num?)?.toInt() ?? _payment!.amountVnd;
    final received = (detail?['receivedAmountVnd'] as num?)?.toInt() ?? 0;
    final remaining = (detail?['remainingAmountVnd'] as num?)?.toInt() ?? amount;
    final content = detail?['transferContent']?.toString() ?? _payment!.transferContent;
    return Container(
      key: const Key('underpaid-notice'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        border: Border.all(color: Colors.orangeAccent),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bạn đã chuyển thiếu tiền',
            style: TextStyle(fontWeight: FontWeight.w800, color: Colors.orangeAccent),
          ),
          const SizedBox(height: 6),
          Text('Đã nhận ${fmt.format(received)}đ / ${fmt.format(amount)}đ.'),
          Text(
            'Vui lòng chuyển bổ sung ${fmt.format(remaining)}đ với cùng nội dung chuyển khoản:',
          ),
          const SizedBox(height: 4),
          SelectableText(
            content,
            style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.gold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Chuyển dư (≥ số tiền) vẫn được chấp nhận. Premium tự kích hoạt khi tổng tiền đủ.',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.decimalPattern('vi_VN');
    final needsVerify = ref.watch(authControllerProvider).user?.needsEmailVerification == true;
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán Premium')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _payment == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Tạo mã QR chuyển khoản. Ngân hàng báo SePay, server nhận webhook và nâng Premium. App tự kiểm tra trạng thái vài giây một lần.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  if (needsVerify) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Tài khoản chưa xác minh email. Hãy xác minh trước khi thanh toán.',
                      style: TextStyle(color: Colors.orangeAccent),
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                  ],
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _loading || needsVerify ? null : _create,
                    child: _loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : const Text('Tạo mã QR'),
                  ),
                ],
              )
            : ListView(
                children: [
                  Text(
                    '${fmt.format(_payment!.amountVnd)}đ',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.gold),
                  ),
                  Text('Trạng thái: ${_status ?? _payment!.status}'),
                  const SizedBox(height: 8),
                  if ((_status ?? _payment!.status) == 'UNDERPAID')
                    _buildUnderpaidNotice(fmt)
                  else
                    const Text(
                      'Đang chờ ngân hàng xác nhận (có thể mất 1–2 phút). App vẫn tự kiểm tra.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  const SizedBox(height: 12),
                  if (_payment!.qrUrl.isNotEmpty)
                    Center(
                      child: CachedNetworkImage(
                        imageUrl: _payment!.qrUrl,
                        width: 220,
                        height: 220,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text('Ngân hàng: ${_payment!.bankCode}'),
                  Text('STK: ${_payment!.accountNumber}'),
                  Text('Chủ TK: ${_payment!.accountName}'),
                  Text('Nội dung: ${_payment!.transferContent}', style: const TextStyle(fontWeight: FontWeight.w800)),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loading ? null : () => _refresh(),
                    child: const Text('Tôi đã chuyển khoản'),
                  ),
                ],
              ),
      ),
    );
  }
}
