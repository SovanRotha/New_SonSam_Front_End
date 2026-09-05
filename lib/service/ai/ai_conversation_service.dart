import 'dart:convert';

import 'package:sansom/core/constant/api_url.dart';
import 'package:sansom/models/ai/ai_conversation.dart';
import 'package:sansom/service/token/token_storage.dart';
import 'package:http/http.dart' as http;

class AIConversationService {
  Future<AIConversation> createConversation(int userId, String title) async {
    final response = await http.post(
      Uri.parse('${ApiUrl.baseUrl}/conversations'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${await TokenStorage.getToken()}',
      },
      body: jsonEncode({'user_id': userId, 'title': title}),
    );

    if (response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      final payload = decoded is Map<String, dynamic>
          ? decoded['data'] ?? decoded['conversation'] ?? decoded
          : null;

      if (payload is Map<String, dynamic>) {
        final conversation = AIConversation.fromJson(payload);

        if (conversation.id > 0) {
          return conversation;
        }
      }

      throw Exception(
        'AI conversation response did not contain a valid conversation ID: ${response.body}',
      );
    }

    throw Exception('Failed to create AI conversation: ${response.body}');
  }
}
