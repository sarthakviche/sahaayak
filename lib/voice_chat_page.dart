import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

const String geminiApiKey = 'AIzaSyCGdSgNfG7QKPBcxndkpjRjSd9SBAme_o8';

class VoiceChatPage extends StatefulWidget {
  const VoiceChatPage({super.key});

  @override
  State<VoiceChatPage> createState() => _VoiceChatPageState();
}

// Add TickerProviderStateMixin for animations
class _VoiceChatPageState extends State<VoiceChatPage>
    with TickerProviderStateMixin {
  // AI and Message State
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  // Voice Services State
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;

  // UI & Animation State
  bool _isInitialized = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String _statusText = "Initializing...";

  @override
  void initState() {
    super.initState();
    _initialize();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.0, end: 12.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initialize() async {
    _model = GenerativeModel(
      model: 'gemini-2.5-pro',
      apiKey: geminiApiKey,
      systemInstruction: Content.system(
        """You are Asha, a compassionate and professional mental health counsellor. Speak with a warm, empathetic, and clear voice. Your role is to support users by providing practical mental health guidance. Always stay within the scope of emotional support, self-help strategies, and stress management. Do not provide medical diagnoses or crisis services. If a situation involves risk, gently encourage the user to seek help from a professional. Keep your answers concise and supportive. You can understand and respond in any language the user uses. Keep all your responses concise and direct, ideally under three sentences.""",
      ),
    );
    _chat = _model.startChat();

    await Permission.microphone.request();
    await _speechToText.initialize();
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.55);

    if (mounted) {
      setState(() {
        _isInitialized = true;
        _statusText = "Tap the mic to begin";
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- Voice Logic ---
  void _startListening() async {
    if (!_isInitialized || _isListening) return;
    bool available = await _speechToText.initialize();
    if (available) {
      setState(() {
        _isListening = true;
        _statusText = "Listening...";
      });
      _speechToText.listen(
        onResult: (result) {
          if (result.finalResult && result.recognizedWords.isNotEmpty) {
            _sendToGemini(result.recognizedWords);
            setState(() => _isListening = false);
          }
        },
        listenFor: const Duration(seconds: 20),
        pauseFor: const Duration(seconds: 5),
      );
    }
  }

  void _stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      setState(() {
        _isListening = false;
        _statusText = "Tap the mic to begin";
      });
    }
  }

  // --- AI Logic ---
  Future<void> _sendToGemini(String text) async {
    _addMessage(text, isUser: true);

    try {
      final response = await _chat.sendMessage(Content.text(text));
      final responseText = response.text;

      if (responseText != null) {
        _addMessage(responseText, isUser: false);
        _speak(responseText);
      } else {
        _showError("I'm having trouble responding right now.");
      }
    } catch (e) {
      _showError("An error occurred. Please check your connection.");
    }
    setState(() => _statusText = "Tap the mic to begin");
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  // --- UI Helpers ---
  void _addMessage(String text, {required bool isUser}) {
    _messages.add({'text': text, 'isUser': isUser});
    _listKey.currentState?.insertItem(_messages.length - 1);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE6E6FA), // Light Lavender
            Color(0xFFE0F7FA), // Pale Blue
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            // Background Illustration
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SvgPicture.asset(
                'assets/calm_wave.png',
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.4), BlendMode.srcIn),
              ),
            ),
            // Main Content
            Column(
              children: [
                Expanded(child: _buildChatList()),
                _buildBottomUI(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite_border, color: Colors.black54, size: 22),
          const SizedBox(width: 8),
          Text(
            'Asha Voice',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return AnimatedList(
      key: _listKey,
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      initialItemCount: _messages.length,
      itemBuilder: (context, index, animation) {
        final message = _messages[index];
        return _buildMessageBubble(
          text: message['text'],
          isUser: message['isUser'],
          animation: animation,
        );
      },
    );
  }

  Widget _buildBottomUI() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        children: [
          Text(
            '"The best way out is always through."',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              color: Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),
          _buildPulsingMicButton(),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Text(
              _statusText,
              key: ValueKey<String>(_statusText),
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingMicButton() {
    return GestureDetector(
      onTap: _isInitialized ? (_isListening ? _stopListening : _startListening) : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The pulsing glow
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9C27B0).withOpacity(0.4),
                      blurRadius: _pulseAnimation.value,
                      spreadRadius: _pulseAnimation.value / 2,
                    ),
                  ],
                ),
              );
            },
          ),
          // The button itself
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.purple.shade300, Colors.deepPurple.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Icon(
              _isListening ? Icons.mic_off : Icons.mic,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String text,
    required bool isUser,
    required Animation<double> animation,
  }) {
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = isUser ? Colors.white : Colors.deepPurple.shade50;
    final textColor = isUser ? Colors.black87 : Colors.deepPurple.shade900;

    return SlideTransition(
      position: Tween<Offset>(
        begin: isUser ? const Offset(1, 0) : const Offset(-1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
      child: FadeTransition(
        opacity: animation,
        child: Align(
          alignment: alignment,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(text, style: TextStyle(color: textColor)),
          ),
        ),
      ),
    );
  }
}