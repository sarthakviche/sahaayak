import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';
import 'auth_page.dart';
import 'voice_journal_page.dart';
import 'calm.dart';
import 'voice_chat_page.dart';
import 'support_network_page.dart';
import 'wearables.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // ✅ --- NEW STATE VARIABLES FOR MOOD LOGGING ---
  int? _selectedMoodIndex; // Use nullable int for no selection
  final int _streakCount = 7; // Example streak count

  final List<Color> _moodColors = [
    const Color.fromARGB(255, 255, 52, 37), // 0: Angry/Worst
    Colors.orange, // 1: Sad
    Colors.yellow, // 2: Neutral
    Colors.lightGreen, // 3: Happy/Good
    Colors.green, // 4: Joy/Best
  ];
  final List<String> _moodEmojis = ['😠', '😞', '😐', '😊', '😁'];


  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ✅ --- NEW SUPABASE MOOD LOGGING FUNCTION ---
  Future<void> _logMood(int moodLevel) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null || !mounted) return;

    try {
      await supabase.from('daily_mood_logs').insert({
        'user_id': userId,
        'mood_level': moodLevel, // Logging the index (0 to 4)
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mood logged successfully! Keep tracking.'),
          backgroundColor: Colors.green,
        ),
      );
    } on PostgrestException catch (e) {
      debugPrint('Supabase Mood Log Error: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log mood: ${e.message}')),
      );
    } catch (e) {
      debugPrint('General Mood Log Error: $e');
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await supabase.auth.signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthPage()),
          (route) => false);
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
            Colors.purple.shade100,
            Colors.lightGreen.shade50,
            Colors.white,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
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
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildQuoteCard(),
                  const SizedBox(height: 32),
                  _buildMoodSelector(),
                  const SizedBox(height: 48),
                  Text(
                    'Need to talk?',
                    style: GoogleFonts.quicksand(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildPulsingMicButton(),
                  const SizedBox(height: 48),
                  _buildActionCards(),
                  const SizedBox(height: 20),
                  _buildWearablesButton(),
                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: _buildCrisisButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
          Icon(Icons.spa_outlined, color: Colors.teal.shade300, size: 24),
          const SizedBox(width: 8),
          Text(
            "Sahaayak",
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 22,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout_outlined, color: Colors.black54),
          onPressed: () => _signOut(context),
        ),
      ],
    );
  }

  Widget _buildQuoteCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '"The first step towards getting somewhere is to decide you\'re not going to stay where you are."',
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 16,
              color: Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          Chip(
            avatar: Icon(Icons.local_fire_department,
                color: Colors.orange.shade700),
            label: Text(
              '$_streakCount-day streak!',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.orange.shade800),
            ),
            backgroundColor: Colors.orange.withOpacity(0.15),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          )
        ],
      ),
    );
  }

  // ✅ --- MOOD SELECTOR UPDATED TO LOG MOODS ---
  Widget _buildMoodSelector() {
    return Column(
      children: [
        Text(
          'How are you feeling today?',
          style: GoogleFonts.quicksand(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_moodEmojis.length, (index) {
            bool isSelected = _selectedMoodIndex == index;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedMoodIndex = index);
                _logMood(index); // Log the mood to Supabase
              },
              child: AnimatedScale(
                scale: isSelected ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _moodColors[index].withOpacity(isSelected ? 0.3 : 0.1),
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: _moodColors[index], width: 2.5)
                        : null,
                  ),
                  child: Text(
                    _moodEmojis[index],
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPulsingMicButton() {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (context) => const VoiceChatPage())),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: 90,
                height: 90,
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
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.purple.shade300, Colors.deepPurple.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child:
                const Icon(Icons.record_voice_over, color: Colors.white, size: 45),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCards() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            title: 'Calm Now',
            icon: Icons.self_improvement,
            color: Colors.lightBlue,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const CalmNowPage())),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildActionCard(
            title: 'Reflect',
            icon: Icons.mic,
            color: Colors.purple,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const VoiceJournalPage())),
          ),
        ),
      ],
    );
  }
  
  Widget _buildWearablesButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WearablesPage()),
          );
        },
        icon: Icon(Icons.watch_outlined, color: Colors.teal.shade700),
        label: Text(
          'Connect Wearables',
          style: GoogleFonts.quicksand(
            color: Colors.teal.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: Colors.teal.withOpacity(0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.teal.withOpacity(0.05),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrisisButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SupportNetworkPage(initialTabIndex: 2),
          ),
        );
      },
      backgroundColor: Colors.red.shade400,
      icon: const Icon(Icons.crisis_alert, color: Colors.white),
      label: Text(
        'Crisis',
        style:
            GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}