import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:histar_mobile/core/config/env.dart';
import 'package:histar_mobile/core/theme/app_theme.dart';
import 'package:histar_mobile/shared/providers.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Opens FE pages with the mobile JWT injected into `timelens_*` localStorage.
class AuthenticatedWebViewScreen extends ConsumerStatefulWidget {
  const AuthenticatedWebViewScreen({
    super.key,
    required this.pathAndQuery,
    this.title = 'TimeLens Web',
  });

  /// Path beginning with `/`, e.g. `/time-portal/{id}?era=1968`.
  final String pathAndQuery;
  final String title;

  @override
  ConsumerState<AuthenticatedWebViewScreen> createState() =>
      _AuthenticatedWebViewScreenState();
}

class _AuthenticatedWebViewScreenState
    extends ConsumerState<AuthenticatedWebViewScreen> {
  WebViewController? _controller;
  String? _error;
  bool _injected = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final origin = AppEnv.webAppUrl;
    if (!origin.startsWith('https://')) {
      setState(() => _error = 'WEB_APP_URL cần HTTPS.');
      return;
    }
    final session = ref.read(sessionStorageProvider);
    final token = await session.getAccessToken();
    if (token == null || token.isEmpty) {
      setState(() => _error = 'Cần đăng nhập để mở trang này.');
      return;
    }
    final refresh = await session.getRefreshToken() ?? '';
    final userId = await session.getUserId() ?? '';
    final name = await session.getDisplayName() ?? '';
    final email = await session.getEmail() ?? '';
    final role = await session.getRole() ?? 'USER';
    final tier = await session.getTier() ?? 'FREE';
    final emailVerified = await session.getEmailVerified();

    final payload = {
      'timelens_token': token,
      'timelens_refresh_token': refresh,
      'timelens_user_id': userId,
      'timelens_display_name': name,
      'timelens_email': email,
      'timelens_role': role,
      'timelens_tier': tier,
      'timelens_email_verified': emailVerified == true ? '1' : '0',
    };
    final jsonPayload = jsonEncode(payload);
    final target =
        '$origin${widget.pathAndQuery.startsWith('/') ? widget.pathAndQuery : '/${widget.pathAndQuery}'}';

    late final WebViewController controller;
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0F1015))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            if (_injected) return;
            if (!url.startsWith(origin)) return;
            _injected = true;
            final script = '''
(function(){
  try {
    var d = $jsonPayload;
    Object.keys(d).forEach(function(k){ if(d[k]!==undefined && d[k]!==null) localStorage.setItem(k, String(d[k])); });
  } catch(e) {}
})();
''';
            try {
              await controller.runJavaScript(script);
            } catch (_) {}
            if (!_navigated) {
              _navigated = true;
              await controller.loadRequest(Uri.parse(target));
            }
          },
          onWebResourceError: (err) {
            if (!mounted) return;
            setState(() => _error = err.description);
          },
        ),
      )
      ..loadRequest(Uri.parse(origin));

    if (!mounted) return;
    setState(() => _controller = controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.surfaceAlt,
      ),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_error!, textAlign: TextAlign.center),
              ),
            )
          : _controller == null
              ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
              : WebViewWidget(controller: _controller!),
    );
  }
}
