import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

const List<Map<String, dynamic>> counselors = [
  {
    'name': 'Dr. Priya Sharma',
    'specialization': 'Student Counseling & Anxiety',
    'rating': 4.8,
    'years_of_experience': 8,
    'languages': ['Hindi', 'English'],
    'city': 'Delhi',
  },
  {
    'name': 'Rahul Mehta',
    'specialization': 'CBT & Depression',
    'rating': 4.6,
    'years_of_experience': 5,
    'languages': ['English', 'Marathi'],
    'city': 'Mumbai',
  },
  {
    'name': 'Dr. Anjali Gupta',
    'specialization': 'College Mental Health',
    'rating': 4.9,
    'years_of_experience': 12,
    'languages': ['Hindi', 'English', 'Punjabi'],
    'city': 'Delhi',
  },
];

const List<Map<String, dynamic>> peerGroups = [
  {
    'name': 'Exam Stress Support Circle',
    'description':
        'Share exam strategies and support each other through academic pressure',
    'category': 'Study Support',
    'members': 24,
    'is_live': true,
    'time': 'Daily 8:00 PM',
    'moderator': 'Sneha (3rd Year Psychology)',
  },
  {
    'name': 'Homesickness & Adjustment',
    'description': 'For students missing home and adjusting to college life',
    'category': 'Emotional Support',
    'members': 18,
    'is_live': false,
    'time': 'Mon/Wed/Fri 7:00 PM',
    'moderator': 'Arjun (4th Year, Peer Mentor)',
  },
];

const List<Map<String, dynamic>> crisisHelplines = [
  {
    'name': 'KIRAN National Helpline',
    'description': '24/7 mental health support',
    'number': '1800-599-0019',
    'type': 'National',
  },
  {
    'name': 'Vandrevala Foundation',
    'description': '24/7 mental health helpline',
    'number': '9999666555',
    'type': 'National',
    'languages': ['Hindi', 'English', 'Multiple'],
  },
];

class SupportNetworkPage extends StatefulWidget {
  final int initialTabIndex;

  const SupportNetworkPage({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<SupportNetworkPage> createState() => _SupportNetworkPageState();
}

class _SupportNetworkPageState extends State<SupportNetworkPage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
  }

  String _generateRandomGmeetLink() {
    const String chars = 'abcdefghijklmnopqrstuvwxyz';
    final Random random = Random();
    String part1 = String.fromCharCodes(Iterable.generate(
        3, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
    String part2 = String.fromCharCodes(Iterable.generate(
        4, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
    String part3 = String.fromCharCodes(Iterable.generate(
        3, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
    return 'https://meet.google.com/$part1-$part2-$part3';
  }

  void _showBookingConfirmation(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Session Confirmed!',
              style: GoogleFonts.quicksand(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your session with $title has been booked.',
                  style: GoogleFonts.lato()),
              const SizedBox(height: 16),
              const Text('Meeting Link:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SelectableText(_generateRandomGmeetLink(),
                  style: const TextStyle(color: Colors.blue)),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget pageContent;
    if (_selectedIndex == 0) {
      pageContent = _buildCounselorsList();
    } else if (_selectedIndex == 1) {
      pageContent = _buildPeerGroupsList();
    } else {
      pageContent = _buildCrisisHelpContent();
    }

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
          centerTitle: true,
          title: Text(
            'Support Network',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        body: Column(
          children: [
            _buildCustomSegmentedControl(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: pageContent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomSegmentedControl() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          _buildSegment('Counselors', 0),
          _buildSegment('Peer Groups', 1),
          _buildSegment('Crisis Help', 2),
        ],
      ),
    );
  }

  Widget _buildSegment(String title, int index) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.deepPurple.shade600 : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCounselorsList() {
    return ListView.builder(
      key: const ValueKey('counselorsList'),
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: counselors.length,
      itemBuilder: (context, index) {
        final counselor = counselors[index];
        return CounselorCard(
          counselorData: counselor,
          onBookSession: () =>
              _showBookingConfirmation(context, counselor['name']),
        );
      },
    );
  }

  Widget _buildPeerGroupsList() {
    return ListView.builder(
      key: const ValueKey('peerGroupsList'),
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: peerGroups.length,
      itemBuilder: (context, index) {
        final group = peerGroups[index];
        return PeerGroupCard(
          groupData: group,
          onJoinLive: () => _showBookingConfirmation(context, group['name']),
        );
      },
    );
  }

  Widget _buildCrisisHelpContent() {
    return SingleChildScrollView(
      key: const ValueKey('crisisHelpContent'),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.shade100),
            ),
            child: Column(
              children: [
                Icon(Icons.favorite_border,
                    color: Colors.red.shade700, size: 32),
                const SizedBox(height: 12),
                Text(
                  'You Are Not Alone',
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.red.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'If you are in distress, please reach out. Help is available, and there are people who care.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(color: Colors.black54, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...crisisHelplines
              .map((helpline) => CrisisHelplineCard(helplineData: helpline))
              .toList(),
        ],
      ),
    );
  }
}

class CounselorCard extends StatelessWidget {
  final Map<String, dynamic> counselorData;
  final VoidCallback onBookSession;

  const CounselorCard({
    super.key,
    required this.counselorData,
    required this.onBookSession,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shadowColor: Colors.purple.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.purple.shade50,
                  child: Icon(Icons.person_outline,
                      size: 30, color: Colors.purple.shade400),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        counselorData['name'],
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        counselorData['specialization'],
                        style: GoogleFonts.lato(
                            color: Colors.black54, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Chip(
                  avatar: Icon(Icons.star,
                      color: Colors.amber.shade800, size: 16),
                  label: Text(
                    '${counselorData['rating']}',
                    style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.amber.shade100,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${counselorData['years_of_experience']} years experience',
                  style:
                      GoogleFonts.lato(color: Colors.grey.shade700, fontSize: 14),
                ),
                ElevatedButton(
                  onPressed: onBookSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: Text('Book',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PeerGroupCard extends StatelessWidget {
  final Map<String, dynamic> groupData;
  final VoidCallback onJoinLive;

  const PeerGroupCard({
    super.key,
    required this.groupData,
    required this.onJoinLive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shadowColor: Colors.purple.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.purple.shade50,
                  child: Icon(Icons.groups_outlined,
                      size: 30, color: Colors.purple.shade400),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    groupData['name'],
                    style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                if (groupData['is_live'])
                  Chip(
                    label: Text('Live',
                        style: GoogleFonts.lato(color: Colors.green.shade800)),
                    backgroundColor: Colors.green.shade100,
                    avatar:
                        const Icon(Icons.circle, color: Colors.green, size: 12),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              groupData['description'],
              style: GoogleFonts.lato(color: Colors.black54, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${groupData['members']} members',
                      style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      groupData['time'],
                      style: GoogleFonts.lato(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: onJoinLive,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: Text('Join',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CrisisHelplineCard extends StatelessWidget {
  final Map<String, dynamic> helplineData;

  const CrisisHelplineCard({super.key, required this.helplineData});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shadowColor: Colors.red.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red.shade50,
          child: Icon(Icons.phone_in_talk_outlined,
              color: Colors.red.shade400),
        ),
        title: Text(
          helplineData['name'],
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          helplineData['number'],
          style: GoogleFonts.lato(color: Colors.black54),
        ),
        trailing: IconButton(
          icon: Icon(Icons.call_outlined, color: Colors.red.shade400),
          onPressed: () {
            launchUrl(Uri(
                scheme: 'tel',
                path: helplineData['number'].replaceAll('-', '')));
          },
        ),
      ),
    );
  }
}