import 'package:flutter/material.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mental Health App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4C8770)),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const CounselorsScreen(),
    );
  }
}

class CounselorsScreen extends StatefulWidget {
  const CounselorsScreen({super.key});

  @override
  State<CounselorsScreen> createState() => _CounselorsScreenState();
}

class _CounselorsScreenState extends State<CounselorsScreen> {
  static final List<Map<String, dynamic>> counselors = [
    {
      'name': 'Dr. Priya Sharma',
      'specialization': 'Student Counseling & Anxiety',
      'rating': 4.8,
      'years_of_experience': 8,
      'languages': ['Hindi', 'English'],
      'city': 'Delhi',
      'cost_per_session': 800,
    },
    {
      'name': 'Rahul Mehta',
      'specialization': 'CBT & Depression',
      'rating': 4.6,
      'years_of_experience': 5,
      'languages': ['English', 'Marathi'],
      'city': 'Mumbai',
      'cost_per_session': 600,
    },
    {
      'name': 'Dr. Anjali Gupta',
      'specialization': 'College Mental Health',
      'rating': 4.9,
      'years_of_experience': 12,
      'languages': ['Hindi', 'English', 'Punjabi'],
      'city': 'Delhi',
      'cost_per_session': 1000,
    },
  ];

  // Function to generate a random GMeet-style link
  String _generateRandomGmeetLink() {
    const String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final Random random = Random();
    String part1 = String.fromCharCodes(
      Iterable.generate(
        3,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
    String part2 = String.fromCharCodes(
      Iterable.generate(
        4,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
    String part3 = String.fromCharCodes(
      Iterable.generate(
        3,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
    return 'https://meet.google.com/$part1-$part2-$part3';
  }

  void _showBookingConfirmation(BuildContext context, String title) {
    final String gmeetLink = _generateRandomGmeetLink();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$title Confirmed!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your session has been booked.'),
              const SizedBox(height: 16),
              const Text(
                'Meeting Link:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              SelectableText(
                gmeetLink,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8EF),
        elevation: 0,
        title: Column(
          children: const [
            Text(
              'Professional Counselors',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22, // made bigger
                color: Colors.black87,
              ),
            ),
            Text(
              'व्यावसायिक सलाहकार',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Optional Banner / Engaging element
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 12),
            child: const Icon(
              Icons.self_improvement,
              size: 60,
              color: Color(0xFF4C8770),
            ),
          ),

          // Crisis Card (top)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(Icons.favorite, color: Colors.red),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'In Crisis? Get Immediate Help',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'संकट में हैं? तुरंत सहायता लें',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    launchUrl(Uri(scheme: 'tel', path: '18005990019'));
                  },
                  icon: const Icon(Icons.phone),
                  label: const Text('Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Counselor List Header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filter',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Choose your preferences',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                Icon(Icons.filter_list, color: Color(0xFF4C8770)),
              ],
            ),
          ),

          // The List of Counselor Cards
          Expanded(
            child: ListView.builder(
              itemCount: counselors.length,
              itemBuilder: (context, index) {
                final counselor = counselors[index];
                return CounselorCard(
                  counselorData: counselor,
                  onBookSession: () =>
                      _showBookingConfirmation(context, counselor['name']),
                );
              },
            ),
          ),
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
    final List<dynamic> languagesList = counselorData['languages'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFd1e7c5),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: Color(0xFF4C8770),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      counselorData['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            counselorData['specialization'],
                            style: const TextStyle(color: Color(0xFF4C8770)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.verified,
                          color: Color(0xFF4C8770),
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber[600], size: 18),
              const SizedBox(width: 4),
              Text(
                '${counselorData['rating']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${counselorData['years_of_experience']} years experience',
                  style: const TextStyle(color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.place_outlined, size: 16, color: Colors.grey[700]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Online & ${counselorData['city']}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.access_time, size: 16, color: Colors.grey[700]),
              const SizedBox(width: 4),
              const Text(
                'Today 3:00 PM',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: languagesList.map<Widget>((lang) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(lang, style: const TextStyle(fontSize: 12)),
                  );
                }).toList(),
              ),
              ElevatedButton.icon(
                onPressed: onBookSession,
                icon: const Icon(Icons.calendar_month, size: 18),
                label: const Text('Book Session'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C8770),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
