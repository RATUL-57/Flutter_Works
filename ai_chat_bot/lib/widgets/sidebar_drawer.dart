import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/chat_sessions_provider.dart';

class SidebarDrawer extends ConsumerWidget {
  final String? currentSessionId;
  const SidebarDrawer({super.key, this.currentSessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(chatSessionsProvider);
    final notifier = ref.read(chatSessionsProvider.notifier);

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('New Chat'),
              onTap: () {
                Navigator.pop(context); // Use context before async
                notifier.createNewSessionAndReturnId().then((sessionId) {
                  if (sessionId != null) {
                    context.go('/chat/$sessionId');
                  }
                });
              },
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return ListTile(
                    leading: const Icon(Icons.chat_bubble_outline),
                    title: Text(session.title),
                    selected: currentSessionId == session.id,
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/chat/${session.id}');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}