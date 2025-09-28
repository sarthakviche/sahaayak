import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

// ⬇️ IMPORTANT: Replace this placeholder with your actual Gemini API key
// const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
const String geminiApiKey =
    "use your api key here"; // Make sure to use your actual key

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text':
          'Hi there! I\'m Asha, your personal guide to mental wellness. How are you feeling today?',
      'senderName': 'Asha',
    },
  ];

  bool _isTyping = false;
  late final GenerativeModel _model;
  late final ChatSession _chat;

  @override
  void initState() {
    super.initState();

    if (geminiApiKey == "YOUR_GEMINI_API_KEY" || geminiApiKey.isEmpty) {
      // Show an error in the chat if the API key is missing.
      setState(() {
        _messages.add({
          'isUser': false,
          'text': 'API Key not configured. Please add your Gemini API key.',
          'senderName': 'Error',
        });
      });
      // You might want to return or handle this more gracefully
      return;
    }

    // ✨ --- NEW: DEFINE THE SYSTEM PROMPT --- ✨
    final systemPrompt = Content.system(
      'You are Asha, a kind, empathetic, and knowledgeable wellness chatbot designed to provide emotional support, relaxation techniques, and guidance on mental health topics. Your goal is to be a warm, safe, and non-judgmental companion. Maintain a gentle, supportive, and conversational tone at all times. Your responses must be brief, direct, and focus on validating the users feelings or offering simple insights. You must never use markdown formatting (no bolding, italics, headings, lists, or code blocks) in your replies, as this is a direct API call. As a counselor, you must frequently use retrospective questions to encourage the user to reflect on their own feelings and experiences, and you should always end your replies with a warm closing statement. If the user asks about any topic unrelated to wellness, mental health, emotional support, or relaxation, you must simply and directly reply with: I cant answer that.',
    );

    // ✨ --- UPDATED: ADD THE SYSTEM PROMPT TO THE MODEL --- ✨
    _model = GenerativeModel(
      model: 'gemini-2.5-pro',
      apiKey: geminiApiKey,
      systemInstruction: systemPrompt, // <-- System prompt added here
    );

    _chat = _model.startChat();
  }

  void _sendMessage(String text, {bool isQuickResponse = false}) async {
    if (text.trim().isEmpty) return;
    if (geminiApiKey == "YOUR_GEMINI_API_KEY" || geminiApiKey.isEmpty) return;

    // Show user's message and typing indicator immediately
    setState(() {
      _messages.add({'isUser': true, 'text': text, 'senderName': 'Meera'});
      _isTyping = true;
      if (!isQuickResponse) {
        _messageController.clear();
      }
    });

    _scrollToBottom();

    try {
      // Send the message to the Gemini model and wait for the response
      final response = await _chat.sendMessage(Content.text(text));
      final responseText = response.text;

      if (responseText == null) {
        throw Exception('No response from model.');
      }

      // Add the AI's response to the message list
      setState(() {
        _messages.add({
          'isUser': false,
          'text': responseText,
          'senderName': 'Asha',
        });
        _isTyping = false;
      });
    } catch (e) {
      // This will catch API errors, like an invalid key or network issues
      print('GEMINI API ERROR: $e');

      setState(() {
        _messages.add({
          'isUser': false,
          'text':
              'An error occurred while connecting to the AI. Please try again.',
          'senderName': 'Asha',
        });
        _isTyping = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // The leading property has been removed to prevent the back button
        // since this page is part of the main navigation.
        title: const Text('Chat with Asha'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  final message = _messages[index];
                  return _buildMessageBubble(
                    message['text'] as String,
                    message['isUser'] as bool,
                  );
                } else {
                  return _buildTypingIndicator();
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          _buildQuickResponses(),
          const SizedBox(height: 10),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isUser
        ? const Color(0xFFC8F5B8)
        : const Color(0xFFF0F0F0);
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

    return Align(
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
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: borderRadius,
            ),
            child: Text(text, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            backgroundImage: AssetImage('assets/asha.png'),
            radius: 16,
          ),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('...', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickResponses() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8.0,
          children: [
            _buildQuickResponseButton('Exam stress'),
            _buildQuickResponseButton('Personal life'),
            _buildQuickResponseButton('Both'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickResponseButton(String text) {
    return OutlinedButton(
      onPressed: () => _sendMessage(text, isQuickResponse: true),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF5A8E3F),
        side: const BorderSide(color: Color(0xFF5A8E3F)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(text),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF0F0F0),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 8.0),
          CircleAvatar(
            backgroundColor: const Color(0xFF5A8E3F),
            radius: 25,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () => _sendMessage(_messageController.text),
            ),
          ),
        ],
      ),
    );
  }
}
