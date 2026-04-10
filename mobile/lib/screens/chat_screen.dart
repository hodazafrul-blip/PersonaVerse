import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:bubble/bubble.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> character;
  
  const ChatScreen({super.key, required this.character});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ApiService _apiService = ApiService();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  bool _isVoiceEnabled = false;
  int _affinityScore = 0;
  String _relationshipStage = 'Stranger';

  @override
  void initState() {
    super.initState();
    _messages.add({
      'text': "Hi there! I'm ${widget.character['name']}. Have you been looking for me?", 
      'sender': 'character'
    });
    _affinityScore = widget.character['affinity_score'] ?? 0;
    _relationshipStage = widget.character['relationship_stage'] ?? 'Stranger';
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final text = _controller.text;
    _controller.clear();

    setState(() {
      _messages.insert(0, {'text': text, 'sender': 'user'});
      _isTyping = true;
    });

    try {
      final response = await _apiService.sendMessage(1, widget.character['id'], text);
      if (mounted) {
        setState(() {
          _messages.insert(0, {'text': response['content'], 'sender': 'character'});
          _affinityScore = response['affinity_score'] ?? _affinityScore;
          _relationshipStage = response['relationship_stage'] ?? _relationshipStage;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isTyping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Hero(
              tag: 'avatar_${widget.character['id']}',
              child: CircleAvatar(
                radius: 20,
                backgroundImage: widget.character['avatar_url'] != null 
                    ? NetworkImage(widget.character['avatar_url']) 
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.character['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Online • $_relationshipStage Stage', style: const TextStyle(color: Color(0xFFEC4899), fontSize: 10)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isVoiceEnabled ? Icons.volume_up : Icons.volume_off, color: Color(0xFFEC4899), size: 20),
            onPressed: () => setState(() => _isVoiceEnabled = !_isVoiceEnabled),
          ),
          IconButton(icon: const Icon(Icons.videocam, color: Colors.white, size: 20), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.white, size: 20), onPressed: () {}),
        ],
        backgroundColor: const Color(0xFF1E2140),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF1E2140),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('Affinity', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (_affinityScore % 100) / 100.0,
                      backgroundColor: const Color(0xFF2E3257),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFEC4899)),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text('Lvl ${(_affinityScore / 50).floor() + 1}', style: const TextStyle(color: Colors.pinkAccent, fontSize: 10)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == 0) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Typing...', style: TextStyle(color: Color(0xFFEC4899), fontStyle: FontStyle.italic)),
                    ),
                  );
                }
                final msg = _messages[_isTyping ? index - 1 : index];
                final isUser = msg['sender'] == 'user';
                
                return Bubble(
                  margin: const BubbleEdges.only(top: 15),
                  alignment: isUser ? Alignment.topRight : Alignment.topLeft,
                  nip: isUser ? BubbleNip.rightBottom : BubbleNip.leftBottom,
                  color: isUser ? const Color(0xFF6366F1) : const Color(0xFF2E3257),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      msg['text'],
                      style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12).copyWith(bottom: MediaQuery.of(context).padding.bottom + 12),
            decoration: const BoxDecoration(
              color: Color(0xFF1E2140),
              border: Border(top: BorderSide(color: Colors.black12)),
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E3257),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E3257),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Message...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF6366F1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
