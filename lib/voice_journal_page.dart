import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'previous_journals_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Securely access the API key provided at build time
const String geminiApiKey = 'AIzaSyCGdSgNfG7QKPBcxndkpjRjSd9SBAme_o8';

class VoiceJournalPage extends StatefulWidget {
  const VoiceJournalPage({super.key});

  @override
  State<VoiceJournalPage> createState() => _VoiceJournalPageState();
}

class _VoiceJournalPageState extends State<VoiceJournalPage> with TickerProviderStateMixin {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecorderInitialized = false;
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _filePath;

  late final GenerativeModel _model;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initialize();
    _setupAnimations();
  }

  Future<void> _initialize() async {
    // Correctly initialize the Gemini Model
    _model = GenerativeModel(
      model: 'gemini-2.5-pro',
      apiKey: geminiApiKey,
    );

    // Initialize the audio recorder
    final micStatus = await Permission.microphone.request();
    if (micStatus != PermissionStatus.granted) {
      // Handle permission denial gracefully
      return;
    }
    await _recorder.openRecorder();
    await _recorder.setSubscriptionDuration(const Duration(milliseconds: 100));
    if (mounted) {
      setState(() => _isRecorderInitialized = true);
    }
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

  @override
  void dispose() {
    _recorder.closeRecorder();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (!_isRecorderInitialized || _isProcessing) return;

    if (_isRecording) {
      _filePath = await _recorder.stopRecorder();
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });
      await _processJournalEntry();
    } else {
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/voice_journal.m4a';
      await _recorder.startRecorder(toFile: path, codec: Codec.aacMP4);
      setState(() => _isRecording = true);
    }
  }

  Future<void> _processJournalEntry() async {
    if (_filePath == null) {
      setState(() => _isProcessing = false);
      return;
    }

    try {
      final file = File(_filePath!);
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      // ✅ --- PROMPT UPDATED WITH THE NEW STRICT TAG LIST --- ✅
      final prompt = TextPart(
        """Transcribe the following audio precisely. Then, based on the transcript, perform these actions:
        1.  Create a concise title (3–5 words).
        2.  Create a short summary (2–3 sentences).
        3.  Analyze the transcript for key emotional themes and choose 3-5 of the most relevant tags ONLY from this specific list: ['Overwhelmed', 'Anxious', 'Isolated', 'Fatigued', 'Procrastinating', 'Self-Critical', 'Pressure', 'Conflicted', 'Productive', 'Grateful', 'Restless', 'Reflective', 'Focused', 'Content', 'Distressed']. Do not use any tags that are not in this list.

        Format the entire output as a single, raw JSON object with four keys: 'title', 'summary', 'transcript', and 'analysis_tags'. Do not include any text, notes, or markdown formatting outside the JSON object itself."""
      );

      final audioBytes = await file.readAsBytes();
      final audioPart = DataPart('audio/mp4', audioBytes);

      final response = await _model.generateContent([
        Content.multi([prompt, audioPart]),
      ]);

      final cleanResponse = response.text!.replaceAll(RegExp(r'```(json)?'), '').trim();
      final journalData = jsonDecode(cleanResponse) as Map<String, dynamic>;

      await Supabase.instance.client.from('journals').insert({
        'user_id': user.id,
        'title': journalData['title'],
        'summary': journalData['summary'],
        'transcript': journalData['transcript'],
        'analysis_tags': journalData['analysis_tags'],
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Voice Journal',
            style: GoogleFonts.quicksand(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Positioned(
              bottom: -50,
              left: 0,
              right: 0,
              child: SvgPicture.asset(
                'assets/images/calm_wave.svg',
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.5), BlendMode.srcIn),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(flex: 2),
                    _buildVisualizer(),
                    const Spacer(flex: 1),
                    _buildPulsingMicButton(),
                    const Spacer(flex: 1),
                    _buildInstructions(),
                    const Spacer(flex: 2),
                    _buildPreviousJournalsButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualizer() {
    return StreamBuilder<RecordingDisposition>(
      stream: _recorder.onProgress,
      builder: (context, snapshot) {
        final double decibels = snapshot.hasData ? snapshot.data!.decibels ?? 0.0 : 0.0;
        final normalizedDb = (max(0, decibels + 50)) / 50;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(30, (index) {
              final barHeight = (sin((index / 2) + (normalizedDb * 10)) + 1.5) * 25 * normalizedDb;
              return Container(
                width: 4,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: max(4, barHeight),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
          ),
        );
      },
    );
  }
  
  Widget _buildPulsingMicButton() {
    return GestureDetector(
      onTap: _toggleRecording,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isRecording)
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.4),
                        blurRadius: _pulseAnimation.value,
                        spreadRadius: _pulseAnimation.value,
                      ),
                    ],
                  ),
                );
              },
            ),
          Container(
            width: 120,
            height: 120,
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
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: _isProcessing 
              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
              : Icon(_isRecording ? Icons.stop_rounded : Icons.mic_none, color: Colors.white, size: 60),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    String text;
    if (_isProcessing) {
      text = 'Processing your thoughts...';
    } else if (_isRecording) {
      text = 'Tap the button to stop recording.';
    } else {
      text = 'Press the button and start talking.';
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
      child: Text(
        text,
        key: ValueKey<String>(text),
        textAlign: TextAlign.center,
        style: GoogleFonts.quicksand(
          fontSize: 16,
          color: Colors.black54,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPreviousJournalsButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PreviousJournalsPage(),
            ),
          );
        },
        icon: Icon(Icons.history, color: Colors.deepPurple.shade400),
        label: Text(
          'View Previous Journals',
          style: GoogleFonts.quicksand(
            color: Colors.deepPurple.shade400,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: Colors.deepPurple.shade200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}