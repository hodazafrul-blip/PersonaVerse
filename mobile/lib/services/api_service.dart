import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  final List<Map<String, dynamic>> _mockCharacters = [
    {
      'id': 1,
      'name': 'Aria',
      'category': 'Romance',
      'personality_traits': 'Sweet, caring, deeply affectionate.',
      'avatar_url': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=400',
      'tags': ['#Sweet', '#Listener', '#Girlfriend']
    },
    {
      'id': 2,
      'name': 'Kael',
      'category': 'RPG',
      'personality_traits': 'Stoic, brave, protective, loyal.',
      'avatar_url': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&q=80&w=400',
      'tags': ['#Protector', '#Knight', '#Action']
    },
    {
      'id': 3,
      'name': 'Serena',
      'category': 'Mentor',
      'personality_traits': 'Wise, motivating, sharp intellect.',
      'avatar_url': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=400',
      'tags': ['#Career', '#LifeCoach', '#Smart']
    },
    {
      'id': 4,
      'name': 'Jin',
      'category': 'Anime',
      'personality_traits': 'Mysterious, cold outside, warm inside.',
      'avatar_url': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=400',
      'tags': ['#Mystery', '#Vampire', '#Dark']
    }
  ];

  Future<List<dynamic>> fetchCharacters() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/characters/')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      // Fallback
    }
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockCharacters;
  }

  Future<Map<String, dynamic>> fetchProfile(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/profile/$userId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<Map<String, dynamic>> createCharacter(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/characters/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create character');
    }
  }

  Future<Map<String, dynamic>> sendMessage(int userId, int characterId, String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'character_id': characterId,
          'content': content,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      // Fallback logic for demo
    }
    
    // Fallback Mock
    await Future.delayed(const Duration(milliseconds: 800));
    final char = _mockCharacters.firstWhere((c) => c['id'] == characterId, orElse: () => _mockCharacters[0]);
    return {
      'id': DateTime.now().millisecondsSinceEpoch,
      'content': "*(Offline Response from ${char['name']})* I'm always here for you, even when the stars go dark.",
      'sender': 'character',
      'affinity_score': 10,
      'relationship_stage': 'Friend',
      'xp_gained': 10
    };
  }
}
