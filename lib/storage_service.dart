import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/test_result.dart';

class StorageService {
  static const _keyResults   = 'ksx_results';
  static const _keyDuration  = 'ksx_duration';
  static const _keyDifficulty= 'ksx_difficulty';
  static const _keyLiveWpm   = 'ksx_live_wpm';

  static final StorageService _i = StorageService._();
  factory StorageService() => _i;
  StorageService._();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Results ──────────────────────────────────────────────
  List<TestResult> getAllResults() {
    final raw = _prefs.getStringList(_keyResults) ?? [];
    return raw
        .map((s) => TestResult.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> saveResult(TestResult r) async {
    final list = _prefs.getStringList(_keyResults) ?? [];
    list.add(jsonEncode(r.toJson()));
    // Keep at most 200 results to avoid bloat
    if (list.length > 200) list.removeAt(0);
    await _prefs.setStringList(_keyResults, list);
  }

  Future<void> deleteResult(String id) async {
    final list = getAllResults()..removeWhere((r) => r.id == id);
    await _prefs.setStringList(
        _keyResults, list.map((r) => jsonEncode(r.toJson())).toList());
  }

  Future<void> clearAll() async => _prefs.remove(_keyResults);

  TestResult? getBest() {
    final all = getAllResults();
    if (all.isEmpty) return null;
    return all.reduce((a, b) => a.wpm > b.wpm ? a : b);
  }

  double get avgWpm {
    final all = getAllResults();
    if (all.isEmpty) return 0;
    return all.fold(0, (s, r) => s + r.wpm) / all.length;
  }

  double get avgAccuracy {
    final all = getAllResults();
    if (all.isEmpty) return 0;
    return all.fold(0.0, (s, r) => s + r.accuracy) / all.length;
  }

  Map<String, int> getMistakeLetters() {
    final map = <String, int>{};
    for (final r in getAllResults()) {
      r.mistakeLetters.forEach((k, v) => map[k] = (map[k] ?? 0) + v);
    }
    final sorted = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(10));
  }

  List<TestResult> getLastNDays(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return getAllResults()
        .where((r) => r.timestamp.isAfter(cutoff))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  int get totalTests => getAllResults().length;

  // ── Settings ─────────────────────────────────────────────
  int  get testDuration  => _prefs.getInt(_keyDuration) ?? 60;
  set  testDuration(int v)  => _prefs.setInt(_keyDuration, v);

  int  get difficulty    => _prefs.getInt(_keyDifficulty) ?? 1;
  set  difficulty(int v)    => _prefs.setInt(_keyDifficulty, v);

  bool get showLiveWpm   => _prefs.getBool(_keyLiveWpm) ?? true;
  set  showLiveWpm(bool v)  => _prefs.setBool(_keyLiveWpm, v);

  // ── ID generator (no uuid package needed) ────────────────
  String generateId() =>
      '${DateTime.now().millisecondsSinceEpoch}_${Object().hashCode}';
}