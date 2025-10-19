import 'message.dart';

class ChatSession {
  final String id;
  final String title;
  final List<Message> messages;

  ChatSession({
    required this.id,
    required this.title,
    required this.messages,
  });

  ChatSession copyWith({
    String? id,
    String? title,
    List<Message>? messages,
  }) {
    return ChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'messages': messages
            .map((msg) => {'role': msg.role, 'content': msg.content})
            .toList(),
      };

  static ChatSession fromJson(Map<String, dynamic> json) => ChatSession(
        id: json['id'],
        title: json['title'],
        messages: (json['messages'] as List)
            .map((m) => Message(role: m['role'], content: m['content']))
            .toList(),
      );
}