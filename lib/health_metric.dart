// NOTE: This file defines the data structures for your health and mood data.
// It's kept separate for better organization and clarity.

import 'dart:math';

// Represents physical data, likely from a 'health_metrics' table in your database.
class HealthMetric {
  final DateTime metricDate;
  final double sleepHours;
  final int steps;
  final int restingHeartRate;
  final int? hrv; // Heart Rate Variability (nullable, as not all devices track it)

  HealthMetric({
    required this.metricDate,
    required this.sleepHours,
    required this.steps,
    required this.restingHeartRate,
    this.hrv,
  });
}

// Represents self-reported data, likely from a separate 'mood_checkins' table.
class MoodCheckin {
  final DateTime checkinDate;
  final double moodRating; // A 1-5 scale
  final double stressLevel; // A 1-5 scale

  MoodCheckin({
    required this.checkinDate,
    required this.moodRating,
    required this.stressLevel,
  });
}

// A combined class that holds data for a single day from both sources.
// This is the primary model the UI will use to display correlated data.
class DailyCombinedMetric {
  final HealthMetric health;
  final MoodCheckin? mood; // Mood is nullable in case the user didn't check in.

  DailyCombinedMetric({required this.health, this.mood});

  // Helper getters to make accessing data in the UI much cleaner and simpler.
  DateTime get date => health.metricDate;
  double get sleepHours => health.sleepHours;
  int get steps => health.steps;
  int get restingHeartRate => health.restingHeartRate;
  int? get hrv => health.hrv;
  double? get moodRating => mood?.moodRating;
  double? get stressLevel => mood?.stressLevel;
}