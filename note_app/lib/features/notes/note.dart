import 'dart:convert';
import 'package:uuid/uuid.dart';

class Note {
  final String id;
  final String title;
  final String content;

  Note({
    String? id,
    required this.title,
    required this.content,
  }) : id = id ?? const Uuid().v4();

  Note copyWith({String? title, String? content}) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'],
        title: json['title'],
        content: json['content'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
      };

  String toJsonString() => jsonEncode(toJson());

  static Note fromJsonString(String s) => Note.fromJson(jsonDecode(s));
}