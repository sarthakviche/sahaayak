import 'package:flutter/material.dart';
import 'dart:async';

class CalmNowPage extends StatelessWidget {
  const CalmNowPage({super.key});

  // Define the colors from the provided palette
  static const Color primaryGreen = Color(0xFF63B96E);
  static const Color lightGreen = Color(0xFFC3E3A6);
  static const Color darkGreen = Color(0xFF286432);
  static const Color soothingBlue = Color(0xFFADD8E6);
  static const Color offWhite = Color(0xFFF0F0F0);
  static const Color lightBlueGreen = Color(0xFFD4EDDB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: offWhite,
        elevation: 0,
        centerTitle: false,
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Calm Now',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
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
                  _buildActivityCard(
                    context,
                    title: 'Breathing Exercises',
                    subtitle: 'Box, 4-7-8, Paced',
                    icon: Icons.air_rounded,
                    color: primaryGreen,
                    onTap: () =>
                        _navigateToActivity(context, 'Breathing Exercises'),
                  ),
                  _buildActivityCard(
                    context,
                    title: 'Quick Reframe',
                    subtitle: '"Fact or Fear?"',
                    icon: Icons.lightbulb_rounded,
                    color: lightGreen,
                    onTap: () => _navigateToActivity(context, 'Quick Reframe'),
                  ),
                  _buildActivityCard(
                    context,
                    title: 'Audio Relaxations',
                    subtitle: 'Safe Place, Body Scan',
                    icon: Icons.headphones_rounded,
                    color: primaryGreen,
                    onTap: () =>
                        _navigateToActivity(context, 'Audio Relaxations'),
                  ),
                ],
              ),
              _buildPsychologyMapping('ACT mindfulness & CBT'),
              _buildSection(
                context,
                title: 'Ground',
                subtitle: 'Distress Tolerance',
                activities: [
                  _buildActivityCard(
                    context,
                    title: '5-4-3-2-1 Grounding',
                    subtitle: 'Interactive checklist',
                    icon: Icons.visibility_rounded,
                    color: soothingBlue,
                    onTap: () =>
                        _navigateToActivity(context, '5-4-3-2-1 Grounding'),
                  ),
                  _buildActivityCard(
                    context,
                    title: 'STOP Skill',
                    subtitle: 'Take a step back...',
                    icon: Icons.pan_tool_alt_rounded,
                    color: lightBlueGreen,
                    onTap: () => _navigateToActivity(context, 'STOP Skill'),
                  ),
                  _buildActivityCard(
                    context,
                    title: 'Soothing Sounds',
                    subtitle: 'Rain, waves, birds...',
                    icon: Icons.music_note_rounded,
                    color: soothingBlue,
                    onTap: () =>
                        _navigateToActivity(context, 'Soothing Sounds'),
                  ),
                ],
              ),
              _buildPsychologyMapping('DBT distress tolerance'),
              _buildSection(
                context,
                title: 'Distract',
                subtitle: 'Shift Attention',
                activities: [
                  _buildActivityCard(
                    context,
                    title: 'Mini-games',
                    subtitle: 'Bubble pop, dot tracing',
                    icon: Icons.videogame_asset_rounded,
                    color: primaryGreen,
                    onTap: () => _navigateToActivity(context, 'Mini-games'),
                  ),
                  _buildActivityCard(
                    context,
                    title: 'Quick Doodle Pad',
                    subtitle: 'Draw to clear your mind',
                    icon: Icons.brush_rounded,
                    color: lightGreen,
                    onTap: () =>
                        _navigateToActivity(context, 'Quick Doodle Pad'),
                  ),
                  _buildActivityCard(
                    context,
                    title: 'Light Quizzes',
                    subtitle: 'Fun facts & trivia',
                    icon: Icons.quiz_rounded,
                    color: primaryGreen,
                    onTap: () => _navigateToActivity(context, 'Light Quizzes'),
                  ),
                ],
              ),
              _buildPsychologyMapping('DBT distraction'),
              _buildSection(
                context,
                title: 'Reflect',
                subtitle: 'Acceptance & Values',
                activities: [
                  _buildActivityCard(
                    context,
                    title: 'ACT Defusion Prompt',
                    subtitle: '"I\'m having the thought that..."',
                    icon: Icons.psychology_rounded,
                    color: soothingBlue,
                    onTap: () =>
                        _navigateToActivity(context, 'ACT Defusion Prompt'),
                  ),
                  _buildActivityCard(
                    context,
                    title: 'Values Check-In',
                    subtitle: 'Align with what matters',
                    icon: Icons.favorite_rounded,
                    color: lightBlueGreen,
                    onTap: () =>
                        _navigateToActivity(context, 'Values Check-In'),
                  ),
                  _buildActivityCard(
                    context,
                    title: 'Mood Note',
                    subtitle: '30-second journal',
                    icon: Icons.mode_edit_rounded,
                    color: soothingBlue,
                    onTap: () => _navigateToActivity(context, 'Mood Note'),
                  ),
                ],
              ),
              _buildPsychologyMapping('ACT & CBT'),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<Widget> activities,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: darkGreen,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(fontSize: 16, color: darkGreen.withOpacity(0.7)),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180, // Fixed height for horizontal scrolling
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: activities.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: activities[index],
              );
            },
          ),
        ),
      ],
    );
  }

  static Widget _buildActivityCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 180,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(icon, size: 36, color: Colors.white),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToActivity(BuildContext context, String activityName) {
    switch (activityName) {
      case 'Breathing Exercises':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const BreathingExercisePage(),
          ),
        );
        break;
      case 'Quick Reframe':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const QuickReframePage()),
        );
        break;
      case 'Audio Relaxations':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AudioRelaxationsPage()),
        );
        break;
      case '5-4-3-2-1 Grounding':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const GroundingPage()));
        break;
      case 'STOP Skill':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const STOPPage()));
        break;
      case 'Soothing Sounds':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const SoothingSoundsPage()),
        );
        break;
      case 'Mini-games':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const MiniGamesPage()));
        break;
      case 'Quick Doodle Pad':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const DoodlePadPage()));
        break;
      case 'Light Quizzes':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const LightQuizzesPage()),
        );
        break;
      case 'ACT Defusion Prompt':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const DefusionPage()));
        break;
      case 'Values Check-In':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ValuesCheckInPage()),
        );
        break;
      case 'Mood Note':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const MoodNotePage()));
        break;
      default:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ActivityPage(activityName: activityName),
          ),
        );
    }
  }

  static Widget _buildPsychologyMapping(String text) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: lightGreen.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.psychology_alt_rounded,
              color: darkGreen,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Based on: $text',
              style: const TextStyle(
                color: darkGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BreathingExercisePage extends StatefulWidget {
  const BreathingExercisePage({super.key});

  @override
  State<BreathingExercisePage> createState() => _BreathingExercisePageState();
}

class _BreathingExercisePageState extends State<BreathingExercisePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  String _instructionText = 'Breathe In';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _startBreathingCycle();
  }

  void _startBreathingCycle() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_controller.status == AnimationStatus.completed) {
        _controller.reverse();
        setState(() {
          _instructionText = 'Breathe Out';
        });
      } else if (_controller.status == AnimationStatus.dismissed) {
        _controller.forward();
        setState(() {
          _instructionText = 'Breathe In';
        });
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CalmNowPage.offWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: CalmNowPage.darkGreen),
        title: const Text(
          'Breathing Exercises',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: CalmNowPage.darkGreen,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _instructionText,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: CalmNowPage.darkGreen,
              ),
            ),
            const SizedBox(height: 40),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: CalmNowPage.primaryGreen.withOpacity(0.7),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: CalmNowPage.primaryGreen.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            const Text(
              'A simple paced breathing exercise',
              style: TextStyle(fontSize: 16, color: CalmNowPage.darkGreen),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickReframePage extends StatelessWidget {
  const QuickReframePage({super.key});

  final List<String> reframes = const [
    "Is this thought a fact or a fear?",
    "What’s another way to see this?",
    "What would you tell a friend in the same situation?",
    "Is this thought helpful?",
  ];

  @override
  Widget build(BuildContext context) {
    final randomReframe = (reframes.toList()..shuffle()).first;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: CalmNowPage.offWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: CalmNowPage.darkGreen),
        title: const Text(
          'Quick Reframe',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: CalmNowPage.darkGreen,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Think about a negative thought you have, then consider this reframe:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: CalmNowPage.darkGreen),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: CalmNowPage.lightGreen,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  randomReframe,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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

class AudioRelaxationsPage extends StatelessWidget {
  const AudioRelaxationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CalmNowPage.offWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: CalmNowPage.darkGreen),
        title: const Text(
          'Audio Relaxations',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: CalmNowPage.darkGreen,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.headphones_rounded,
                size: 80,
                color: CalmNowPage.primaryGreen,
              ),
              const SizedBox(height: 24),
              const Text(
                'Guided relaxation sessions coming soon!',
                style: TextStyle(fontSize: 20, color: CalmNowPage.darkGreen),
              ),
              const SizedBox(height: 16),
              const Text(
                'Imagine here you would have a list of audio files like "Safe Place Visualization" and "Body Scan".',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: CalmNowPage.darkGreen),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GroundingPage extends StatefulWidget {
  const GroundingPage({super.key});

  @override
  State<GroundingPage> createState() => _GroundingPageState();
}

class _GroundingPageState extends State<GroundingPage> {
  final List<String> senses = ["See", "Feel", "Hear", "Smell", "Taste"];
  final List<String> currentItems = ["", "", "", "", ""];
  int currentSenseIndex = 0;
  int remainingItems = 5;

  void _nextItem(String item) {
    if (remainingItems > 0) {
      setState(() {
        currentItems[currentSenseIndex] = item;
        remainingItems--;
        if (remainingItems == 4) currentSenseIndex = 1;
        if (remainingItems == 2) currentSenseIndex = 2;
        if (remainingItems == 1) currentSenseIndex = 3;
        if (remainingItems == 0) currentSenseIndex = 4;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CalmNowPage.offWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: CalmNowPage.darkGreen),
        title: const Text(
          '5-4-3-2-1 Grounding',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: CalmNowPage.darkGreen,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Notice ${remainingItems == 4 ? 4 : 5 - remainingItems} things you ${senses[currentSenseIndex].toLowerCase()}:",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CalmNowPage.darkGreen,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText:
                    'Enter an item you ${senses[currentSenseIndex].toLowerCase()}',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: CalmNowPage.soothingBlue.withOpacity(0.5),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _nextItem(value);
                }
              },
            ),
            const SizedBox(height: 24),
            ...List.generate(5, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  "${senses[index]}: ${currentItems[index]}",
                  style: TextStyle(
                    fontSize: 16,
                    color: currentItems[index].isNotEmpty
                        ? CalmNowPage.darkGreen
                        : CalmNowPage.darkGreen.withOpacity(0.5),
                    fontWeight: currentItems[index].isNotEmpty
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              );
            }),
            const Spacer(),
            if (remainingItems == 0)
              Text(
                'You have completed the exercise!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CalmNowPage.primaryGreen,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class STOPPage extends StatelessWidget {
  const STOPPage({super.key});

  final List<String> stopSteps = const [
    "S: Stop what you're doing. Freeze.",
    "T: Take a step back. Don't act on impulse.",
    "O: Observe your thoughts, feelings, and body.",
    "P: Proceed mindfully. Choose your next action.",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CalmNowPage.offWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: CalmNowPage.darkGreen),
        title: const Text(
          'STOP Skill',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: CalmNowPage.darkGreen,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'The STOP Skill',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: CalmNowPage.darkGreen,
                ),
              ),
              const SizedBox(height: 16),
              ...stopSteps.map((step) {
                return Card(
                  color: CalmNowPage.lightBlueGreen,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      step,
                      style: const TextStyle(
                        fontSize: 18,
                        color: CalmNowPage.darkGreen,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

class SoothingSoundsPage extends StatelessWidget {
  const SoothingSoundsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CalmNowPage.offWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: CalmNowPage.darkGreen),
        title: const Text(
          'Soothing Sounds',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: CalmNowPage.darkGreen,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.waves_rounded,
                size: 80,
                color: CalmNowPage.soothingBlue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Relax with the sounds of nature.',
                style: TextStyle(fontSize: 20, color: CalmNowPage.darkGreen),
              ),
              const SizedBox(height: 16),
              const Text(
                'Imagine here you would have play buttons for sound clips like rain, waves, and birds.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: CalmNowPage.darkGreen),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MiniGamesPage extends StatelessWidget {
  const MiniGamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CalmNowPage.offWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: CalmNowPage.darkGreen),
        title: const Text(
          'Mini-games',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: CalmNowPage.darkGreen,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.videogame_asset_rounded,
                size: 80,
                color: CalmNowPage.primaryGreen,
              ),
              const SizedBox(height: 24),
              const Text(
                'Time for a quick mental break!',
                style: TextStyle(fontSize: 20, color: CalmNowPage.darkGreen),
              ),
              const SizedBox(height: 16),
              const Text(
                'Imagine here you would have simple games like "Bubble Pop" or "Focus Dot Tracing".',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: CalmNowPage.darkGreen),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DoodlePadPage extends StatelessWidget {
  const DoodlePadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CalmNowPage.offWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: CalmNowPage.darkGreen),
        title: const Text(
          'Quick Doodle Pad',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: CalmNowPage.darkGreen,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.brush_rounded,
                size: 80,
                color: CalmNowPage.lightGreen,
              ),
              const SizedBox(height: 24),
              const Text(
                'Draw to clear your mind.',
                style: TextStyle(fontSize: 20, color: CalmNowPage.darkGreen),
              ),
              const SizedBox(height: 16),
              const Text(
                'Imagine here you would have a simple drawing canvas where you can draw and clear your mind.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: CalmNowPage.darkGreen),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LightQuizzesPage extends StatelessWidget {
  const LightQuizzesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CalmNowPage.offWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: CalmNowPage.darkGreen),
        title: const Text(
          'Light Quizzes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: CalmNowPage.darkGreen,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.quiz_rounded,
                size: 80,
                color: CalmNowPage.primaryGreen,
              ),
              const SizedBox(height: 24),
              const Text(
                'Test your knowledge with some fun facts.',
                style: TextStyle(fontSize: 20, color: CalmNowPage.darkGreen),
              ),
              const SizedBox(height: 16),
              const Text(
                'Imagine here you would have simple questions with multiple-choice answers.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: CalmNowPage.darkGreen),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DefusionPage extends StatelessWidget {
  const DefusionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CalmNowPage.offWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: CalmNowPage.darkGreen),
        title: const Text(
          'ACT Defusion Prompt',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: CalmNowPage.darkGreen,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.psychology_rounded,
                size: 80,
                color: CalmNowPage.soothingBlue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Say: "I\'m having the thought that..."',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: CalmNowPage.darkGreen,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'This exercise helps you separate from your thoughts and create space.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: CalmNowPage.darkGreen),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ValuesCheckInPage extends StatelessWidget {
  const ValuesCheckInPage({super.key});

  final List<String> values = const [
    "Family",
    "Career",
    "Friendship",
    "Health",
    "Creativity",
    "Adventure",
  ];

  @override
  Widget build(BuildContext context) {
    final randomValue = (values.toList()..shuffle()).first;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: CalmNowPage.offWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: CalmNowPage.darkGreen),
        title: const Text(
          'Values Check-In',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: CalmNowPage.darkGreen,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_rounded,
                size: 80,
                color: CalmNowPage.lightBlueGreen,
              ),
              const SizedBox(height: 24),
              const Text(
                'Check in with a core value:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: CalmNowPage.darkGreen),
              ),
              const SizedBox(height: 16),
              Text(
                randomValue,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: CalmNowPage.darkGreen,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'What is one small step you can take now to live this value?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: CalmNowPage.darkGreen),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MoodNotePage extends StatefulWidget {
  const MoodNotePage({super.key});

  @override
  State<MoodNotePage> createState() => _MoodNotePageState();
}

class _MoodNotePageState extends State<MoodNotePage> {
  final TextEditingController _botheringController = TextEditingController();
  final TextEditingController _controlController = TextEditingController();

  @override
  void dispose() {
    _botheringController.dispose();
    _controlController.dispose();
    super.dispose();
  }

  void _saveNote() {
    // Here you would save the note to a database
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note saved!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CalmNowPage.offWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: CalmNowPage.darkGreen),
        title: const Text(
          'Mood Note',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: CalmNowPage.darkGreen,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Write one thing that\'s bothering you and one small thing in your control.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: CalmNowPage.darkGreen),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _botheringController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Something that\'s bothering me...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controlController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'One thing in my control...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveNote,
              style: ElevatedButton.styleFrom(
                backgroundColor: CalmNowPage.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'Save Note',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityPage extends StatelessWidget {
  final String activityName;

  const ActivityPage({super.key, required this.activityName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          activityName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: CalmNowPage.darkGreen,
          ),
        ),
        backgroundColor: CalmNowPage.offWhite,
        iconTheme: const IconThemeData(color: CalmNowPage.darkGreen),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: CalmNowPage.primaryGreen,
                size: 80,
              ),
              const SizedBox(height: 24),
              Text(
                'Placeholder for "$activityName"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: CalmNowPage.darkGreen,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'This screen would contain the interactive exercise for $activityName. The navigation is now functional!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: CalmNowPage.darkGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
