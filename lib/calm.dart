import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';

// Main entry point for the "Calm Now" feature
class CalmNowPage extends StatelessWidget {
  const CalmNowPage({super.key});

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
            icon: Icon(Icons.arrow_back, color: Colors.grey.shade800),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Calm Now',
            style: GoogleFonts.quicksand(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildSection(
                  context,
                  title: 'Relax',
                  subtitle: 'Mind-Body Calm',
                  activities: [
                    _buildActivityCard(context, title: 'Breathing Exercises', subtitle: 'Box, 4-7-8, Paced', icon: Icons.air_rounded, color: Colors.deepPurple, page: const BreathingExercisePage()),
                    _buildActivityCard(context, title: 'Quick Reframe', subtitle: '"Fact or Fear?"', icon: Icons.lightbulb_outline_rounded, color: Colors.purple, page: const QuickReframePage()),
                    _buildActivityCard(context, title: 'Audio Relaxations', subtitle: 'Safe Place, Body Scan', icon: Icons.headphones_rounded, color: Colors.deepPurple, page: const AudioRelaxationsPage()),
                  ],
                ),
                _buildPsychologyMapping('Based on ACT & CBT'),
                _buildSection(
                  context,
                  title: 'Ground',
                  subtitle: 'Distress Tolerance',
                  activities: [
                    _buildActivityCard(context, title: '5-4-3-2-1 Grounding', subtitle: 'Interactive checklist', icon: Icons.visibility_outlined, color: Colors.blueGrey, page: const GroundingPage()),
                    _buildActivityCard(context, title: 'STOP Skill', subtitle: 'Take a step back', icon: Icons.pan_tool_alt_outlined, color: Colors.grey.shade600, page: const STOPPage()),
                    _buildActivityCard(context, title: 'Soothing Sounds', subtitle: 'Rain, waves, birds', icon: Icons.music_note_rounded, color: Colors.blueGrey, page: const SoothingSoundsPage()),
                  ],
                ),
                _buildPsychologyMapping('Based on DBT Distress Tolerance'),
                _buildSection(
                  context,
                  title: 'Distract',
                  subtitle: 'Shift Attention',
                  activities: [
                     _buildActivityCard(context, title: 'Mini-games', subtitle: 'Bubble pop, dot tracing', icon: Icons.videogame_asset_outlined, color: Colors.teal, page: const MiniGamesPage()),
                     _buildActivityCard(context, title: 'Quick Doodle Pad', subtitle: 'Draw to clear your mind', icon: Icons.brush_rounded, color: Colors.indigo, page: const DoodlePadPage()),
                     _buildActivityCard(context, title: 'Light Quizzes', subtitle: 'Fun facts & trivia', icon: Icons.quiz_outlined, color: Colors.teal, page: const LightQuizzesPage()),
                  ],
                ),
                _buildPsychologyMapping('Based on DBT Distraction'),
                 _buildSection(
                  context,
                  title: 'Reflect',
                  subtitle: 'Acceptance & Values',
                  activities: [
                     _buildActivityCard(context, title: 'ACT Defusion Prompt', subtitle: '"I\'m having the thought that..."', icon: Icons.psychology_outlined, color: Colors.pink, page: const DefusionPage()),
                     _buildActivityCard(context, title: 'Values Check-In', subtitle: 'Align with what matters', icon: Icons.favorite_border_rounded, color: Colors.red, page: const ValuesCheckInPage()),
                     _buildActivityCard(context, title: 'Mood Note', subtitle: '30-second journal', icon: Icons.mode_edit_outline_rounded, color: Colors.pink, page: const MoodNotePage()),
                  ],
                ),
                _buildPsychologyMapping('Based on ACT & CBT'),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {
    required String title,
    required String subtitle,
    required List<Widget> activities,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(title, style: GoogleFonts.quicksand(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
        Text(subtitle, style: GoogleFonts.lato(fontSize: 16, color: Colors.black54)),
        const SizedBox(height: 16),
        SizedBox(
          height: 200, // give a bit more vertical space to avoid clipping
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: activities.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: activities[index],
            ),
          ),
        ),
      ],
    );
  }

  // ✅ FIXED: Dynamic height card to avoid overflow
  Widget _buildActivityCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget page,
  }) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => page)),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // ✅ allows the card to expand dynamically
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.quicksand(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.lato(fontSize: 13, color: Colors.black54),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPsychologyMapping(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 4.0),
      child: Chip(
        avatar: Icon(Icons.psychology_alt_outlined, color: Colors.purple.shade800, size: 18),
        label: Text(text),
        backgroundColor: Colors.purple.shade50,
        labelStyle: GoogleFonts.lato(color: Colors.purple.shade900),
      ),
    );
  }
}

// --- REUSABLE THEMED SCAFFOLD WIDGET ---
class ThemedActivityPage extends StatelessWidget {
  final String title;
  final Widget body;

  const ThemedActivityPage({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple.shade50, Colors.deepPurple.shade50, Colors.white],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.grey.shade800),
          title: Text(title, style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
        body: body,
      ),
    );
  }
}

// --- INDIVIDUAL ACTIVITY PAGES ---
class BreathingExercisePage extends StatefulWidget {
  const BreathingExercisePage({super.key});

  @override
  State<BreathingExercisePage> createState() => _BreathingExercisePageState();
}

