import 'package:flutter/material.dart';

class TestResult {
  final String id;
  final int wpm;
  final double accuracy;
  final int mistakes;
  final DateTime timestamp;
  final int duration;
  final String mode;
  final int totalChars;
  final Map<String, int> mistakeLetters;

  const TestResult({
    required this.id,
    required this.wpm,
    required this.accuracy,
    required this.mistakes,
    required this.timestamp,
    required this.duration,
    required this.mode,
    required this.totalChars,
    required this.mistakeLetters,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'wpm': wpm,
    'accuracy': accuracy,
    'mistakes': mistakes,
    'timestamp': timestamp.toIso8601String(),
    'duration': duration,
    'mode': mode,
    'totalChars': totalChars,
    'mistakeLetters': mistakeLetters,
  };

  factory TestResult.fromJson(Map<String, dynamic> j) => TestResult(
    id: j['id'] as String,
    wpm: j['wpm'] as int,
    accuracy: (j['accuracy'] as num).toDouble(),
    mistakes: j['mistakes'] as int,
    timestamp: DateTime.parse(j['timestamp'] as String),
    duration: j['duration'] as int,
    mode: j['mode'] as String,
    totalChars: j['totalChars'] as int,
    mistakeLetters: Map<String, int>.from(j['mistakeLetters'] as Map),
  );

  String get grade {
    if (wpm >= 100) return 'S';
    if (wpm >= 80) return 'A';
    if (wpm >= 60) return 'B';
    if (wpm >= 40) return 'C';
    if (wpm >= 20) return 'D';
    return 'F';
  }

  String get gradeLabel {
    if (wpm >= 100) return 'Legendary';
    if (wpm >= 80) return 'Expert';
    if (wpm >= 60) return 'Advanced';
    if (wpm >= 40) return 'Intermediate';
    if (wpm >= 20) return 'Beginner';
    return 'Novice';
  }

  Color get gradeColor {
    if (wpm >= 100) return const Color(0xFF7C3AED);
    if (wpm >= 80) return const Color(0xFF4A6CF7);
    if (wpm >= 60) return const Color(0xFF06D6A0);
    if (wpm >= 40) return const Color(0xFFFFA94D);
    if (wpm >= 20) return const Color(0xFFFF4F6E);
    return const Color(0xFFB0B7C3);
  }
}