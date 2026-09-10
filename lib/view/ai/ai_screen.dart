import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/core/constant/app_color.dart';

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

  Future<void> sendMessage([String? text]) async {
    final message = text ?? messageController.text.trim();
    final provider = context.read<AIProvider>();

    if (message.isEmpty || provider.conversation == null) {
      return;
    }

    if (text == null) {
      messageController.clear();
    }

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SanSom AI',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages Area
          Expanded(
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : provider.messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.chat_bubble_outline, size: 36, color: AppColors.primary),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'How can I help you today?',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Ask me about your budget, transactions, or financial insights.',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.messages.length,
                        itemBuilder: (context, index) {
                          final message = provider.messages[index];
                          final bool isUser = message.role == 'user';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Row(
                              mainAxisAlignment: isUser
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isUser) ...[
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isUser
                                          ? AppColors.primary
                                          : AppColors.surface,
                                      borderRadius: BorderRadius.circular(16),
                                      border: isUser
                                          ? null
                                          : Border.all(color: AppColors.border),
                                    ),
                                    child: Text(
                                      message.message,
                                      style: TextStyle(
                                        color: isUser
                                            ? AppColors.textLight
                                            : AppColors.textPrimary,
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),

          // Loading indicator for incoming messages
          if (provider.isCreatingMessage)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Text(
                      'SanSom AI is thinking...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Quick Suggestion Chips Bar
          // Container(
          //   height: 48,
          //   padding: const EdgeInsets.symmetric(horizontal: 12),
          //   child: ListView(
          //     scrollDirection: Axis.horizontal,
          //     children: [
          //       _buildSuggestionChip('Check my budget', Icons.pie_chart_outline),
          //       _buildSuggestionChip('Add income', Icons.add_circle_outline),
          //       _buildSuggestionChip('Spending breakdown', Icons.analytics_outlined),
          //     ],
          //   ),
          // ),

          // Message Input Field Bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      textInputAction: TextInputAction.send,
                      enabled: provider.conversation != null && !provider.isLoading,
                      onSubmitted: (_) => sendMessage(),
                      decoration: InputDecoration(
                        hintText: provider.conversation == null
                            ? 'Initializing chat...'
                            : 'Ask SanSom anything...',
                        hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        filled: true,
                        fillColor: AppColors.background,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.mic_none, color: AppColors.textSecondary, size: 20),
                          onPressed: () {},
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: (provider.conversation == null ||
                              provider.isCreatingMessage ||
                              provider.isLoading)
                          ? null
                          : () => sendMessage(),
                      icon: const Icon(Icons.send, color: AppColors.textLight, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(icon, size: 14, color: AppColors.primary),
        label: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
        backgroundColor: AppColors.surface,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () => sendMessage(label),
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