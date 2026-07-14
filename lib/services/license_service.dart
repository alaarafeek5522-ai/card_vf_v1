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
    String? saved = prefs.getString(_savedDevicePref);
    if (saved != null) return saved;
    final deviceInfo = DeviceInfoPlugin();
    final android = await deviceInfo.androidInfo;
    final id = android.id;
    await prefs.setString(_savedDevicePref, id);
    return id;
  }

  static Future<Map<String, dynamic>> _fetchGist() async {
    final res = await http.get(
      Uri.parse('https://api.github.com/gists/$_gistId'),
      headers: {
        'Authorization': 'token $_token',
        'Accept': 'application/vnd.github.v3+json',
      },
    ).timeout(const Duration(seconds: 10));
    final data = jsonDecode(res.body);
    final content = data['files'][_fileName]['content'];
    return jsonDecode(content);
  }

  static Future<void> _updateGist(Map<String, dynamic> data) async {
    await http.patch(
      Uri.parse('https://api.github.com/gists/$_gistId'),
      headers: {
        'Authorization': 'token $_token',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'files': {_fileName: {'content': jsonEncode(data)}}
      }),
    ).timeout(const Duration(seconds: 10));
  }

  static Future<LicenseResult> activateKey(String key) async {
    try {
      final deviceId = await _getDeviceId();
      final gistData = await _fetchGist();
      final keys = gistData['keys'] as Map<String, dynamic>? ?? {};

      if (!keys.containsKey(key)) {
        return const LicenseResult(success: false, message: '❌ المفتاح غير صحيح');
      }

      final keyData = keys[key] as Map<String, dynamic>;

      if (keyData['active'] != true) {
        return const LicenseResult(success: false, message: '🚫 هذا المفتاح معطل');
      }

      final existingDevice = keyData['device_id'];
      if (existingDevice != null && existingDevice != deviceId) {
        return const LicenseResult(success: false, message: '⚠️ هذا المفتاح مسجل على جهاز آخر');
      }

      final now = DateTime.now().toIso8601String();
      keys[key] = {
        ...keyData,
        'device_id': deviceId,
        'registered_at': keyData['registered_at'] ?? now,
        'stars': keyData['stars'] ?? 0,
      };
      gistData['keys'] = keys;
      await _updateGist(gistData);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_savedKeyPref, key);

      // تحقق من المدة
      final expiresAt = keyData['expires_at'] as String?;
      if (expiresAt != null) {
        if (DateTime.now().isAfter(DateTime.parse(expiresAt))) {
          return const LicenseResult(success: false, message: '⏰ انتهت صلاحية المفتاح، تواصل مع المطور لتجديده');
        }
      }
      return const LicenseResult(success: true);
    } catch (e) {
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

      final keyData = keys[savedKey] as Map<String, dynamic>;
      if (keyData['active'] != true) return const LicenseResult(success: false, message: '🚫 تم إيقاف هذا المفتاح');
      if (keyData['device_id'] != deviceId) return const LicenseResult(success: false);

      // تحقق من المدة
      final expiresAt = keyData['expires_at'] as String?;
      if (expiresAt != null) {
        if (DateTime.now().isAfter(DateTime.parse(expiresAt))) {
          return const LicenseResult(success: false, message: '⏰ انتهت صلاحية المفتاح، تواصل مع المطور لتجديده');
        }
      }
      return const LicenseResult(success: true);
    } catch (e) {
      return const LicenseResult(success: false, isConnectionError: true);
    }
  }


  static Future<String?> getSavedKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_savedKeyPref);
  }

  static Future<String?> getRegisteredKey() async => getSavedKey();
}
