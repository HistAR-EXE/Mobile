import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:histar_mobile/core/api/api_error.dart';
import 'package:histar_mobile/core/theme/app_theme.dart';
import 'package:histar_mobile/shared/providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.registerMode = false});

  final bool registerMode;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController(text: 'demo@histar.vn');
  final _password = TextEditingController(text: 'Demo@2026');
  final _name = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _googleLogin() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).loginWithGoogle();
      if (!mounted) return;
      final auth = ref.read(authControllerProvider);
      if (auth.user?.needsEmailVerification == true) {
        context.go('/verify-email');
      } else if (auth.appMode == null) {
        context.go('/mode-select');
      } else {
        context.go('/home');
      }
    } catch (e) {
      setState(() {
        _error = e is ApiError ? e.message : e.toString();
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (widget.registerMode) {
        await ref.read(authControllerProvider.notifier).register(
              email: _email.text.trim(),
              password: _password.text,
              displayName: _name.text.trim().isEmpty ? 'Traveler' : _name.text.trim(),
            );
      } else {
        await ref.read(authControllerProvider.notifier).login(
              _email.text.trim(),
              _password.text,
            );
      }
      if (!mounted) return;
      final auth = ref.read(authControllerProvider);
      if (auth.user?.needsEmailVerification == true) {
        context.go('/verify-email');
      } else if (auth.appMode == null) {
        context.go('/mode-select');
      } else {
        context.go('/home');
      }
    } catch (e) {
      setState(() {
        _error = e is ApiError ? e.message : e.toString();
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.registerMode ? 'Đăng ký' : 'Đăng nhập'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/onboarding'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (widget.registerMode) ...[
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Tên hiển thị'),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Mật khẩu'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.redAccent)),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                  )
                : Text(widget.registerMode ? 'Tạo tài khoản' : 'Đăng nhập'),
          ),
          if (!widget.registerMode) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _busy ? null : _googleLogin,
              icon: const Icon(Icons.g_mobiledata, size: 28),
              label: const Text('Tiếp tục với Google'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: AppColors.border),
              ),
            ),
          ],
          TextButton(
            onPressed: () => context.go(widget.registerMode ? '/login' : '/register'),
            child: Text(
              widget.registerMode ? 'Đã có tài khoản? Đăng nhập' : 'Chưa có tài khoản? Đăng ký',
              style: const TextStyle(color: AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }
}
