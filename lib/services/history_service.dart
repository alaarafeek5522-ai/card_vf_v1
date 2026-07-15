import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static const String _key = 'charge_history_v1';

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.cast<Map<String, dynamic>>();
  }

  static Future<void> addRecord({
    required String phone,
    required String cardName,
    required String netCharge,
    required bool success,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    history.insert(0, {
      'phone': phone,
      'card': cardName,
      'charge': netCharge,
      'success': success,
      'date': DateTime.now().toIso8601String(),
    });
    if (history.length > 50) history.removeLast();
    await prefs.setString(_key, jsonEncode(history));
  }

  static Future<String?> getLastReceiver() async {
    final history = await getHistory();
    if (history.isEmpty) return null;
    return history.first['phone'] as String?;
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
