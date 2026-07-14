import 'dart:convert';
import 'package:http/http.dart' as http;

class VodafoneService {
  static Future<ChargeResult> chargeCard({
    required String phone,
    required String productId,
    required String netCharge,
  }) async {
    try {
      final url = Uri.parse(
        'https://apismartapp.pythonanywhere.com/vf/?phone=$phone&product_id=$productId&net_charge=$netCharge',
      );
      final res = await http.get(url).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final success = data['success'] == true || data['status'] == 'success';
        return ChargeResult(
          success: success,
          message: data['message'] ?? (success ? 'تم الشحن بنجاح ✅' : 'فشل الشحن ❌'),
        );
      }
      return ChargeResult(success: false, message: 'فشل الاتصال بالخادم ❌');
    } catch (_) {
      return ChargeResult(success: false, message: 'خطأ في الاتصال ❌');
    }
  }

  static Future<Map<String, dynamic>> fetchRemoteConfig() async {
    try {
      final res = await http.get(
        Uri.parse('https://alaarafeek5522-ai.github.io/card_vf_v1_config/config.json'),
      ).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) return Map<String, dynamic>.from(jsonDecode(res.body));
    } catch (_) {}
    return {};
  }

  static Future<bool> isVodafoneNetwork() async {
    try {
      final res = await http.get(
        Uri.parse('http://mobile.vodafone.com.eg/checkSeamless/realms/vf-realm/protocol/openid-connect/auth?client_id=ana-vodafone-app-seamless'),
        headers: {'User-Agent': 'okhttp/4.11.0'},
      ).timeout(const Duration(seconds: 6));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

class ChargeResult {
  final bool success;
  final String message;
  ChargeResult({required this.success, required this.message});
}
