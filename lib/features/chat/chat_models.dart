class ChatReply {
  const ChatReply({
    required this.reply,
    required this.conversationId,
    this.sources = const [],
  });

  final String reply;
  final String conversationId;
  final List<String> sources;

  factory ChatReply.fromJson(Map<String, dynamic> json) {
    final rawSources = json['sources'];
    final sources = <String>[];
    if (rawSources is List) {
      for (final s in rawSources) {
        if (s is String) {
          sources.add(s);
        } else if (s is Map && s['title'] != null) {
          sources.add(s['title'].toString());
        }
      }
    }
    return ChatReply(
      reply: json['reply'] as String? ?? '',
      conversationId: json['conversationId'] as String? ?? '',
      sources: sources,
    );
  }
}
