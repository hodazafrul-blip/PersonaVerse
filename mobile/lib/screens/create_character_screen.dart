import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CreateCharacterScreen extends StatefulWidget {
  const CreateCharacterScreen({super.key});

  @override
  State<CreateCharacterScreen> createState() => _CreateCharacterScreenState();
}

class _CreateCharacterScreenState extends State<CreateCharacterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _backstoryController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isSaving = false;

  double _funnySlider = 0.5;
  double _seriousSlider = 0.5;
  double _romanticSlider = 0.2;

  void _saveCharacter() async {
    if (_nameController.text.isEmpty || _backstoryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      final res = await _apiService.createCharacter({
        'name': _nameController.text,
        'category': 'Roleplay',
        'personality_traits': 'Humor: $_funnySlider, Stoic: $_seriousSlider, Romance: $_romanticSlider',
        'backstory': _backstoryController.text,
        'speaking_tone': 'Casual',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Created ${res['name']} with DALL-E Avatar!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Character Builder', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1E2140),
        elevation: 0,
        actions: [
          _isSaving 
            ? const Center(child: Padding(padding: EdgeInsets.only(right: 20), child: CircularProgressIndicator(strokeWidth: 2)))
            : TextButton(
                onPressed: _saveCharacter,
                child: const Text('GENERATE', style: TextStyle(color: Color(0xFFEC4899), fontWeight: FontWeight.bold)),
              )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E3257),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEC4899), width: 2),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, color: Color(0xFFEC4899), size: 30),
                      SizedBox(height: 8),
                      Text('DALL-E 3\nAvatar', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text('Identity', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Character Name',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF1E2140),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _backstoryController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Backstory & Memory Rules...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF1E2140),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 30),
              const Text('Personality Tuning', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildSlider('Humor / Funny', _funnySlider, (val) => setState(() => _funnySlider = val)),
              _buildSlider('Serious / Stoic', _seriousSlider, (val) => setState(() => _seriousSlider = val)),
              _buildSlider('Romantic / Flirty', _romanticSlider, (val) => setState(() => _romanticSlider = val)),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Slider(
          value: value,
          activeColor: const Color(0xFFEC4899),
          inactiveColor: const Color(0xFF2E3257),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
