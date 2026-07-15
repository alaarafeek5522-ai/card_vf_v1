import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

class LicenseResult {
  final bool success;
  final String? message;
  final bool isConnectionError;

  const LicenseResult({
    required this.success,
    this.message,
    this.isConnectionError = false,
  });
}

class LicenseService {
  static const String _gistId = 'c3271d0dced87c1e4e46ab073b885cbf';
  static const String _fileName = 'keys.json';
  static const String _savedKeyPref = 'saved_license_key';
  static const String _savedDevicePref = 'saved_device_id';

  static String get _token {
    final parts = ['g', 'h', 'o', '_', 'u', 'g', 'I', 'f', 'U', 'i', 'p', 's', 'F', 'L', 'J', 'v', 'K', 'L', 'T', 'v', 'n', 'e', 'f', 'S', 'J', 'Q', 'c', 'V', 'q', 'q', 'Y', 'l', 'F', 'Y', '3', 'D', 'G', 'k', 'H', 'v'];
    return parts.join();
  }

  static Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_savedDevicePref);
    if (saved != null) return saved;
    final android = await DeviceInfoPlugin().androidInfo;
    await prefs.setString(_savedDevicePref, android.id);
    return android.id;
  }

  static Future<Map<String, dynamic>> _fetchGist() async {
    final res = await http.get(
      Uri.parse('https://api.github.com/gists/$_gistId'),
      headers: {'Authorization': 'token $_token', 'Accept': 'application/vnd.github.v3+json'},
    ).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) throw Exception('Gist read failed');
    final data = jsonDecode(res.body);
    return Map<String, dynamic>.from(jsonDecode(data['files'][_fileName]['content']));
  }

  static Future<void> _updateGist(Map<String, dynamic> data) async {
    final res = await http.patch(
      Uri.parse('https://api.github.com/gists/$_gistId'),
      headers: {
        'Authorization': 'token $_token',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'files': {_fileName: {'content': jsonEncode(data)}}}),
    ).timeout(const Duration(seconds: 10));
    if (res.statusCode < 200 || res.statusCode >= 300) throw Exception('Gist update failed');
  }

  static LicenseResult? _checkExpiry(Map<String, dynamic> keyData) {
    final raw = keyData['expires_at']?.toString();
    if (raw == null || raw.isEmpty) {
      return const LicenseResult(
        success: false,
        message: '⏳ هذا المفتاح لا يحتوي على مدة صلاحية. تواصل مع المطور لتجديده.',
      );
    }
    final expiresAt = DateTime.tryParse(raw)?.toUtc();
    if (expiresAt == null || !DateTime.now().toUtc().isBefore(expiresAt)) {
      return const LicenseResult(
        success: false,
        message: '⏳ انتهت مدة المفتاح. لازم تتواصل مع المطور لتجديده.',
      );
    }
    return null;
  }

  static Future<LicenseResult> activateKey(String key) async {
    try {
      final deviceId = await _getDeviceId();
      final gistData = await _fetchGist();
      final keys = gistData['keys'] as Map<String, dynamic>? ?? {};

      if (!keys.containsKey(key)) return const LicenseResult(success: false, message: '❌ المفتاح غير صحيح');
      final keyData = Map<String, dynamic>.from(keys[key] as Map);
      if (keyData['active'] != true) return const LicenseResult(success: false, message: '🚫 هذا المفتاح معطل');

      final expiryError = _checkExpiry(keyData);
      if (expiryError != null) return expiryError;

      final existingDevice = keyData['device_id'];
      if (existingDevice != null && existingDevice != deviceId) {
        return const LicenseResult(success: false, message: '⚠️ هذا المفتاح مسجل على جهاز آخر');
      }

      final now = DateTime.now().toUtc().toIso8601String();
      keys[key] = {...keyData, 'device_id': deviceId, 'registered_at': keyData['registered_at'] ?? now};
      gistData['keys'] = keys;
      await _updateGist(gistData);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_savedKeyPref, key);
      return const LicenseResult(success: true);
    } catch (_) {
      return const LicenseResult(success: false, message: 'خطأ في الاتصال، حاول مرة أخرى', isConnectionError: true);
    }
  }

  static Future<LicenseResult> validateSavedKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedKey = prefs.getString(_savedKeyPref);
      if (savedKey == null) return const LicenseResult(success: false);

      final deviceId = await _getDeviceId();
      final gistData = await _fetchGist();
      final keys = gistData['keys'] as Map<String, dynamic>? ?? {};
      if (!keys.containsKey(savedKey)) return const LicenseResult(success: false);

      final keyData = Map<String, dynamic>.from(keys[savedKey] as Map);
      if (keyData['active'] != true) return const LicenseResult(success: false, message: '🚫 تم إيقاف هذا المفتاح');
      final expiryError = _checkExpiry(keyData);
      if (expiryError != null) return expiryError;
      if (keyData['device_id'] != deviceId) return const LicenseResult(success: false);
      return const LicenseResult(success: true);
    } catch (_) {
      return const LicenseResult(success: false, isConnectionError: true);
    }
  }

  static Future<String?> getSavedKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_savedKeyPref);
  }

  static Future<String?> getRegisteredKey() async => getSavedKey();
}
