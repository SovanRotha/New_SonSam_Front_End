import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sansom/provider/ai/ai_provider.dart';
import 'package:sansom/provider/auth/auth_provider.dart';
import 'package:sansom/service/token/token_storage.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      createConversation();
    });
  }

  Future<void> createConversation() async {
    final token = await TokenStorage.getToken();

    if (!mounted || token == null) {
      debugPrint('Aborted: Token is null or widget unmounted.');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final aiProvider = context.read<AIProvider>();

    final user = authProvider.user;
    final userId = user?['id'];
    final parsedUserId = userId is int ? userId : int.tryParse('$userId');

    if (parsedUserId == null) {
      debugPrint('Aborted: Invalid or missing User ID.');
      return;
    }

    await aiProvider.createConversation(
      parsedUserId,
      'SanSom AI conversation',
    );

    if (mounted) {
      scrollToBottom();
    }
  }

  Future<void> sendMessage() async {
    final message = messageController.text.trim();
    final provider = context.read<AIProvider>();

    if (message.isEmpty || provider.conversation == null) {
      return;
    }

    messageController.clear();

    await provider.createMessage(
      'user',
      message,
    );

    scrollToBottom();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AIProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SanSom AI'),
      ),
      body: Column(
        children: [
          // Messages Area
          Expanded(
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : provider.messages.isEmpty
                    ? const Center(
                        child: Text('How can I help you today?'),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.messages.length,
                        itemBuilder: (context, index) {
                          final message = provider.messages[index];
                          final bool isUser = message.role == 'user';

                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75,
                              ),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? Colors.blue
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(
                                message.message,
                                style: TextStyle(
                                  color:
                                      isUser ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // Loading indicator for incoming messages
          if (provider.isCreatingMessage)
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('AI is thinking...'),
              ),
            ),

          // Message Input Field
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      textInputAction: TextInputAction.send,
                      enabled: provider.conversation != null &&
                          !provider.isLoading,
                      onSubmitted: (_) {
                        sendMessage();
                      },
                      decoration: InputDecoration(
                        hintText: provider.conversation == null
                            ? 'Initializing chat...'
                            : 'Ask SanSom AI...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: (provider.conversation == null ||
                            provider.isCreatingMessage ||
                            provider.isLoading)
                        ? null
                        : sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}