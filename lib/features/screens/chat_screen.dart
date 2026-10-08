import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:histar_mobile/core/api/api_error.dart';
import 'package:histar_mobile/core/theme/app_theme.dart';
import 'package:histar_mobile/features/gamification/cu_chi_keys.dart';
import 'package:histar_mobile/shared/providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    required this.characterId,
    this.locationId,
    this.questRecord,
    this.questPrompt,
    this.call = false,
  });

  final String characterId;
  final String? locationId;
  final String? questRecord;
  final String? questPrompt;
  final bool call;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _messages = <_Bubble>[];
  String? _conversationId;
  bool _sending = false;
  String? _retryText;
  bool _dialogueRecorded = false;
  String? _quizState; // open | correct | wrong

  @override
  void initState() {
    super.initState();
    final prompt = widget.questPrompt?.trim();
    if (prompt != null && prompt.isNotEmpty) {
      _controller.text = prompt;
    }
    if (widget.call) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final params = <String, String>{
          'characterId': widget.characterId,
          'call': '1',
          if (widget.locationId != null) 'locationId': widget.locationId!,
          if (widget.questRecord != null) 'questRecord': widget.questRecord!,
          if (widget.questPrompt != null) 'questPrompt': widget.questPrompt!,
        };
        final q = Uri(queryParameters: params).query;
        context.push('/web?path=${Uri.encodeComponent('/chat?$q')}&title=${Uri.encodeComponent('Gọi Chrono')}');
      });
    }
  }

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
          'Nâng cấp Premium 49.000đ/tháng để chat AI không giới hạn và mở gamification đầy đủ.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Để sau')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xem gói 49k')),
        ],
      ),
    );
    if (go == true && mounted) {
      context.push('/pricing');
    }
  }

  Future<void> _recordDialogue() async {
    final key = widget.questRecord;
    final locationId = widget.locationId;
    if (_dialogueRecorded || key == null || key.isEmpty || locationId == null) return;
    if (key == saBanQuestKey) return;
    _dialogueRecorded = true;
    try {
      await ref.read(discoveryRepositoryProvider).record(
            unlockKey: key,
            locationId: locationId,
            source: 'map',
          );
    } catch (_) {
      _dialogueRecorded = false;
    }
  }

  Future<void> _acceptSaBan(String text) async {
    final id = 'quiz-${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _messages.add(_Bubble(text: text, isUser: true));
      _messages.add(_Bubble(text: SaBanQuiz.prompt, isUser: false, quizId: id));
      _quizState = 'open';
      _controller.clear();
    });
  }

  Future<void> _answerQuiz(String optionId) async {
    if (_quizState == 'correct') return;
    final correct = optionId == SaBanQuiz.correctId;
    setState(() => _quizState = correct ? 'correct' : 'wrong');
    if (!correct) {
      setState(() {
        _messages.add(
          _Bubble(text: 'Chưa đúng. Xem lại tầng sâu nhất rồi chọn lại.', isUser: false),
        );
        _quizState = 'open';
      });
      return;
    }
    final locationId = widget.locationId;
    if (locationId == null) return;
    try {
      final result = await ref.read(gamificationRepositoryProvider).claimChapterBonus(
            locationId: locationId,
            unlockKey: saBanQuestKey,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.alreadyClaimed
                ? 'Bạn đã nhận điểm chương này rồi.'
                : 'Chính xác. +${result.awarded} điểm chương sa bàn',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _quizState = 'open');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  String _friendlyChatError(ApiError e) {
    if (e.code == 'EMAIL_NOT_VERIFIED') {
      return 'Vui lòng xác thực email trước khi chat.';
    }
    if (e.isQuota || e.status == 429) {
      return e.message;
    }
    if (e.status == 503 ||
        e.status == 500 ||
        e.message.contains('RAG AI') ||
        e.message.contains('providers') ||
        e.message.contains('Gemini')) {
      return e.status == 500
          ? 'Lỗi máy chủ. Hãy gửi lại.'
          : 'Chrono đang bận. Hãy gửi lại sau một lát.';
    }
    return e.message;
  }

  Future<void> _send([String? override]) async {
    final text = (override ?? _controller.text).trim();
    if (text.isEmpty || _sending) return;

    if (widget.questRecord == saBanQuestKey && messageHasSaBanCode(text)) {
      await _acceptSaBan(text);
      return;
    }

    setState(() {
      _messages.add(_Bubble(text: text, isUser: true));
      if (override == null) _controller.clear();
      _retryText = null;
      _sending = true;
    });
    try {
      final reply = await ref.read(chatRepositoryProvider).send(
            characterId: widget.characterId,
            message: text,
            conversationId: _conversationId,
          );
      if (!mounted) return;
      await _recordDialogue();
      setState(() {
        _conversationId = reply.conversationId;
        _messages.add(_Bubble(text: reply.reply, isUser: false, sources: reply.sources));
      });
    } catch (e) {
      if (!mounted) return;
      if (e is ApiError) {
        final msg = _friendlyChatError(e);
        setState(() {
          _messages.add(_Bubble(text: msg, isUser: false));
          if (e.code != 'EMAIL_NOT_VERIFIED' && !e.isQuota) {
            _retryText = text;
          }
        });
        if (e.isQuota) {
          await _showQuotaDialog();
        } else if (e.code == 'EMAIL_NOT_VERIFIED') {
          final go = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Chưa xác thực email'),
              content: Text(msg),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Đóng')),
                ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xác thực')),
              ],
            ),
          );
          if (go == true && mounted) context.push('/verify-email');
        }
      } else {
        setState(() {
          _messages.add(_Bubble(text: 'Lỗi: $e', isUser: false));
          _retryText = text;
        });
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat AI'),
        actions: [
          IconButton(
            tooltip: 'Gọi Chrono (web)',
            onPressed: () {
              final params = <String, String>{
                'characterId': widget.characterId,
                'call': '1',
                if (widget.locationId != null) 'locationId': widget.locationId!,
                if (widget.questRecord != null) 'questRecord': widget.questRecord!,
                if (widget.questPrompt != null) 'questPrompt': widget.questPrompt!,
              };
              final q = Uri(queryParameters: params).query;
              context.push(
                '/web?path=${Uri.encodeComponent('/chat?$q')}&title=${Uri.encodeComponent('Gọi Chrono')}',
              );
            },
            icon: const Icon(Icons.videocam_outlined),
          ),
        ],
      ),
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
                        if (m.quizId != null) ...[
                          const SizedBox(height: 8),
                          for (final option in SaBanQuiz.options)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: OutlinedButton(
                                onPressed: _quizState == 'correct'
                                    ? null
                                    : () => _answerQuiz(option.id),
                                child: Text(option.label, textAlign: TextAlign.left),
                              ),
                            ),
                        ],
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
          if (_retryText != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: _sending ? null : () => _send(_retryText),
                  child: const Text('Gửi lại'),
                ),
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
                    onPressed: _sending ? null : () => _send(),
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
  _Bubble({
    required this.text,
    required this.isUser,
    this.sources = const [],
    this.quizId,
  });
  final String text;
  final bool isUser;
  final List<String> sources;
  final String? quizId;
}
