import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PreviousJournalsPage extends StatefulWidget {
  const PreviousJournalsPage({super.key});

  @override
  State<PreviousJournalsPage> createState() => _PreviousJournalsPageState();
}

class _PreviousJournalsPageState extends State<PreviousJournalsPage> {
  static const Duration _istOffset = Duration(hours: 5, minutes: 30);

  Future<List<Map<String, dynamic>>> _fetchJournals() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabase
        .from('journals')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return response;
  }

  DateTime _toIst(DateTime dt) {
    return dt.toUtc().add(_istOffset);
  }

  DateTime _parseIsoToIst(String? iso) {
    if (iso == null) return _toIst(DateTime.now());
    try {
      return _toIst(DateTime.parse(iso));
    } catch (_) {
      return _toIst(DateTime.now());
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
          title: Text(
            'Journal History',
            style: GoogleFonts.quicksand(
                color: Colors.black87, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchJournals(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  snapshot.hasError ? 'Error: ${snapshot.error}' : 'You have no journal entries yet.',
                  style: GoogleFonts.lato(color: Colors.black54),
                ),
              );
            }
            final journals = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeatmap(journals),
                  const SizedBox(height: 32),
                  Text(
                    'Past Entries',
                    style: GoogleFonts.quicksand(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: journals.length,
                    itemBuilder: (context, index) {
                      return _buildJournalCard(journals[index]);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeatmap(List<Map<String, dynamic>> journals) {
    final istNow = _toIst(DateTime.now());
    final istNowDate = DateTime(istNow.year, istNow.month, istNow.day);
    final earliestDate = istNowDate.subtract(const Duration(days: 29));
    final journalDates = journals
        .map((j) => _parseIsoToIst(j['created_at']))
        .map((d) => DateTime(d.year, d.month, d.day))
        .where((d) => !d.isBefore(earliestDate) && !d.isAfter(istNowDate))
        .toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last 30 Days',
          style: GoogleFonts.quicksand(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
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
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 10,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount: 30,
                itemBuilder: (context, index) {
                  final day = istNowDate.subtract(Duration(days: index));
                  final hasEntry = journalDates.contains(day);
                  return Container(
                    decoration: BoxDecoration(
                      color: hasEntry
                          ? Colors.deepPurple.shade200
                          : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Text(
                '${journalDates.length} entries in the last 30 days',
                style: GoogleFonts.lato(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJournalCard(Map<String, dynamic> journal) {
    final createdAtIst = _parseIsoToIst(journal['created_at']);
    // ✅ --- FETCH AND PREPARE TAGS --- ✅
    final List<dynamic> tags = journal['analysis_tags'] ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shadowColor: Colors.purple.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              title: Text(
                journal['title'] ?? 'Journal Entry',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      journal['summary'] ?? 'No summary.',
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.w600, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    // ✅ --- DISPLAY TAGS IN DIALOG --- ✅
                    if (tags.isNotEmpty) ...[
                      Text('Key Themes:', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6.0,
                        runSpacing: 4.0,
                        children: tags.map((tag) => Chip(
                          label: Text(tag.toString()),
                          backgroundColor: Colors.purple.shade50,
                          labelStyle: TextStyle(color: Colors.purple.shade800),
                        )).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      journal['transcript'] ?? 'No transcript.',
                      style: GoogleFonts.lato(color: Colors.black54, height: 1.5),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.purple.shade50,
                    child: Icon(Icons.mic_none, color: Colors.purple.shade400),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMMM dd, yyyy').format(createdAtIst), // e.g., October 11, 2025
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('hh:mm a').format(createdAtIst), // e.g., 12:08 PM
                        style: GoogleFonts.lato(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                journal['title'] ?? 'No Title',
                style: GoogleFonts.lato(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87),
              ),
              // ✅ --- DISPLAY TAGS IN CARD --- ✅
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6.0,
                  runSpacing: 4.0,
                  children: tags.map((tag) => Chip(
                    label: Text(tag.toString(), style: const TextStyle(fontSize: 12)),
                    backgroundColor: Colors.purple.shade50,
                    labelStyle: TextStyle(color: Colors.purple.shade800),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}