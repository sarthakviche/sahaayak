import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// --- DATA MODELS (Included here to make the file self-contained) ---

class HealthMetric {
  final DateTime metricDate;
  final double sleepHours;
  final int steps;
  final int restingHeartRate;
  final int? hrv;

  HealthMetric({
    required this.metricDate,
    required this.sleepHours,
    required this.steps,
    required this.restingHeartRate,
    this.hrv,
  });
}

class MoodCheckin {
  final DateTime checkinDate;
  final double moodRating; // e.g., 1-5
  final double stressLevel; // e.g., 1-5

  MoodCheckin({
    required this.checkinDate,
    required this.moodRating,
    required this.stressLevel,
  });
}

class DailyCombinedMetric {
  final HealthMetric health;
  final MoodCheckin? mood;

  DailyCombinedMetric({required this.health, this.mood});

  DateTime get date => health.metricDate;
  double get sleepHours => health.sleepHours;
  int get steps => health.steps;
  int get restingHeartRate => health.restingHeartRate;
  int? get hrv => health.hrv;
  double? get moodRating => mood?.moodRating;
  double? get stressLevel => mood?.stressLevel;
}


// --- THEMED COLOR PALETTE ---
final Color primaryPurple = Colors.deepPurple.shade200;
final Color primaryMint = Colors.teal.shade200;
final Color primaryTeal = Colors.teal.shade400;
final Color primaryPink = Colors.pink.shade200;
final Color primaryDark = const Color(0xFF333333);
final Color hrvBlue = Colors.lightBlue.shade300;

// --- 1. SERVICE LAYER (Mocking Data) ---
class HealthService {
  Future<List<HealthMetric>> fetchWeeklyHealthMetrics() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _generateMockHealthData();
  }

  Future<List<MoodCheckin>> fetchWeeklyMoods() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _generateMockMoodData();
  }

  List<HealthMetric> _generateMockHealthData() {
    final random = Random();
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: index));
      return HealthMetric(
        metricDate: date,
        sleepHours: 6.0 + random.nextDouble() * 3.5,
        steps: 4000 + random.nextInt(10000),
        restingHeartRate: 60 + random.nextInt(15),
        hrv: 40 + random.nextInt(35) - (index * 2),
      );
    }).reversed.toList();
  }

  List<MoodCheckin> _generateMockMoodData() {
    final random = Random();
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: index));
      if (index == 2) return null; // Simulate a missed day
      return MoodCheckin(
        checkinDate: date,
        moodRating: 2.5 + random.nextDouble() * 2.5,
        stressLevel: 2.0 + random.nextDouble() * 2.0,
      );
    }).whereType<MoodCheckin>().toList().reversed.toList();
  }
}

// --- 2. STATE MANAGEMENT (Health Provider) ---
class HealthProvider with ChangeNotifier {
  final HealthService _service = HealthService();
  List<DailyCombinedMetric> _combinedWeeklyData = [];
  bool _isLoading = false;

  List<DailyCombinedMetric> get combinedWeeklyData => _combinedWeeklyData;
  bool get isLoading => _isLoading;

  double get avgSleepHours => _calculateAverage((d) => d.sleepHours);
  int get avgSteps => _calculateAverage((d) => d.steps.toDouble()).toInt();
  int get avgRestingHeartRate => _calculateAverage((d) => d.restingHeartRate.toDouble()).toInt();
  int get avgHrv => _calculateAverage((d) => d.hrv?.toDouble() ?? 0.0, includeNulls: false).toInt();

  bool get isSleepAlert => avgSleepHours > 0 && avgSleepHours < 6.5;
  bool get isActivityAlert => avgSteps > 0 && avgSteps < 5000;

  bool get isHrvTrendAlert {
    if (_combinedWeeklyData.length < 7) return false;
    final firstHalfAvg = _calculateAverage((d) => d.hrv?.toDouble() ?? 0.0, start: 0, end: 3, includeNulls: false);
    final secondHalfAvg = _calculateAverage((d) => d.hrv?.toDouble() ?? 0.0, start: 3, end: 7, includeNulls: false);
    return secondHalfAvg > 0 && firstHalfAvg > 0 && secondHalfAvg < firstHalfAvg * 0.9;
  }

