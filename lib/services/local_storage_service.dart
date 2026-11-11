import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/leaderboard_entry.dart';

class LocalStorageService {
  static const String _keyLeaderboard = 'quiz_leaderboard_entries';
  static const String _keyCustomSubjects = 'quiz_custom_subjects_map';
  static const String _keyPlayerName = 'quiz_stored_player_name';

  /// Save player default name
  static Future<void> savePlayerName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPlayerName, name);
  }

  static Future<String> getPlayerName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPlayerName) ?? 'Alex Hunter';
  }

  /// Leaderboard operations
  static Future<List<LeaderboardEntry>> getLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_keyLeaderboard) ?? [];
    final list = <LeaderboardEntry>[];
    for (var str in raw) {
      try {
        list.add(LeaderboardEntry.fromJson(jsonDecode(str)));
      } catch (_) {}
    }
    // Sort descending by score, then percentage
    list.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;
      return b.percentage.compareTo(a.percentage);
    });
    return list;
  }

  static Future<void> saveScore(LeaderboardEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getLeaderboard();
    existing.add(entry);
    // Sort and keep top 50
    existing.sort((a, b) => b.score.compareTo(a.score));
    final trimmed = existing.take(50).map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_keyLeaderboard, trimmed);
  }

  static Future<void> clearLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLeaderboard);
  }

  /// Custom uploaded subject files
  static Future<Map<String, String>> getCustomSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyCustomSubjects);
    if (raw == null) return {};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map((key, value) => MapEntry(key, value.toString()));
    } catch (_) {
      return {};
    }
  }

  static Future<void> saveCustomSubject(String subjectName, String content) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getCustomSubjects();
    current[subjectName] = content;
    await prefs.setString(_keyCustomSubjects, jsonEncode(current));
  }

  static Future<void> deleteCustomSubject(String subjectName) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getCustomSubjects();
    current.remove(subjectName);
    await prefs.setString(_keyCustomSubjects, jsonEncode(current));
  }
}
