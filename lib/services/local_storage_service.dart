import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyCustomSubjects = 'quiz_custom_subjects_map';

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