  String get correlationInsight {
    final relevantDays = _combinedWeeklyData.where((d) => d.mood != null).toList();
    if (relevantDays.length < 4) {
      return "Log your mood daily to unlock personalized insights about your well-being.";
    }
    final goodSleepDays = relevantDays.where((d) => d.sleepHours >= 7.5).toList();
    final poorSleepDays = relevantDays.where((d) => d.sleepHours < 6.5).toList();
    if (goodSleepDays.isNotEmpty && poorSleepDays.isNotEmpty) {
      final avgMoodGoodSleep = goodSleepDays.map((d) => d.moodRating!).reduce((a, b) => a + b) / goodSleepDays.length;
      final avgMoodPoorSleep = poorSleepDays.map((d) => d.moodRating!).reduce((a, b) => a + b) / poorSleepDays.length;
      if (avgMoodGoodSleep > avgMoodPoorSleep * 1.15) {
        final percentage = ((avgMoodGoodSleep / avgMoodPoorSleep) - 1) * 100;
        return "Insight ✨: On days you slept well, your reported mood was ${percentage.toStringAsFixed(0)}% higher on average.";
      }
    }
    return "Consistent sleep and activity are key pillars of mental well-being.";
  }

  double _calculateAverage(double Function(DailyCombinedMetric) getValue, {int? start, int? end, bool includeNulls = true}) {
    var data = _combinedWeeklyData;
    if (start != null && end != null) data = data.sublist(start, end);
    if (!includeNulls) data = data.where((d) => getValue(d) != 0.0).toList();
    if (data.isEmpty) return 0.0;
    return data.map(getValue).reduce((a, b) => a + b) / data.length;
  }

  HealthProvider() {
    fetchData();
  }

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final healthData = await _service.fetchWeeklyHealthMetrics();
      final moodData = await _service.fetchWeeklyMoods();
      _combinedWeeklyData = _combineHealthAndMood(healthData, moodData);
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<DailyCombinedMetric> _combineHealthAndMood(List<HealthMetric> health, List<MoodCheckin> moods) {
    final moodMap = {for (var m in moods) DateTime(m.checkinDate.year, m.checkinDate.month, m.checkinDate.day): m};
    return health.map((h) {
      final key = DateTime(h.metricDate.year, h.metricDate.month, h.metricDate.day);
      return DailyCombinedMetric(health: h, mood: moodMap[key]);
    }).toList();
  }
}

// --- 3. UI IMPLEMENTATION (Main Page Widget) ---
class WearablesPage extends StatelessWidget {
  const WearablesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HealthProvider(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade50, Colors.deepPurple.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text('Health Insights', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.black87)),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black87,
            elevation: 0,
          ),
          body: Consumer<HealthProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.combinedWeeklyData.isEmpty) {
                return Center(child: CircularProgressIndicator(color: primaryPurple));
              }

              if (provider.combinedWeeklyData.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.watch_outlined, size: 80, color: Colors.purple.shade200),
                        const SizedBox(height: 16),
                        Text('No health metrics found.', textAlign: TextAlign.center, style: GoogleFonts.lato(fontSize: 18, color: Colors.black54)),
                        const SizedBox(height: 8),
                        Text('Connect your wearable or simulate data to start tracking.', textAlign: TextAlign.center, style: GoogleFonts.lato(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('Simulate 7 Days of Data'),
                          onPressed: provider.isLoading ? null : () => provider.fetchData(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple.shade300,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                children: [
                  _ContextualAlert(provider: provider),
                  const SizedBox(height: 16),
                  const _InsightsCard(),
                  const SizedBox(height: 16),
                  _SummaryCards(provider: provider),
                  const SizedBox(height: 24),
                  const _ChartCard(title: 'Sleep & Mood Correlation', child: _SleepTimelineChart()),
                  const SizedBox(height: 16),
                  const _ChartCard(title: 'Heart Rate Variability (ms)', child: _HrvLineChart()),
                  const SizedBox(height: 16),
                  const _ChartCard(title: 'Daily Steps', child: _StepsBarChart()),
                  const SizedBox(height: 16),
                  const _ChartCard(title: 'Resting Heart Rate (BPM)', child: _HeartRateLineChart()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// --- Reusable UI Components ---

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white.withOpacity(0.85),
      shadowColor: Colors.purple.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.quicksand(fontSize: 18, fontWeight: FontWeight.w700, color: primaryDark)),
            const SizedBox(height: 24),
            SizedBox(height: 200, child: child),
          ],
        ),
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final HealthProvider provider;
  const _SummaryCards({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildMetricCard(context, 'Avg Sleep', '${provider.avgSleepHours.toStringAsFixed(1)} hrs', Icons.bedtime_outlined, primaryPurple),
        const SizedBox(width: 12),
        _buildMetricCard(context, 'Avg Steps', NumberFormat('#,###').format(provider.avgSteps), Icons.directions_run_outlined, primaryTeal),
        const SizedBox(width: 12),
        _buildMetricCard(context, 'Avg HRV', '${provider.avgHrv} ms', Icons.monitor_heart_outlined, hrvBlue),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        shadowColor: color.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(title, style: GoogleFonts.lato(fontSize: 12, color: Colors.grey.shade600)),
              Text(value, style: GoogleFonts.quicksand(fontSize: 18, fontWeight: FontWeight.bold, color: primaryDark)),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightsCard extends StatelessWidget {
  const _InsightsCard();
  @override
  Widget build(BuildContext context) {
    final insightText = Provider.of<HealthProvider>(context).correlationInsight;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: primaryPurple.withOpacity(0.15),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.lightbulb_outline_rounded, color: Colors.deepPurple.shade300, size: 32),
            const SizedBox(width: 12),
            Expanded(child: Text(insightText, style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w600, color: primaryDark.withOpacity(0.8), height: 1.4))),
          ],
        ),
      ),
    );
  }
}

