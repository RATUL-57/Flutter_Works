import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import 'note.dart';

class NoteEditPage extends ConsumerStatefulWidget {
  final String? noteId;
  const NoteEditPage({super.key, this.noteId});

  @override
  ConsumerState<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends ConsumerState<NoteEditPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  Note? _editingNote;

  @override
  void initState() {
    super.initState();
    final notes = ref.read(notesProvider);
    if (widget.noteId != null) {
      _editingNote = notes.firstWhere((n) => n.id == widget.noteId, orElse: () => Note(title: '', content: ''));
      _titleController.text = _editingNote?.title ?? '';
      _contentController.text = _editingNote?.content ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final title = _titleController.text.trim();
              final content = _contentController.text.trim();
              if (title.isEmpty && content.isEmpty) {
                Navigator.of(context).pop();
                return;
              }
              final note = (_editingNote ?? Note(title: '', content: '')).copyWith(
                title: title,
                content: content,
              );
              await ref.read(notesProvider.notifier).addOrUpdateNote(note);
              if (!mounted) return;
              // Only use context if mounted
              context.go('/');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                ),
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}