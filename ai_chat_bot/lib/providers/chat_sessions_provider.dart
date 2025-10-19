import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_session.dart';
import '../models/message.dart';
import '../services/chat_history_service.dart';

class ChatSessionsNotifier extends StateNotifier<List<ChatSession>> {
  ChatSessionsNotifier() : super([]) {
    _loadSessions();
  }

  String? _activeSessionId;

  String? get activeSessionId => _activeSessionId;

  ChatSession? get activeSession {
    try {
      return state.firstWhere((s) => s.id == _activeSessionId);
    } catch (_) {
      return null;
    }
  }

  ChatSession? getSessionById(String? id) {
    if (id == null) return null;
    try {
      return state.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadSessions() async {
    final sessions = await ChatHistoryService.loadSessions();
    state = sessions;
    if (sessions.isNotEmpty) {
      _activeSessionId = sessions.first.id;
    }
  }

  void setActiveSession(String id) {
    _activeSessionId = id;
    state = [...state];
  }

  Future<String?> createNewSessionAndReturnId() async {
    final newSession = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Chat ${state.length + 1}',
      messages: [],
    );
    state = [newSession, ...state];
    _activeSessionId = newSession.id;
    await ChatHistoryService.saveSessions(state);
    return newSession.id;
  }

  Future<void> createNewSession() async {
    await createNewSessionAndReturnId();
  }

  Future<void> addMessageToSession(String sessionId, Message message) async {
    final idx = state.indexWhere((s) => s.id == sessionId);
    if (idx == -1) return;
    final session = state[idx];
    final updatedSession = session.copyWith(messages: [...session.messages, message]);
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == idx) updatedSession else state[i]
    ];
    await ChatHistoryService.saveSessions(state);
  }

  Future<void> updateSessionMessages(String sessionId, List<Message> messages) async {
    final idx = state.indexWhere((s) => s.id == sessionId);
    if (idx == -1) return;
    final session = state[idx];
    final updatedSession = session.copyWith(messages: messages);
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == idx) updatedSession else state[i]
    ];
    await ChatHistoryService.saveSessions(state);
  }
}

final chatSessionsProvider =
    StateNotifierProvider<ChatSessionsNotifier, List<ChatSession>>((ref) {
  return ChatSessionsNotifier();
});