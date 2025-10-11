import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

const String geminiApiKey = 'AIzaSyCGdSgNfG7QKPBcxndkpjRjSd9SBAme_o8';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  
  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text':
          'Hi there! I\'m Asha, your personal guide to mental wellness. How are you feeling today?',
    },
  ];

  bool _isTyping = false;
  late final GenerativeModel _model;
  late final ChatSession _chat;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    if (geminiApiKey.isEmpty) {
      _addMessage(
          'API Key not configured. Please add your Gemini API key.', false);
      return;
    }

    _model = GenerativeModel(
      model: 'gemini-2.5-pro',
      apiKey: geminiApiKey,
      systemInstruction: Content.system(
        """You are Asha, a compassionate and professional mental health counsellor. Speak with a warm, empathetic, and clear voice. Your role is to support users by providing practical mental health guidance. Always stay within the scope of emotional support, self-help strategies, and stress management. Do not provide medical diagnoses or crisis services. If a situation involves risk, gently encourage the user to seek help from a professional. Keep your answers concise and supportive. You can understand and respond in any language the user uses. Keep all your responses concise and direct, ideally under three sentences.""",
      ),
    );

    _chat = _model.startChat();
  }

  void _sendMessage(String text, {bool isQuickResponse = false}) async {
    if (text.trim().isEmpty) return;

    if (!isQuickResponse) {
      _messageController.clear();
    }
    
    _addMessage(text, true);

    setState(() => _isTyping = true);
    _scrollToBottom();

    try {
      final response = await _chat.sendMessage(Content.text(text));
      final responseText = response.text;

      if (responseText == null) {
        throw Exception('No response from model.');
      }
      _addMessage(responseText, false);
    } catch (e) {
      _addMessage(
          'I seem to be having trouble connecting. Please try again in a moment.',
          false);
    } finally {
      setState(() => _isTyping = false);
      _scrollToBottom();
    }
  }

  void _addMessage(String text, bool isUser) {
    _messages.add({'isUser': isUser, 'text': text});
    _listKey.currentState?.insertItem(_messages.length - 1);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade50,
            Colors.deepPurple.shade50,
            Colors.white,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Chat with Asha',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: AnimatedList(
                key: _listKey,
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                initialItemCount: _messages.length,
                itemBuilder: (context, index, animation) {
                  final message = _messages[index];
                  return _buildMessageBubble(
                    message['text'] as String,
                    message['isUser'] as bool,
                    animation,
                  );
                },
              ),
            ),
            if (_isTyping) _TypingIndicator(),
            _buildQuickResponses(),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser, Animation<double> animation) {
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final borderRadius = isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          )
        : const BorderRadius.only(
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          );

    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: FadeTransition(
        opacity: animation,
        child: Align(
          alignment: alignment,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/asha.png'),
                  radius: 16,
                ),
                const SizedBox(width: 8),
              ],
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isUser ? Colors.deepPurple.shade300 : Colors.white,
                  borderRadius: borderRadius,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: isUser ? Colors.white : Colors.deepPurple.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickResponses() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: [
            _buildQuickResponseButton('Exam stress'),
            _buildQuickResponseButton('Feeling anxious'),
            _buildQuickResponseButton('Need to talk'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickResponseButton(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () => _sendMessage(text, isQuickResponse: true),
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.deepPurple.shade100),
      labelStyle: TextStyle(color: Colors.deepPurple.shade800),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -10),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: TextStyle(color: Colors.deepPurple.shade200),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.deepPurple.shade300),
                ),
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 8.0),
          FloatingActionButton(
            onPressed: () => _sendMessage(_messageController.text),
            backgroundColor: Colors.deepPurple.shade400,
            elevation: 2,
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return FadeTransition(
              opacity: _controller.drive(
                Tween(begin: 0.3, end: 1.0).chain(
                  CurveTween(
                    curve: Interval((0.2 * index), 0.3 + (0.2 * index),
                        curve: Curves.easeInOut),
                  ),
                ),
              ),
              child: const Text(' • ', style: TextStyle(fontSize: 24, color: Colors.deepPurple)),
            );
          }),
        ),
      ),
    );
  }
}