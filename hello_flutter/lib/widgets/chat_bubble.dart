import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onSave;

  const ChatBubble({super.key, required this.message, this.onSave});

  @override
  Widget build(BuildContext context) {
    if (message.isLoading) return _buildLoadingBubble(context);

    final cs = Theme.of(context).colorScheme;
    final showSaveButton = onSave != null && !message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: message.isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!message.isUser) ...[
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                      child: Text('🍸', style: TextStyle(fontSize: 15))),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? cs.primary
                        : cs.surfaceVariant,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft:
                          Radius.circular(message.isUser ? 16 : 4),
                      bottomRight:
                          Radius.circular(message.isUser ? 4 : 16),
                    ),
                    border: message.isUser
                        ? null
                        : Border.all(color: cs.outline.withValues(alpha: 0.6)),
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: message.isUser
                          ? cs.onPrimary
                          : cs.onSurface,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
              if (message.isUser) ...[
                const SizedBox(width: 8),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: cs.surfaceVariant,
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.outline),
                  ),
                  child: Center(
                    child: Icon(Icons.person,
                        size: 16,
                        color: cs.onSurface.withValues(alpha: 0.7)),
                  ),
                ),
              ],
            ],
          ),
          if (showSaveButton)
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 6),
              child: GestureDetector(
                onTap: onSave,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.green.withValues(alpha: 0.45)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.save_alt,
                          size: 12, color: Colors.green),
                      SizedBox(width: 5),
                      Text(
                        'Save as Drink',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingBubble(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
                color: cs.primaryContainer, shape: BoxShape.circle),
            child: const Center(
                child: Text('🍸', style: TextStyle(fontSize: 15))),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: cs.surfaceVariant,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              border:
                  Border.all(color: cs.outline.withValues(alpha: 0.6)),
            ),
            child: const _TypingIndicator(),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotColor = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.33;
            final t = (_controller.value - delay).clamp(0.0, 1.0);
            final opacity = (t < 0.5 ? t * 2 : (1 - t) * 2).clamp(0.3, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Opacity(
                opacity: opacity,
                child: CircleAvatar(radius: 4, backgroundColor: dotColor),
              ),
            );
          }),
        );
      },
    );
  }
}

