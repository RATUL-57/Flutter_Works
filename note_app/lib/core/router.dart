import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/notes/note_home.dart';
import '../features/notes/note_edit.dart';
import '../features/settings/settings_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const NoteHomePage(),
        routes: [
          GoRoute(
            path: 'edit/:id',
            builder: (context, state) => NoteEditPage(noteId: state.pathParameters['id']),
          ),
          GoRoute(
            path: 'edit',
            builder: (context, state) => const NoteEditPage(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
});