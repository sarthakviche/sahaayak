import 'package:flutter/material.dart';

class MoodTrendsPage extends StatelessWidget {
  const MoodTrendsPage({super.key});

  // Example mood data (0-4, 0=bad, 4=good) for a few weeks
  final List<List<int?>> _moodData = const [
    [0, 1, 2, 1, 0, null, 1],
    [2, 3, 2, 2, 3, 4, 3],
    [4, 3, 4, 3, 4, 4, 4],
    [3, 3, 2, 1, 2, 3, 3],
    [1, 2, 2, 2, 3, 4, 4],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mood Trends'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Mood Over Time',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildMoodCalendar(),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodCalendar() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLegend(),
          const SizedBox(height: 10),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text('Less', style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(width: 5),
        ...List.generate(5, (index) => _buildColorBox(index)),
        const SizedBox(width: 5),
        const Text('More', style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildColorBox(int moodLevel) {
    Color color;
    switch (moodLevel) {
      case 0:
        color = const Color.fromARGB(255, 255, 52, 37);
        break;
      case 1:
        color = Colors.orange;
        break;
      case 2:
        color = Colors.yellow;
        break;
      case 3:
        color = Colors.lightGreen;
        break;
      case 4:
        color = Colors.green;
        break;
      default:
        color = Colors.grey[300]!;
    }
    return Container(
      width: 15,
      height: 15,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    const List<String> weekdays = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const SizedBox(width: 40), // Placeholder for weekday labels
            ...weekdays
                .map((day) => Text(day, style: const TextStyle(fontSize: 12)))
                .toList(),
          ],
        ),
        const SizedBox(height: 5),
        Column(
          children: List.generate(_moodData.length, (weekIndex) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    'Week ${weekIndex + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ..._moodData[weekIndex].map((moodLevel) {
                  return Container(
                    width: 30,
                    height: 30,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: _getColorForMood(moodLevel),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }).toList(),
              ],
            );
          }),
        ),
      ],
    );
  }

  Color _getColorForMood(int? moodLevel) {
    if (moodLevel == null) {
      return Colors.grey[300]!; // Color for no data
    }
    switch (moodLevel) {
      case 0:
        return const Color.fromARGB(255, 255, 52, 37);
      case 1:
        return Colors.orange;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.lightGreen;
      case 4:
        return Colors.green;
      default:
        return Colors.grey[300]!;
    }
  }
}
