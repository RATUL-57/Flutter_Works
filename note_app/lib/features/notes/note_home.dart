import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';

class NoteHomePage extends ConsumerWidget {
  const NoteHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/notes.png',
              height: 32,
              width: 32,
            ),
            const SizedBox(width: 8),
            const Text('Notes'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: notes.isEmpty
          ? const Center(child: Text('No notes yet.'))
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, idx) {
                final note = notes[idx];
                return _NoteCard(
                  note: note,
                  onTap: () => context.push('/edit/${note.id}'),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/edit'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _NoteCard extends StatefulWidget {
  final dynamic note;
  final VoidCallback onTap;
  const _NoteCard({required this.note, required this.onTap});

  @override
  State<_NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<_NoteCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovering ? Colors.blueAccent : Colors.grey.shade300,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _hovering ? Colors.blue.withOpacity(0.2) : Colors.black12,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            title: Text(
              widget.note.title.isEmpty ? '(No Title)' : widget.note.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: widget.note.content.isNotEmpty
                ? Text(
                    widget.note.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ),
      ),
    );
  }
}