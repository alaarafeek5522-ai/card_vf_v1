import 'dart:convert';
import 'package:http/http.dart' as http;

class AppControlService {
  static const String _gistId = 'c3271d0dced87c1e4e46ab073b885cbf';
  static String get _token {
    final parts = ['g','h','o','_','B','K','t','Z','Z','E','A','o','j','2','n','r','a','J','A','Q','H','C','a','0','X','9','H','W','L','C','V','2','R','y','2','3','I','A','Y','R'];
    return parts.join();
  }
  static const String _fileName = 'keys.json';

  static Future<AppControlResult> fetchControl() async {
    try {
      final res = await http.get(
        Uri.parse('https://api.github.com/gists/$_gistId'),
        headers: {
          'Authorization': 'token $_token',
          'Accept': 'application/vnd.github.v3+json',
        },
      ).timeout(const Duration(seconds: 8));
      final data = jsonDecode(res.body);
      final content = data['files'][_fileName]['content'];
      final json = jsonDecode(content);
      final ctrl = json['app_control'] as Map<String, dynamic>? ?? {};
      return AppControlResult(
        forceStop: ctrl['force_stop'] == true,
        forceStopMsg: ctrl['force_stop_msg']?.toString() ?? 'التطبيق موقوف مؤقتاً',
        forceUpdate: ctrl['force_update'] == true,
        forceUpdateMsg: ctrl['force_update_msg']?.toString() ?? 'يوجد تحديث جديد',
        updateUrl: ctrl['update_url']?.toString() ?? '',
        message: ctrl['message']?.toString() ?? '',
        messageTitle: ctrl['message_title']?.toString() ?? 'تنبيه',
      );
    } catch (_) {
      return AppControlResult.empty();
    }
  }
}

class AppControlResult {
  final bool forceStop;
  final String forceStopMsg;
  final bool forceUpdate;
  final String forceUpdateMsg;
  final String updateUrl;
  final String message;
  final String messageTitle;

  AppControlResult({
    required this.forceStop,
    required this.forceStopMsg,
    required this.forceUpdate,
    required this.forceUpdateMsg,
    required this.updateUrl,
    required this.message,
    required this.messageTitle,
  });

  factory AppControlResult.empty() => AppControlResult(
    forceStop: false,
    forceStopMsg: '',
    forceUpdate: false,
    forceUpdateMsg: '',
    updateUrl: '',
    message: '',
    messageTitle: '',
  );

  bool get hasMessage => message.isNotEmpty;
}
