import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/chat_sessions_provider.dart';

class IntroPage extends ConsumerWidget {
  const IntroPage({super.key});

  Future<void> _startChat(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(chatSessionsProvider.notifier);
    final sessionId = await notifier.createNewSessionAndReturnId();
    if (sessionId != null) {
      context.go('/chat/$sessionId');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Text(
          'AI ChatBot',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startChat(context, ref),
        label: const Text('Start Chat'),
        icon: const Icon(Icons.chat),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}