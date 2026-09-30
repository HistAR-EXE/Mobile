import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:histar_mobile/core/api/api_error.dart';
import 'package:histar_mobile/core/theme/app_theme.dart';
import 'package:histar_mobile/shared/providers.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.characterId});

  final String characterId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _messages = <_Bubble>[];
  String? _conversationId;
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showQuotaDialog() async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hết lượt chat miễn phí'),
        content: const Text(
          'Nâng cấp Premium 79.000đ/tháng để chat AI không giới hạn và mở gamification đầy đủ.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Để sau')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xem gói 79k')),
        ],
      ),
    );
    if (go == true && mounted) {
      context.push('/pricing');
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _messages.add(_Bubble(text: text, isUser: true));
      _controller.clear();
      _sending = true;
    });
    try {
      final reply = await ref.read(chatRepositoryProvider).send(
            characterId: widget.characterId,
            message: text,
            conversationId: _conversationId,
          );
      if (!mounted) return;
      setState(() {
        _conversationId = reply.conversationId;
        _messages.add(_Bubble(text: reply.reply, isUser: false, sources: reply.sources));
      });
    } catch (e) {
      if (!mounted) return;
      final msg = e is ApiError ? e.message : e.toString();
      setState(() => _messages.add(_Bubble(text: 'Lỗi: $msg', isUser: false)));
      if (e is ApiError && e.isQuota) {
        await _showQuotaDialog();
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat AI')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                return Align(
                  alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    decoration: BoxDecoration(
                      color: m.isUser ? AppColors.orange.withValues(alpha: 0.25) : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.text),
                        if (m.sources.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Nguồn: ${m.sources.join(' · ')}',
                            style: const TextStyle(fontSize: 11, color: AppColors.muted),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(hintText: 'Hỏi về lịch sử...'),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    style: IconButton.styleFrom(backgroundColor: AppColors.orange),
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : const Icon(Icons.send, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble {
  _Bubble({required this.text, required this.isUser, this.sources = const []});
  final String text;
  final bool isUser;
  final List<String> sources;
}
