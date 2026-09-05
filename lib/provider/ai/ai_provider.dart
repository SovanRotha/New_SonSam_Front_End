import 'package:flutter/foundation.dart';
import 'package:sansom/models/ai/ai_conversation.dart';
import 'package:sansom/models/ai/ai_message.dart';
import 'package:sansom/service/ai/ai_conversation_service.dart';
import 'package:sansom/service/ai/ai_message_service.dart';

class AIProvider extends ChangeNotifier {
  final AIConversationService conversationService = AIConversationService();
  final AIMessageService messageService = AIMessageService();

  AIConversation? conversation;
  List<AIMessage> messages = [];

  bool isLoading = false;
  bool isCreatingMessage = false;

  Future<void> createConversation(int userId, String title) async {
    isLoading = true;
    notifyListeners();

    try {
      conversation = await conversationService.createConversation(
        userId,
        title,
      );
      messages.clear();
    } catch (e) {
      if (kDebugMode) {
        print('Error creating conversation: $e');
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createMessage(
    String role,
    String message, {
    String? metadata,
    String? toolCallId,
  }) async {
    if (conversation == null) {
      if (kDebugMode) {
        print('No conversation available.');
      }
      return;
    }

    isCreatingMessage = true;
    notifyListeners();

    try {
      final newMessages = await messageService.createMessage(
        conversation!.id,
        role,
        message,
        metadata: metadata,
        toolCallId: toolCallId,
      );

      messages.addAll(newMessages);
    } catch (e) {
      if (kDebugMode) {
        print('Error creating message: $e');
      }
    } finally {
      isCreatingMessage = false;
      notifyListeners();
    }
  }
}