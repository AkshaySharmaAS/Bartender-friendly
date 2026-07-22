import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/api_key_dialog.dart';
import '../../widgets/save_recipe_dialog.dart';

class AiRecipeScreen extends StatefulWidget {
  const AiRecipeScreen({super.key});

  @override
  State<AiRecipeScreen> createState() => _AiRecipeScreenState();
}

class _AiRecipeScreenState extends State<AiRecipeScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  // Each AiRecipeScreen has its own chat state using a separate provider key
  // We reuse ChatProvider but the screen manages its own scroll + input
  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    final chat = context.read<ChatProvider>();
    if (!chat.hasApiKey) {
      await ApiKeyDialog.show(context);
      return;
    }
    _msgCtrl.clear();
    await chat.sendBartenderMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1A3A1A)
                : const Color(0xFFE8F5E9),
            border: Border(
              bottom: BorderSide(
                color: isDark ? const Color(0xFF2A4A2A) : const Color(0xFFC8E6C9),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              const Text('🤖', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Recipe Assistant',
                      style: TextStyle(
                          color: isDark
                              ? const Color(0xFF81C784)
                              : const Color(0xFF1B5E20),
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                    Text(
                      'Create & refine cocktail recipes with AI',
                      style: TextStyle(
                          color: isDark
                              ? const Color(0xFF81C784).withValues(alpha: 0.65)
                              : const Color(0xFF388E3C),
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
              Consumer<ChatProvider>(
                builder: (_, chat, _) => IconButton(
                  icon: Icon(Icons.refresh,
                      color: isDark
                          ? const Color(0xFF81C784).withValues(alpha: 0.65)
                          : const Color(0xFF388E3C)),
                  tooltip: 'New session',
                  onPressed: chat.clearMessages,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: Consumer<ChatProvider>(
            builder: (context, chat, _) {
              if (chat.messages.isEmpty) {
                return _BartenderPrompts(
                  onTap: (p) {
                    _msgCtrl.text = p;
                    _send();
                  },
                );
              }

              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _scrollToBottom());

              return ListView.builder(
                controller: _scrollCtrl,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: chat.messages.length +
                    (chat.error != null ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == chat.messages.length && chat.error != null) {
                    return _ErrorBanner(
                        message: chat.error!, onDismiss: chat.clearError);
                  }
                  return ChatBubble(
                    message: chat.messages[i],
                    onSave: (!chat.messages[i].isUser && !chat.messages[i].isLoading)
                        ? () => SaveRecipeDialog.show(
                              context,
                              recipeContent: chat.messages[i].content,
                            )
                        : null,
                  );
                },
              );
            },
          ),
        ),

        // Input
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFEEEEEE),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _msgCtrl,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: const InputDecoration(
                    hintText: 'Ask for a recipe, ingredient sub...',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Consumer<ChatProvider>(
                builder: (_, chat, _) => GestureDetector(
                  onTap: chat.isSending ? null : _send,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: chat.isSending
                          ? const Color(0xFF2E7D32).withValues(alpha: 0.5)
                          : const Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                    ),
                    child: chat.isSending
                        ? const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            ),
                          )
                        : const Icon(Icons.send,
                            color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BartenderPrompts extends StatelessWidget {
  final void Function(String) onTap;

  const _BartenderPrompts({required this.onTap});

  static const prompts = [
    'Create a tropical cocktail recipe with rum and mango',
    'Give me a non-alcoholic mocktail with lavender and lemon',
    'What can I make with gin, elderflower and cucumber?',
    'Create a spicy margarita variation',
    'Suggest 3 signature cocktails for a beach bar',
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✨', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 16),
            Text(
              'AI Recipe Studio',
              style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Get AI-generated recipes, ingredient suggestions and creative ideas',
              style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.5), fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ...prompts.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () => onTap(p),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: cs.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cs.outline),
                      ),
                      child: Row(
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(p,
                                style: TextStyle(
                                    color: cs.onSurface.withValues(alpha: 0.75),
                                    fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: cs.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cs.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: cs.error, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message,
                  style: TextStyle(color: cs.error, fontSize: 12)),
            ),
            IconButton(
              icon: Icon(Icons.close, color: cs.error, size: 16),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
