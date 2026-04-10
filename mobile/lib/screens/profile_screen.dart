import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _apiService.fetchProfile(1); // Hardcoded user 1 for prototype
      setState(() {
        _profile = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF1E2140),
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 15),
              Text(_profile?['username'] ?? 'Guest User', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Text('Level ${_profile?['level'] ?? 1} Explorer (${_profile?['xp'] ?? 0} XP)', style: const TextStyle(color: Color(0xFFEC4899), fontSize: 14)),
              const SizedBox(height: 30),
              _buildPanel(
                'Gamification & Rewards',
                [
                  _buildListTile(Icons.card_giftcard, 'Daily Login Reward', 'Available!'),
                  _buildListTile(Icons.emoji_events, 'Achievements', '12 / 50 Unlocked'),
                ]
              ),
              const SizedBox(height: 20),
              _buildPanel(
                'Personalization',
                [
                  _buildListTile(Icons.dark_mode, 'Theme', 'Dark Mode'),
                  _buildListTile(Icons.language, 'Language', 'English'),
                  _buildListTile(Icons.notifications, 'Notifications', 'Enabled'),
                ]
              ),
              const SizedBox(height: 20),
              _buildPanel(
                'Premium (Unlocked)',
                [
                  _buildListTile(Icons.star, 'PersonaVerse Pro', 'Active (Unlimited)'),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'All features including DALL-E image generation, multi-branch storytelling, and ElevenLabs voice are unlocked by default.',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  )
                ]
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPanel(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2140),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const Divider(color: Colors.black12, height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, String trailing) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6366F1)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: Text(trailing, style: const TextStyle(color: Colors.grey)),
    );
  }
}
