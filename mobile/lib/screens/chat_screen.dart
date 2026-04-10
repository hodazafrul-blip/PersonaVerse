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

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final text = _controller.text;
    _controller.clear();

    setState(() {
      _messages.insert(0, {'text': text, 'sender': 'user'});
      _isTyping = true;
    });

    try {
      // Mocking user_id = 1 for now
      final response = await _apiService.sendMessage(1, widget.character['id'], text);
      setState(() {
        _messages.insert(0, {'text': response['content'], 'sender': 'character'});
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isTyping = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.character['avatar_url'] != null 
                  ? NetworkImage(widget.character['avatar_url']) 
                  : null,
            ),
            const SizedBox(width: 10),
            Text(widget.character['name']),
          ],
        ),
        backgroundColor: const Color(0xFF1E2140),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == 0) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Typing...', style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }
                final msg = _messages[_isTyping ? index - 1 : index];
                final isUser = msg['sender'] == 'user';
                
                return Bubble(
                  margin: const BubbleEdges.only(top: 10),
                  alignment: isUser ? Alignment.topRight : Alignment.topLeft,
                  nip: isUser ? BubbleNip.rightBottom : BubbleNip.leftBottom,
                  color: isUser ? const Color(0xFF6366F1) : const Color(0xFF2E3257),
                  child: Text(
                    msg['text'],
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            color: const Color(0xFF1E2140),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.grey),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF6366F1)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
