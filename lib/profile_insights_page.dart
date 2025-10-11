import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'main.dart';

// Data Model for a single mood log entry
class MoodEntry {
  final DateTime date;
  final int moodLevel; // 0 (Worst) to 4 (Best)

  MoodEntry({required this.date, required this.moodLevel});
}

class ProfileInsightsPage extends StatefulWidget {
  const ProfileInsightsPage({super.key});

  @override
  State<ProfileInsightsPage> createState() => _ProfileInsightsPageState();
}

class _ProfileInsightsPageState extends State<ProfileInsightsPage> {
  late Future<Map<String, dynamic>> _profileDataFuture;

  // Centralized mood details for consistency
  final List<Map<String, dynamic>> _moodDetails = [
    {'emoji': '😠', 'label': 'Very Low', 'color': Colors.red.shade300},
    {'emoji': '😞', 'label': 'Low', 'color': Colors.orange.shade300},
    {'emoji': '😐', 'label': 'Neutral', 'color': Colors.amber.shade400},
    {'emoji': '😊', 'label': 'Good', 'color': Colors.lightGreen.shade400},
    {'emoji': '😁', 'label': 'Very Good', 'color': Colors.green.shade400},
  ];

  @override
  void initState() {
    super.initState();
    _profileDataFuture = _fetchProfileData();
  }

  Future<void> _reloadData() async {
    setState(() {
      _profileDataFuture = _fetchProfileData();
    });
  }

  Future<Map<String, dynamic>> _fetchProfileData() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in.');

    final user = supabase.auth.currentUser!;
    final userName = user.email?.split('@')[0] ?? 'User';
    final profileHandle = '@${userName.toLowerCase()}${user.id.substring(0, 4)}';

