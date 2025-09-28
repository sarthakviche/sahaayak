import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart'; // To use the supabase client
import 'auth_page.dart'; // To navigate back to the auth page
import 'voice_journal_page.dart'; // Import the voice journal page
import 'calm.dart'; // Import the Calm Now page

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedMood = '';
  final int _streakCount = 7; // Example streak count
  final List<Color> _moodColors = [
    const Color.fromARGB(255, 255, 52, 37),
    Colors.orange,
    Colors.yellow,
    Colors.lightGreen,
    Colors.green,
  ];
  final List<String> _moodEmojis = ['😠', '😞', '😐', '😊', '😁'];

  // Sign out the current user
  Future<void> _signOut(BuildContext context) async {
    await supabase.auth.signOut();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 255, 213),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sahaayak",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // App intro section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: const [
                  Icon(Icons.psychology, size: 50, color: Colors.lightBlue),
                  SizedBox(height: 10),
                  Text(
                    "Your Mental Wellness Companion",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Sahaayak helps you reflect, calm down, and track your mental health journey. "
                    "Stay mindful, build habits, and take small steps every day.",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              'How are you feeling today?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Mood selector inside card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  _moodEmojis.length,
                  (index) => GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMood = _moodEmojis[index];
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _moodColors[index].withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: _selectedMood == _moodEmojis[index]
                            ? Border.all(color: _moodColors[index], width: 3)
                            : null,
                      ),
                      child: Text(
                        _moodEmojis[index],
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            // Streak counter display
            if (_streakCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                      size: 22,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$_streakCount-day streak!',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 35),

            // Action buttons row
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    title: 'Calm Now',
                    icon: Icons.self_improvement,
                    color: Colors.lightBlue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CalmNowPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildActionButton(
                    title: 'Reflect',
                    icon: Icons.mic,
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VoiceJournalPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Decorative helmets/icons
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 20,
              children: const [
                Icon(
                  Icons.sports_martial_arts,
                  size: 40,
                  color: Colors.black54,
                ),
                Icon(Icons.sports_kabaddi, size: 40, color: Colors.black54),
                Icon(Icons.health_and_safety, size: 40, color: Colors.black54),
                Icon(Icons.spa, size: 40, color: Colors.black54),
              ],
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Colors.red,
        icon: const Icon(Icons.crisis_alert, color: Colors.white),
        label: const Text(
          'Crisis',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Helper widget to build action buttons
  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
