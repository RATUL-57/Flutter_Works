class Message {
  final String role; // 'user' or 'assistant'
  final String content;

  Message({required this.role, required this.content});
}