    try {
      final journalEntries = await supabase
          .from('journals')
          .select('analysis_tags, created_at')
          .eq('user_id', userId);

      final moodLogEntries = await supabase
          .from('daily_mood_logs')
          .select('mood_level, logged_at')
          .eq('user_id', userId)
          .order('logged_at', ascending: false);

      int? todaysAverageMood;
      final Map<DateTime, List<int>> dailyMoodsRaw = {};
      final todayDateOnly = DateUtils.dateOnly(DateTime.now().toLocal());

      for (var entry in moodLogEntries) {
        final date = DateTime.parse(entry['logged_at']).toLocal();
        final dateOnly = DateUtils.dateOnly(date);
        final moodLevel = entry['mood_level'] as int;

        dailyMoodsRaw.putIfAbsent(dateOnly, () => []).add(moodLevel);

        if (dateOnly.isAtSameMomentAs(todayDateOnly)) {
          // This logic is still needed to calculate the average
          dailyMoodsRaw[todayDateOnly]!.add(moodLevel);
        }
      }
      
      if (dailyMoodsRaw.containsKey(todayDateOnly)) {
        final todaysMoodsList = dailyMoodsRaw[todayDateOnly]!;
        final double average = todaysMoodsList.reduce((a, b) => a + b) / todaysMoodsList.length;
        todaysAverageMood = average.round();
      }

      final List<MoodEntry> averagedMoodEntries = dailyMoodsRaw.entries.map((entry) {
        final double average = entry.value.reduce((a, b) => a + b) / entry.value.length;
        return MoodEntry(date: entry.key, moodLevel: average.round());
      }).toList();
      averagedMoodEntries.sort((a, b) => a.date.compareTo(b.date));

      final Map<String, int> tagCounts = {};
      for (var entry in journalEntries) {
        final tags = (entry['analysis_tags'] as List?)?.cast<String>();
        if (tags != null) {
          for (var tag in tags) {
            tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
          }
        }
      }
      final sortedTags = tagCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final userTopTags = sortedTags.take(6).map((e) => e.key).toList();

      return {
        'entries_count': journalEntries.length,
        'streak': _calculateStreak(journalEntries),
        'top_tags': userTopTags,
        'mood_entries': averagedMoodEntries.reversed.take(7).toList().reversed.toList(),
        'user_name': userName,
        'profile_handle': profileHandle,
        'todays_mood_avg': todaysAverageMood,
        'recent_moods': moodLogEntries.take(5).toList(),
      };
    } catch (e) {
      debugPrint('Supabase Fetch Error: $e');
      throw Exception('Failed to load profile data.');
    }
  }

  int _calculateStreak(List<Map<String, dynamic>> journalEntries) {
    if (journalEntries.isEmpty) return 0;
    Set<DateTime> uniqueDays = journalEntries.map((e) => DateUtils.dateOnly(DateTime.parse(e['created_at']).toLocal())).toSet();
    List<DateTime> sortedDates = uniqueDays.toList()..sort();

    int streak = 0;
    DateTime today = DateUtils.dateOnly(DateTime.now().toLocal());
    DateTime currentCheckDate = uniqueDays.contains(today) ? today : today.subtract(const Duration(days: 1));
    
    for (int i = sortedDates.length - 1; i >= 0; i--) {
      if (sortedDates[i].isAtSameMomentAs(currentCheckDate)) {
        streak++;
        currentCheckDate = currentCheckDate.subtract(const Duration(days: 1));
      } else if (sortedDates[i].isBefore(currentCheckDate)) {
        break;
      }
    }
    return streak;
  }

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
          title: Text('Profile & Insights', style: GoogleFonts.quicksand(color: Colors.black87, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _profileDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: GoogleFonts.lato(color: Colors.red.shade700)));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No data found.', style: GoogleFonts.lato(color: Colors.black54)));
            }

            final data = snapshot.data!;
            if (data['entries_count'] == 0 && (data['mood_entries'] as List).isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text('No journal or mood entries yet. Start logging to see your insights!', textAlign: TextAlign.center, style: GoogleFonts.lato(color: Colors.black54, fontSize: 16)),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _reloadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _buildProfileHeader(data['user_name'], data['profile_handle']),
                    const SizedBox(height: 24),
                    _buildTodaysMoodCard(data['todays_mood_avg']),
                    const SizedBox(height: 24),
                    _buildGamificationBar(data['entries_count'], data['streak']),
                    const SizedBox(height: 24),
                    _buildMoodTrendCard(data['mood_entries']),
                    const SizedBox(height: 24),
                    _buildTagsSection(data['top_tags']),
                    const SizedBox(height: 24),
                    _buildRecentMoodsSection(data['recent_moods']),
                    const SizedBox(height: 24),
                    _buildRecommendedActions(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String userName, String profileHandle) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.deepPurple.withOpacity(0.1),
          child: Icon(Icons.person_outline, size: 40, color: Colors.deepPurple.shade300),
        ),
        const SizedBox(height: 12),
        Text(userName, style: GoogleFonts.quicksand(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(profileHandle, style: GoogleFonts.lato(fontSize: 16, color: Colors.grey.shade600)),
      ],
    );
  }
  
  Widget _buildTodaysMoodCard(int? averageMoodLevel) {
    return Card(
      elevation: 4,
      shadowColor: Colors.purple.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Today's Average Mood", style: GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 16),
            if (averageMoodLevel != null) ...[
              Text(
                _moodDetails[averageMoodLevel]['emoji'],
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 8),
              Text(
                _moodDetails[averageMoodLevel]['label'],
                style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.w600, color: _moodDetails[averageMoodLevel]['color']),
              ),
            ] else ...[
              Icon(Icons.edit_note_outlined, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 8),
              Text(
                "You haven't logged your mood today.",
                style: GoogleFonts.lato(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGamificationBar(int entriesCount, int currentStreak) {
    final double levelProgress = (entriesCount % 20) / 20.0;
    final int currentLevel = (entriesCount ~/ 20) + 1;

    return Card(
      elevation: 4,
      shadowColor: Colors.purple.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                _buildStatCard('Journal Streak', '$currentStreak Days', Icons.local_fire_department_outlined, Colors.orange),
                const SizedBox(width: 16),
                _buildStatCard('Total Entries', '$entriesCount', Icons.history_edu_outlined, Colors.deepPurple),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Level $currentLevel', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold)),
                Text('Next Level: ${20 - (entriesCount % 20)} entries', style: GoogleFonts.lato(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: levelProgress,
                backgroundColor: Colors.grey.shade200,
                color: Colors.deepPurple.shade300,
                minHeight: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12)
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: GoogleFonts.quicksand(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                Text(label, style: GoogleFonts.lato(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection(List<String> tags) {
    if(tags.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Top Emotional Tags', style: GoogleFonts.quicksand(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: tags.map((tag) => _buildTagChip(tag)).toList(),
        ),
      ],
    );
  }

  Widget _buildTagChip(String tag) {
    return Chip(
      label: Text(tag, style: GoogleFonts.lato(color: Colors.deepPurple.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
      backgroundColor: Colors.purple.shade50,
      avatar: Icon(Icons.psychology_alt_outlined, size: 16, color: Colors.deepPurple.shade300),
      side: BorderSide(color: Colors.purple.shade100),
    );
  }

  Widget _buildMoodTrendCard(List<MoodEntry> entries) {
    if(entries.isEmpty) return const SizedBox.shrink();
    return Card(
      elevation: 4,
      shadowColor: Colors.purple.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Mood Trend', style: GoogleFonts.quicksand(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 4,
                  minY: 0,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < entries.length) {
                            return Text(DateFormat('EEE').format(entries[index].date), style: GoogleFonts.lato(fontSize: 10, color: Colors.grey));
                          }
                          return const Text('');
                        },
                        reservedSize: 30,
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: entries.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.moodLevel.toDouble(),
                          color: _getMoodColor(entry.value.moodLevel),
                          width: 20,
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentMoodsSection(List<dynamic> recentMoods) {
    if (recentMoods.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Mood Logs', style: GoogleFonts.quicksand(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...recentMoods.map((mood) => _buildMoodEntryCard(mood)).toList(),
      ],
    );
  }

  Widget _buildMoodEntryCard(Map<String, dynamic> moodLog) {
    final createdAt = DateTime.parse(moodLog['logged_at']).toLocal();
    final moodLevel = moodLog['mood_level'] as int;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shadowColor: Colors.purple.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Text(
          _moodDetails[moodLevel]['emoji'],
          style: const TextStyle(fontSize: 28),
        ),
        title: Text(
          _moodDetails[moodLevel]['label'],
          style: GoogleFonts.quicksand(fontWeight: FontWeight.w600, color: _moodDetails[moodLevel]['color']),
        ),
        subtitle: Text(
          DateFormat.yMMMd().add_jm().format(createdAt),
          style: GoogleFonts.lato(color: Colors.grey.shade600, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildRecommendedActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recommended Actions', style: GoogleFonts.quicksand(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildActionItem('Continue daily journaling', 'You\'re building a great habit!', Icons.history_edu_outlined, Colors.deepPurple),
        _buildActionItem('Try a breathing exercise', 'Based on your tags, this might help.', Icons.air, Colors.teal),
      ],
    );
  }

  Widget _buildActionItem(String title, String subtitle, IconData icon, Color iconColor) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shadowColor: iconColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: GoogleFonts.quicksand(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: GoogleFonts.lato(color: Colors.grey.shade600)),
        onTap: () {},
      ),
    );
  }
  
  Color _getMoodColor(int moodLevel) {
    if (moodLevel >= 0 && moodLevel < _moodDetails.length) {
      return _moodDetails[moodLevel]['color'];
    }
    return Colors.grey.shade300;
  }
}