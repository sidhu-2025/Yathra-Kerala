import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'sender': 'bot',
      'text': 'Namaskaram! I am YathraKerala AI Travel Assistant (TransitGPT). Ask me about routes, bus timings, fares, or travel options during rain!'
    }
  ];
  bool _isSending = false;

  Future<void> _sendMessage([String? preset]) async {
    final text = preset ?? _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isSending = true;
    });
    _controller.clear();

    final reply = await ApiService.askChatbot(text);
    setState(() {
      _messages.add({'sender': 'bot', 'text': reply});
      _isSending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy, color: Colors.amber),
            SizedBox(width: 8),
            Text('TransitGPT AI Assistant'),
          ],
        ),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.teal.shade50,
            child: Row(
              children: [
                const Icon(Icons.psychology, size: 20, color: Colors.teal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'LLM-powered conversational route planner & GTFS intelligence',
                    style: TextStyle(fontSize: 12, color: Colors.teal.shade900),
                  ),
                ),
              ],
            ),
          ),
          // Suggested prompts chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                ActionChip(
                  label: const Text('Chemperi to Kannur route?'),
                  onPressed: () => _sendMessage('How do I travel from Chemperi to Kannur?'),
                ),
                const SizedBox(width: 6),
                ActionChip(
                  label: const Text('Public transit fares in Kerala'),
                  onPressed: () => _sendMessage('What are the auto and bus fares in Kerala?'),
                ),
                const SizedBox(width: 6),
                ActionChip(
                  label: const Text('Rain advice'),
                  onPressed: () => _sendMessage('Suggest best route during heavy rain'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                final isUser = m['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.teal.shade700 : Colors.grey.shade100,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(14),
                        topRight: const Radius.circular(14),
                        bottomLeft: Radius.circular(isUser ? 14 : 2),
                        bottomRight: Radius.circular(isUser ? 2 : 14),
                      ),
                      border: isUser ? null : Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      m['text'] ?? '',
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isSending)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 8),
                  Text('TransitGPT is thinking...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Ask travel question in English / Manglish...',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.teal.shade700,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: () => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