class _ContextualAlert extends StatelessWidget {
  final HealthProvider provider;
  const _ContextualAlert({required this.provider});

  @override
  Widget build(BuildContext context) {
    String? message;
    IconData icon = Icons.info_outline;
    Color color = Colors.blue.shade100;
    Color iconColor = Colors.blue.shade800;

    if (provider.isHrvTrendAlert) {
      message = 'HRV Alert: Your HRV is trending down, which can be a sign of stress. Prioritizing rest may help.';
      icon = Icons.trending_down;
      color = hrvBlue.withOpacity(0.2);
      iconColor = hrvBlue;
    } else if (provider.isSleepAlert) {
      message = 'Sleep Alert: Your average sleep is low. This can impact focus and mood.';
      icon = Icons.bedtime_outlined;
      color = primaryPurple.withOpacity(0.2);
      iconColor = primaryPurple;
    } else if (provider.isActivityAlert) {
      message = 'Activity Check: Your steps are below target. More movement can boost energy.';
      icon = Icons.directions_walk_outlined;
      color = primaryMint.withOpacity(0.3);
      iconColor = primaryTeal;
    }

    if (message == null) {
      return const SizedBox.shrink();
    }

    return Card(
      color: color,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Navigating to relevant wellness resources...'),
                      backgroundColor: primaryTeal,
                    ),
                  );
                },
                child: Text('Take Action →', style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SleepTimelineChart extends StatelessWidget {
  const _SleepTimelineChart();

  String _getMoodEmoji(double? moodRating) {
    if (moodRating == null) return '';
    if (moodRating > 4.5) return '😊';
    if (moodRating > 3.5) return '🙂';
    if (moodRating > 2.5) return '😐';
    if (moodRating > 1.5) return '😟';
    return '😥';
  }

  @override
  Widget build(BuildContext context) {
    final dailyData = Provider.of<HealthProvider>(context).combinedWeeklyData;
    const minY = 4.0, maxY = 10.0, targetSleep = 7.5;

    final barChart = BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(enabled: false),
        titlesData: _buildTitles(dailyData, (v) => '${v.toInt()}h', 2),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        maxY: maxY,
        minY: minY,
        barGroups: dailyData.asMap().entries.map((entry) {
          final metric = entry.value;
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: metric.sleepHours,
                color: metric.sleepHours >= targetSleep ? primaryMint : (metric.sleepHours >= 6.0 ? Colors.amber.shade300 : primaryPink),
                width: 22,
                borderRadius: BorderRadius.circular(6),
                backDrawRodData: BackgroundBarChartRodData(show: true, toY: maxY, color: Colors.grey.withOpacity(0.05)),
              ),
            ],
          );
        }).toList(),
        extraLinesData: _buildHorizontalLine(targetSleep, primaryPurple, 'Target (${targetSleep}h)'),
      ),
    );

    return Stack(
      children: [
        barChart,
        LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: dailyData.asMap().entries.map((entry) {
                final metric = entry.value;
                final bottomPadding = (metric.sleepHours - minY) / (maxY - minY) * (constraints.maxHeight - 40);
                return Container(
                  width: (constraints.maxWidth / dailyData.length) - 10,
                  margin: EdgeInsets.only(bottom: bottomPadding + 30),
                  alignment: Alignment.bottomCenter,
                  child: Text(_getMoodEmoji(metric.moodRating), style: const TextStyle(fontSize: 16)),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _HrvLineChart extends StatelessWidget {
  const _HrvLineChart();

  @override
  Widget build(BuildContext context) {
    final dailyData = Provider.of<HealthProvider>(context).combinedWeeklyData;
    final hrvValues = dailyData.map((d) => d.hrv).whereType<int>().toList();
    if (hrvValues.isEmpty) return const Center(child: Text("No HRV data available."));

    final minY = (hrvValues.reduce(min) - 5).toDouble();
    final maxY = (hrvValues.reduce(max) + 5).toDouble();

    final avgHrv = hrvValues.reduce((a, b) => a + b) / hrvValues.length;
    final stdDev = sqrt(hrvValues.map((x) => pow(x - avgHrv, 2)).reduce((a, b) => a + b) / hrvValues.length);
    final lowerBand = avgHrv - stdDev;
    final upperBand = avgHrv + stdDev;

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1)),
        titlesData: _buildTitles(dailyData, (v) => v.toInt().toString(), (maxY - minY) / 3),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (dailyData.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: dailyData.asMap().entries.where((e) => e.value.hrv != null).map((entry) => FlSpot(entry.key.toDouble(), entry.value.hrv!.toDouble())).toList(),
            isCurved: true,
            color: hrvBlue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true, getDotPainter: (spot, p, bar, i) => FlDotCirclePainter(radius: 4, color: hrvBlue, strokeColor: Colors.white, strokeWidth: 2)),
            belowBarData: BarAreaData(show: true, color: hrvBlue.withOpacity(0.1)),
          ),
        ],
        rangeAnnotations: RangeAnnotations(
          horizontalRangeAnnotations: [
            HorizontalRangeAnnotation(y1: lowerBand.toDouble(), y2: upperBand.toDouble(), color: hrvBlue.withOpacity(0.08)),
          ],
        ),
      ),
    );
  }
}

