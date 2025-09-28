import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'previous_journals_page.dart';

// 🚨 IMPORTANT: DO NOT HARDCODE YOUR API KEY.
// Use a package like flutter_dotenv to load it from a .env file.
// For example: const String geminiApiKey = dotenv.env['GEMINI_API_KEY']!;
const String geminiApiKey = "use your api key here";

class VoiceJournalPage extends StatefulWidget {
  const VoiceJournalPage({super.key});

  @override
  State<VoiceJournalPage> createState() => _VoiceJournalPageState();
}

class _VoiceJournalPageState extends State<VoiceJournalPage> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecorderInitialized = false;
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _filePath;

  late final GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();

    // ✅ CORRECTED MODEL INITIALIZATION
    _model = GenerativeModel(
      model: 'gemini-2.5-pro', // Using the correct model name
      apiKey: geminiApiKey,
    );
  }

  Future<void> _initializeRecorder() async {
    final micStatus = await Permission.microphone.request();
    if (micStatus != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Microphone permission is required to record a journal.',
            ),
          ),
        );
      }
      return;
    }

    await _recorder.openRecorder();
    await _recorder.setSubscriptionDuration(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isRecorderInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (!_isRecorderInitialized) return;

    if (_isRecording) {
      await _recorder.stopRecorder();
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });
      await _processJournalEntry();
    } else {
      final tempDir = await getTemporaryDirectory();
      _filePath = '${tempDir.path}/voice_journal.m4a';
      await _recorder.startRecorder(toFile: _filePath, codec: Codec.aacMP4);
      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _processJournalEntry() async {
    if (_filePath == null) {
      setState(() => _isProcessing = false);
      return;
    }

    try {
      final file = File(_filePath!);
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception("User not logged in");
      }

      final prompt = TextPart(
        "Transcribe the following audio precisely. Then, based on the transcript, create a concise title (3–5 words) and a short summary (2–3 sentences). Format the output as a JSON object with three keys: 'title', 'summary', 'transcript'. Do not include anything outside the raw JSON object.",
      );

      final audioBytes = await file.readAsBytes();
      final audioPart = DataPart('audio/mp4', audioBytes);

      final response = await _model.generateContent([
        Content.multi([prompt, audioPart]),
      ]);

      final cleanResponse = response.text!
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final journalData = jsonDecode(cleanResponse) as Map<String, dynamic>;

      await supabase.from('journals').insert({
        'user_id': user.id,
        'title': journalData['title'],
        'summary': journalData['summary'],
        'transcript': journalData['transcript'],
      });

      await file.delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Journal entry saved successfully!')),
        );
      }
    } catch (e) {
      debugPrint('Error processing journal: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save journal: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Widget _buildMicButton() {
    if (_isProcessing) {
      return const CircularProgressIndicator(color: Colors.white);
    }
    return Icon(_isRecording ? Icons.stop : Icons.mic, size: 80);
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF5A8E3F);
    final Color backgroundColor = const Color(0xFFF0F5E6);
    final bool isButtonEnabled = _isRecorderInitialized && !_isProcessing;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Voice Journal',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(flex: 2),
              Text(
                'ı ı ı ı ı', // Corrected the visualizer text
                style: TextStyle(
                  color: primaryColor.withOpacity(_isRecording ? 1.0 : 0.6),
                  fontSize: 48,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 150,
                height: 150,
                child: ElevatedButton(
                  onPressed: isButtonEnabled ? _toggleRecording : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 8,
                    disabledBackgroundColor: Colors.grey.shade400,
                  ),
                  child: _buildMicButton(),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Press the button and start talking.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
              const SizedBox(height: 15),
              Text(
                'This is your private space to record your thoughts. These are one-sided recordings, not a chat with an AI.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PreviousJournalsPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history, color: Colors.white),
                  label: const Text(
                    'View Previous Journals',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor.withOpacity(0.9),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
