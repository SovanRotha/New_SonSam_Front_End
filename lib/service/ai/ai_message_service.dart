import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:sansom/core/constant/api_url.dart';
import 'package:sansom/models/ai/ai_message.dart';
import 'package:sansom/service/token/token_storage.dart';

class AIMessageService {

  Future<List<AIMessage>> createMessage(
    int conversationId,
    String role,
    String message, {
    String? metadata,
    String? toolCallId,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiUrl.baseUrl}/conversation/$conversationId/messages'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${await TokenStorage.getToken()}',
      },
      body: jsonEncode({
        'conversation_id': conversationId,
        'role': role,
        'message': message,
        'metadata': metadata,
        'tool_call_id': toolCallId,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        final messages = <AIMessage>[];
        final userMessage = decoded['user_message'];
        final assistantMessage = decoded['assistant_message'];

        if (userMessage is Map<String, dynamic>) {
          messages.add(AIMessage.fromJson(userMessage));
        }

        if (assistantMessage is Map<String, dynamic>) {
          messages.add(AIMessage.fromJson(assistantMessage));
        }

        if (messages.isNotEmpty) {
          return messages;
        }

        final data = decoded['data'];
        if (data is Map<String, dynamic>) {
          return [AIMessage.fromJson(data)];
        }
      }
    }

    throw Exception('Failed to create AI message: ${response.body}');
  }
}