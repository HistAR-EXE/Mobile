import 'package:histar_mobile/core/api/api_client.dart';
import 'package:histar_mobile/features/chat/chat_models.dart';

class ChatRepository {
  ChatRepository(this._api);
  final ApiClient _api;

  Future<ChatReply> send({
    required String characterId,
    required String message,
    String? conversationId,
  }) {
    return _api.postData(
      '/api/chat/messages',
      data: {
        'characterId': characterId,
        'message': message,
        if (conversationId != null) 'conversationId': conversationId,
      },
      parse: (raw) => ChatReply.fromJson(Map<String, dynamic>.from(raw as Map)),
    );
  }
}
