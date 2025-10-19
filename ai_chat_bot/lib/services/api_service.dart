import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:1234'; // Change if needed

  static Future<String> sendMessage(List<Message> messages) async {
    final url = Uri.parse('$baseUrl/v1/chat/completions');
    final body = {
      "messages": messages
          .map((m) => {"role": m.role, "content": m.content})
          .toList(),
      "max_tokens": 1024,
      "temperature": 0.7,
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] ?? '';
    } else {
      return 'Error: ${response.statusCode}';
    }
  }
}