import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/speech_service.dart';

class ChatbotScreen extends StatefulWidget {
  final bool autoStartVoice;

  const ChatbotScreen({super.key, this.autoStartVoice = false});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'sender': 'bot',
      'text': 'Namaskaram! I am YathraKerala AI Travel Assistant (TransitGPT). You can type or tap the microphone to ask about routes, bus timings, fares, or travel options during rain!'
    }
  ];
  bool _isSending = false;
  bool _isListening = false;
  String _selectedLang = 'en-IN'; // 'en-IN' or 'ml-IN'
  String _listeningStatus = '';
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    // Microphone is strictly OFF by default; activates only when user taps the mic button
  }

  @override
  void dispose() {
    SpeechService.stopListening();
    _pulseController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toggleListening() {
    if (_isListening) {
      SpeechService.stopListening();
      setState(() {
        _isListening = false;
        _listeningStatus = '';
      });
      if (_controller.text.trim().isNotEmpty) {
        _sendMessage();
      }
    } else {
      setState(() {
        _isListening = true;
        _listeningStatus = 'Listening... Speak your travel question now';
      });

      SpeechService.startListening(
        lang: _selectedLang,
        onResult: (text, isFinal) {
          if (!mounted) return;
          setState(() {
            _controller.text = text;
          });
          if (isFinal && text.trim().isNotEmpty) {
            setState(() {
              _isListening = false;
              _listeningStatus = '';
            });
            _sendMessage(text);
          }
        },
        onEnd: () {
          if (!mounted) return;
          setState(() {
            _isListening = false;
            _listeningStatus = '';
          });
        },
        onError: (err) {
          if (!mounted) return;
          setState(() {
            _isListening = false;
            _listeningStatus = '';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Microphone voice input: $err'),
              backgroundColor: Colors.red.shade800,
            ),
          );
        },
      );
    }
  }

  Future<void> _sendMessage([String? preset]) async {
    final text = preset ?? _controller.text.trim();
    if (text.isEmpty) return;

    if (_isListening) {
      SpeechService.stopListening();
      setState(() => _isListening = false);
    }

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isSending = true;
    });
    _controller.clear();

    final reply = await ApiService.askChatbot(text);
    if (!mounted) return;
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
            Icon(Icons.smart_toy, color: Colors.amberAccent),
            SizedBox(width: 8),
            Text('TransitGPT AI Assistant'),
          ],
        ),
        backgroundColor: const Color(0xFF1565C0), // Primary Blue
        foregroundColor: Colors.white,
        actions: [
          // Voice Language Selector
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PopupMenuButton<String>(
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language, size: 18, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    _selectedLang == 'en-IN' ? 'EN' : 'ML',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              tooltip: 'Voice Search Language',
              onSelected: (val) {
                setState(() => _selectedLang = val);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Voice search language set to: ${val == 'en-IN' ? 'English (India)' : 'Malayalam (മലയാളം)'}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'en-IN',
                  child: Text('English (India) - en-IN'),
                ),
                const PopupMenuItem(
                  value: 'ml-IN',
                  child: Text('Malayalam (മലയാളം) - ml-IN'),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Top AI & Speech Info Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFFE3F2FD),
            child: Row(
              children: [
                const Icon(Icons.psychology, size: 20, color: Color(0xFF1565C0)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'LLM-powered GTFS travel assistant • Tap microphone to speak in English / Manglish',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.mic, size: 12, color: Colors.white),
                      SizedBox(width: 2),
                      Text('VOICE AI', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
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
                  avatar: const Icon(Icons.directions_bus, size: 14),
                  label: const Text('Chemperi to Kannur route?'),
                  onPressed: () => _sendMessage('How do I travel from Chemperi to Kannur?'),
                ),
                const SizedBox(width: 6),
                ActionChip(
                  avatar: const Icon(Icons.currency_rupee, size: 14),
                  label: const Text('Public transit fares in Kerala'),
                  onPressed: () => _sendMessage('What are the auto and bus fares in Kerala?'),
                ),
                const SizedBox(width: 6),
                ActionChip(
                  avatar: const Icon(Icons.thunderstorm, size: 14),
                  label: const Text('Rain advice'),
                  onPressed: () => _sendMessage('Suggest best route during heavy rain'),
                ),
                const SizedBox(width: 6),
                ActionChip(
                  avatar: const Icon(Icons.train, size: 14),
                  label: const Text('Fastest to Kozhikode'),
                  onPressed: () => _sendMessage('What is the fastest way from Kannur to Kozhikode?'),
                ),
              ],
            ),
          ),

          // Message Bubble List
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
                      color: isUser ? const Color(0xFF1565C0) : Colors.grey.shade100,
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

          // Pulsing Voice Listening Status Bar
          if (_isListening)
            AnimatedBuilder(
              animation: _pulseController,
              builder: (ctx, child) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50.withOpacity(0.8 + 0.2 * _pulseController.value),
                    border: Border(top: BorderSide(color: Colors.red.shade300)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red.shade600,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.5 * _pulseController.value),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.mic, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _listeningStatus.isNotEmpty
                              ? _listeningStatus
                              : 'Listening to your voice... Speak now',
                          style: TextStyle(
                            color: Colors.red.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red.shade800,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                        icon: const Icon(Icons.stop_circle, size: 16),
                        label: const Text('Done & Ask', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        onPressed: _toggleListening,
                      ),
                    ],
                  ),
                );
              },
            ),

          if (_isSending)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1565C0))),
                  SizedBox(width: 8),
                  Text('TransitGPT LLM is thinking...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),

          // Bottom Input Bar with Microphone & Send
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Text input field
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: _isListening
                            ? 'Listening to speech...'
                            : 'Ask travel question or tap microphone...',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Microphone Button
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (ctx, child) {
                      return CircleAvatar(
                        backgroundColor: _isListening
                            ? Colors.red.shade600
                            : const Color(0xFF1565C0),
                        radius: 20,
                        child: IconButton(
                          icon: Icon(
                            _isListening ? Icons.graphic_eq : Icons.mic,
                            color: Colors.white,
                            size: 20,
                          ),
                          tooltip: _isListening ? 'Stop Listening' : 'Voice Search with LLM (Microphone)',
                          onPressed: _toggleListening,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 6),

                  // Send Button
                  CircleAvatar(
                    backgroundColor: const Color(0xFF0D47A1),
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      tooltip: 'Send Query',
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