class _BreathingExercisePageState extends State<BreathingExercisePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _instructionText = 'Breathe In';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _controller.addListener(() {
      if (_controller.status == AnimationStatus.forward) {
        if (_instructionText != 'Breathe In') setState(() => _instructionText = 'Breathe In');
      } else if (_controller.status == AnimationStatus.reverse) {
        if (_instructionText != 'Breathe Out') setState(() => _instructionText = 'Breathe Out');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemedActivityPage(
      title: 'Breathing Exercise',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Text(_instructionText, style: GoogleFonts.quicksand(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple.shade700)),
            const SizedBox(height: 60),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_controller.value * 0.5),
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade200, Colors.deepPurple.shade300],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)],
                    ),
                  ),
                );
              },
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}

class QuickReframePage extends StatelessWidget {
  const QuickReframePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    const reframes = ["Is this thought a fact or a fear?", "What’s another way to see this?", "What would I tell a friend in this situation?"];
    final randomReframe = (reframes..shuffle()).first;

    return ThemedActivityPage(
      title: 'Quick Reframe',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Consider this reframe:', textAlign: TextAlign.center, style: GoogleFonts.lato(fontSize: 18, color: Colors.black54)),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.1), blurRadius: 15)],
                ),
                child: Text(randomReframe, textAlign: TextAlign.center, style: GoogleFonts.quicksand(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple.shade800)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder helper
Widget _buildPlaceholder(IconData icon, String text, Color color) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 80, color: color.withOpacity(0.3)),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(fontSize: 18, color: Colors.black54),
          ),
        ),
      ],
    ),
  );
}

// Placeholder pages
class AudioRelaxationsPage extends StatelessWidget {
  const AudioRelaxationsPage({super.key});
  @override
  Widget build(BuildContext context) => ThemedActivityPage(title: 'Audio Relaxations', body: _buildPlaceholder(Icons.headphones_rounded, "Guided audio sessions are coming soon.", Colors.deepPurple));
}

class GroundingPage extends StatelessWidget {
  const GroundingPage({super.key});
  @override
  Widget build(BuildContext context) => ThemedActivityPage(title: '5-4-3-2-1 Grounding', body: _buildPlaceholder(Icons.visibility_rounded, "An interactive grounding exercise is coming soon.", Colors.blueGrey));
}

class STOPPage extends StatelessWidget {
  const STOPPage({super.key});
  @override
  Widget build(BuildContext context) => ThemedActivityPage(title: 'STOP Skill', body: _buildPlaceholder(Icons.pan_tool_alt_rounded, "A guide for the STOP skill is coming soon.", Colors.grey.shade600));
}

class SoothingSoundsPage extends StatelessWidget {
  const SoothingSoundsPage({super.key});
  @override
  Widget build(BuildContext context) => ThemedActivityPage(title: 'Soothing Sounds', body: _buildPlaceholder(Icons.waves_rounded, "Relaxing sounds of nature are coming soon.", Colors.blueGrey));
}

class MiniGamesPage extends StatelessWidget {
  const MiniGamesPage({super.key});
  @override
  Widget build(BuildContext context) => ThemedActivityPage(title: 'Mini-Games', body: _buildPlaceholder(Icons.videogame_asset_outlined, "Simple games to help you refocus are coming soon.", Colors.teal));
}

class DoodlePadPage extends StatelessWidget {
  const DoodlePadPage({super.key});
  @override
  Widget build(BuildContext context) => ThemedActivityPage(title: 'Doodle Pad', body: _buildPlaceholder(Icons.brush_rounded, "A simple doodle pad to clear your mind is coming soon.", Colors.indigo));
}

class LightQuizzesPage extends StatelessWidget {
  const LightQuizzesPage({super.key});
  @override
  Widget build(BuildContext context) => ThemedActivityPage(title: 'Light Quizzes', body: _buildPlaceholder(Icons.quiz_outlined, "Fun and light quizzes are coming soon.", Colors.teal));
}

class DefusionPage extends StatelessWidget {
  const DefusionPage({super.key});
  @override
  Widget build(BuildContext context) => ThemedActivityPage(title: 'Defusion Prompt', body: _buildPlaceholder(Icons.psychology_outlined, 'The prompt: "I am having the thought that..." is coming soon.', Colors.pink));
}

class ValuesCheckInPage extends StatelessWidget {
  const ValuesCheckInPage({super.key});
  @override
  Widget build(BuildContext context) => ThemedActivityPage(title: 'Values Check-In', body: _buildPlaceholder(Icons.favorite_border_rounded, "An exercise to check in with your core values is coming soon.", Colors.red));
}

class MoodNotePage extends StatelessWidget {
  const MoodNotePage({super.key});
  @override
  Widget build(BuildContext context) => ThemedActivityPage(title: 'Mood Note', body: _buildPlaceholder(Icons.mode_edit_outline_rounded, "A 30-second mood journal is coming soon.", Colors.pink));
}

class ActivityPage extends StatelessWidget {
  final String activityName;
  const ActivityPage({super.key, required this.activityName});
  @override
  Widget build(BuildContext context) => ThemedActivityPage(title: activityName, body: _buildPlaceholder(Icons.construction_rounded, 'The "$activityName" activity is currently under construction.', Colors.orange));
}