class _StepsBarChart extends StatelessWidget {
  const _StepsBarChart();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HealthProvider>(context);
    final dailyData = provider.combinedWeeklyData;
    final maxSteps = dailyData.isEmpty ? 12000.0 : dailyData.map((d) => d.steps).reduce(max) * 1.1;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(enabled: false),
        titlesData: _buildTitles(dailyData, (v) => '${(v / 1000).toStringAsFixed(0)}k', maxSteps / 4),
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1)),
        borderData: FlBorderData(show: false),
        maxY: maxSteps,
        barGroups: dailyData.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.steps.toDouble(),
                color: primaryTeal.withOpacity(0.8),
                width: 16,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }).toList(),
        extraLinesData: _buildHorizontalLine(provider.avgSteps.toDouble(), primaryTeal, 'Avg (${NumberFormat('#,###').format(provider.avgSteps)})'),
      ),
    );
  }
}

class _HeartRateLineChart extends StatelessWidget {
  const _HeartRateLineChart();

  @override
  Widget build(BuildContext context) {
    final dailyData = Provider.of<HealthProvider>(context).combinedWeeklyData;
    final rhrValues = dailyData.map((d) => d.restingHeartRate).toList();
    if (rhrValues.isEmpty) return const Center(child: Text("No data."));

    final minY = (rhrValues.reduce(min) - 5).toDouble();
    final maxY = (rhrValues.reduce(max) + 5).toDouble();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1)),
        titlesData: _buildTitles(dailyData, (v) => v.toInt().toString(), (maxY - minY) / 3),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (dailyData.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: dailyData.asMap().entries.map((entry) => FlSpot(entry.key.toDouble(), entry.value.restingHeartRate.toDouble())).toList(),
            isCurved: true,
            color: primaryPink,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true, getDotPainter: (spot, p, bar, i) => FlDotCirclePainter(radius: 4, color: primaryPink, strokeColor: Colors.white, strokeWidth: 2)),
            belowBarData: BarAreaData(show: true, color: primaryPink.withOpacity(0.1)),
          ),
        ],
      ),
    );
  }
}

// --- Chart Helper Functions ---

FlTitlesData _buildTitles(List<DailyCombinedMetric> data, String Function(double) leftTitleFormatter, double leftInterval) {
  return FlTitlesData(
    show: true,
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          final int index = value.toInt();
          if (index >= 0 && index < data.length) {
            return Text(DateFormat('EEE').format(data[index].date), style: const TextStyle(fontSize: 10, color: Colors.grey));
          }
          return const Text('');
        },
        reservedSize: 30,
      ),
    ),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) => Text(leftTitleFormatter(value), style: const TextStyle(fontSize: 10, color: Colors.grey)),
        reservedSize: 40,
        interval: leftInterval,
      ),
    ),
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  );
}

ExtraLinesData _buildHorizontalLine(double y, Color color, String label) {
  return ExtraLinesData(
    horizontalLines: [
      HorizontalLine(
        y: y,
        color: color.withOpacity(0.6),
        strokeWidth: 1.5,
        dashArray: [8, 4],
        label: HorizontalLineLabel(
          show: true,
          alignment: Alignment.topRight,
          padding: const EdgeInsets.only(right: 5, bottom: 2),
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
          labelResolver: (_) => label,
        ),
      ),
    ],
  );
}