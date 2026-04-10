import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android emulator, or localhost/IP for real device/iOS
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<List<dynamic>> fetchCharacters() async {
    final response = await http.get(Uri.parse('$baseUrl/characters/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load characters');
    }
  }

  Future<Map<String, dynamic>> sendMessage(int userId, int characterId, String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
        'character_id': characterId,
        'content': content,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to send message');
    }
  }
}
