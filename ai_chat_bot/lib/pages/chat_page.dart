import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/message.dart';
import '../providers/chat_sessions_provider.dart';
import '../services/api_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/sidebar_drawer.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String? sessionId;
  const ChatPage({super.key, required this.sessionId});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final notifier = ref.read(chatSessionsProvider.notifier);
    final session = notifier.getSessionById(widget.sessionId);
    if (session == null) return;

    await notifier.addMessageToSession(session.id, Message(role: 'user', content: text));
    setState(() {
      _isLoading = true;
      _controller.clear();
    });

    final response = await ApiService.sendMessage(
      session.messages + [Message(role: 'user', content: text)],
    );
    await notifier.addMessageToSession(session.id, Message(role: 'assistant', content: response));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(chatSessionsProvider.notifier);
    final session = notifier.getSessionById(widget.sessionId);

    return Scaffold(
      drawer: SidebarDrawer(currentSessionId: widget.sessionId),
      body: Stack(
        children: [
          Column(
            children: [
              // Floating Topbar
              Material(
                elevation: 4,
                color: Theme.of(context).colorScheme.surface,
                child: SizedBox(
                  height: 64,
                  child: Row(
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        session?.title ?? 'AI ChatBot',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: session?.messages.length ?? 0,
                  itemBuilder: (context, index) {
                    final msg = session!.messages[index];
                    return ChatBubble(message: msg);
                  },
                ),
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Type your message...',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _isLoading ? null : _sendMessage,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}