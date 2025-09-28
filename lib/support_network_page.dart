import 'package:flutter/material.dart';
import 'mood_trends_page.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportNetworkPage extends StatefulWidget {
  const SupportNetworkPage({super.key});

  @override
  State<SupportNetworkPage> createState() => _SupportNetworkPageState();
}

class _SupportNetworkPageState extends State<SupportNetworkPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _selectedMoodIndex;
  bool _showNoteField = false; // 👈 for toggling note field
  final TextEditingController _noteController = TextEditingController();

  final List<Map<String, String>> _peerGroups = [
    {
      'name': 'Mindful Moments',
      'topics': 'Anxiety, Stress',
      'members': '12',
      'next_meeting': 'Tomorrow, 6 PM',
      'link': 'https://meet.google.com/abc-defg-hij',
    },
    {
      'name': 'Support Circle',
      'topics': 'Depression, Isolation',
      'members': '8',
      'next_meeting': 'Wednesday, 7 PM',
      'link': 'https://meet.google.com/klm-nopq-rst',
    },
    {
      'name': 'Study Buddies',
      'topics': 'Academic Pressure, Time Management',
      'members': '15',
      'next_meeting': 'Thursday, 5 PM',
      'link': 'https://meet.google.com/uvw-xyza-bcd',
    },
    {
      'name': 'Connect & Thrive',
      'topics': 'Relationships, Social Anxiety',
      'members': '10',
      'next_meeting': 'Friday, 8 PM',
      'link': 'https://meet.google.com/efg-hijk-lmn',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5E6),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          // Mood logging card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How are you feeling today?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMoodIndex = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: _selectedMoodIndex == index
                              ? Colors.green.withOpacity(0.25)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          ['😩', '😥', '😐', '😊', '😁'][index],
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),

                // Add Note Toggle
                if (!_showNoteField)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showNoteField = true;
                      });
                    },
                    icon: const Icon(Icons.note_add, color: Colors.green),
                    label: const Text(
                      'Add a note',
                      style: TextStyle(color: Colors.green),
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _noteController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Write your note...',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Save note to backend if needed
                            setState(() {
                              _showNoteField = false;
                              _noteController.clear();
                            });
                          },
                          child: const Text('Done'),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 12),

                // Moved button down & renamed
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const MoodTrendsPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.trending_up, color: Colors.white),
                    label: const Text(
                      'Your Mood in the Past Few Days',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab bar
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.green,
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Peer Groups'),
              Tab(text: 'Crisis Help'),
            ],
          ),

          // Content for tabs
          // Replace inside TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPeerGroupsTab(),
                _buildCrisisHelpTab(), // New function for crisis help
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeerGroupsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.filter_list, color: Colors.black54),
                label: const Text(
                  'Filter',
                  style: TextStyle(color: Colors.black54),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.group_add, color: Colors.white),
                label: const Text(
                  'Create Group',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._peerGroups.map((group) {
            return _buildGroupCard(
              group['name']!,
              group['topics']!,
              int.parse(group['members']!),
              group['next_meeting']!,
              group['link']!,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildGroupCard(
    String title,
    String topics,
    int members,
    String nextMeeting,
    String meetLink,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(topics, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              '$members members • Next meeting: $nextMeeting',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () async {
            final uri = Uri.parse(meetLink);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Could not open the Google Meet link'),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: const Text('Join', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

Widget _buildCrisisHelpTab() {
  final List<Map<String, String>> crisisHelplines = [
    {
      'title': 'Vandrevala Foundation Helpline',
      'desc': 'Mental health support across India',
      'number': '1860 2662 345',
    },
    {
      'title': 'AASRA Helpline',
      'desc': '24/7 Suicide prevention & mental health support',
      'number': '+91-9820466726',
    },
    {
      'title': 'Snehi',
      'desc': 'Counseling & crisis intervention (Delhi)',
      'number': '+91-9582208181',
    },
    {
      'title': 'iCall (TISS)',
      'desc': 'National mental health counseling service',
      'number': '+91-9152987821',
    },
    {
      'title': 'Childline 1098',
      'desc': '24/7 helpline for children in distress',
      'number': '1098',
    },
  ];

  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: crisisHelplines.length,
    itemBuilder: (context, index) {
      final helpline = crisisHelplines[index];
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 2,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          title: Text(
            helpline['title']!,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              helpline['desc']!,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          trailing: ElevatedButton.icon(
            onPressed: () async {
              final Uri phoneUri = Uri(scheme: 'tel', path: helpline['number']);
              if (await canLaunchUrl(phoneUri)) {
                await launchUrl(phoneUri);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not launch dialer')),
                );
              }
            },
            icon: const Icon(Icons.phone, color: Colors.white, size: 18),
            label: const Text('Call', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      );
    },
  );
}
