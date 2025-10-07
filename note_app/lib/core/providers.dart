import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/notes/note.dart';

final notesProvider = StateNotifierProvider<NotesNotifier, List<Note>>((ref) {
  return NotesNotifier()..loadNotes();
});

final sharedPrefsProvider = Provider<SharedPreferences?>((ref) => null);

class NotesNotifier extends StateNotifier<List<Note>> {
  NotesNotifier() : super([]);

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesData = prefs.getStringList('notes') ?? [];
    state = notesData.map((e) => Note.fromJsonString(e)).toList();
  }

  Future<void> saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesData = state.map((e) => e.toJsonString()).toList();
    await prefs.setStringList('notes', notesData);
  }

  Future<void> addOrUpdateNote(Note note) async {
    final idx = state.indexWhere((n) => n.id == note.id);
    if (idx >= 0) {
      state = [
        ...state.sublist(0, idx),
        note,
        ...state.sublist(idx + 1),
      ];
    } else {
      state = [...state, note];
    }
    await saveNotes();
  }

  Future<void> deleteNote(String id) async {
    state = state.where((n) => n.id != id).toList();
    await saveNotes();
  }
}