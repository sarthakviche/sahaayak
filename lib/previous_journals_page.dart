import 'package:flutter/material.dart';
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
    if (supabase.auth.currentUser == null) {
      return [];
    }
    final userId = supabase.auth.currentUser!.id;
    final response = await supabase
        .from('journals')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return response;
  }

  /// Convert any DateTime (parsed from Supabase) to IST.
  /// We first get the UTC moment with .toUtc(), then add the IST offset.
  DateTime _toIst(DateTime dt) {
    final utc = dt.toUtc();
    return utc.add(_istOffset);
  }

  /// Safely parse an ISO timestamp string to IST DateTime.
  /// If parsing fails, returns `DateTime.now()` converted to IST as a fallback.
  DateTime _parseIsoToIst(String? iso) {
    if (iso == null) {
      return _toIst(DateTime.now());
    }
    try {
      final parsed = DateTime.parse(iso);
      return _toIst(parsed);
    } catch (_) {
      // Fallback
      return _toIst(DateTime.now());
    }
  }

  /// Build the 30-day heatmap using IST-based days.
  Widget _buildHeatmap(List<Map<String, dynamic>> journals) {
    // IST "now" and date-only boundaries
    final istNow = _toIst(DateTime.now());
    final istNowDate = DateTime(istNow.year, istNow.month, istNow.day);

    // earliest included day = 29 days before today (so total 30 days including today)
    final earliestDate = istNowDate.subtract(const Duration(days: 29));

    // collect normalized journal dates (IST)
    final journalDates = journals
        .map((j) {
          final created = _parseIsoToIst(j['created_at'] as String?);
          return DateTime(created.year, created.month, created.day);
        })
        .where((d) {
          // include if within [earliestDate, istNowDate]
          return !d.isBefore(earliestDate) && !d.isAfter(istNowDate);
        })
        .toSet();

    final entryCount = journalDates.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Last 30 Days',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2C3E50),
            borderRadius: BorderRadius.circular(12),
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
                  // Build the grid from today (index 0) backwards in IST
                  final day = istNowDate.subtract(Duration(days: index));
                  final hasEntry = journalDates.contains(day);

                  return Container(
                    decoration: BoxDecoration(
                      color: hasEntry
                          ? const Color(0xFF82E0AA)
                          : Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Text(
                '$entryCount entries in the last 30 days',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2C38),
      appBar: AppBar(
        title: const Text(
          'Journal History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchJournals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          final journals = snapshot.data;
          if (journals == null || journals.isEmpty) {
            return const Center(
              child: Text(
                'You have no journal entries yet.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeatmap(journals),
                const SizedBox(height: 32),
                const Text(
                  'Past Entries',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: journals.length,
                  itemBuilder: (context, index) {
                    final journal = journals[index];
                    final createdAtIst = _parseIsoToIst(
                      journal['created_at'] as String?,
                    );

                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: const Color(0xFFE8EAF6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            title: Text(
                              journal['title'] ?? 'Journal Entry',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    journal['summary'] ??
                                        'No summary available.',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    journal['transcript'] ??
                                        'No transcript available.',
                                    style: const TextStyle(
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text(
                                  'Close',
                                  style: TextStyle(color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xAAE0F2E8).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white.withOpacity(0.15),
                              child: const Icon(
                                Icons.mic,
                                color: Color(0xFF82E0AA),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Indian date format: dd/MM/yyyy
                                Text(
                                  DateFormat('dd/MM/yyyy').format(createdAtIst),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // 12-hour time: HH:mm a
                                Text(
                                  DateFormat('hh:mm a').format(createdAtIst),
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
