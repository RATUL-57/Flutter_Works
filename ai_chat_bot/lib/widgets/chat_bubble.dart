import 'package:flutter/material.dart';
import '../models/message.dart';
import 'markdown_display.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: const BoxConstraints(maxWidth: 350),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 25) // ~0.1 opacity
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(10),
        child: isUser
            ? Text(
                message.content,
                style: const TextStyle(fontSize: 16),
              )
            : MarkdownDisplay(text: message.content),
      ),
    );
  }
}