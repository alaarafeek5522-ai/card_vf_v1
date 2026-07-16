import 'dart:convert';
import 'package:http/http.dart' as http;

class VodafoneService {
  static const String _configUrl =
      'https://alaarafeek5522-ai.github.io/config_app/config.json';

  static Future<Map<String, dynamic>> fetchRemoteConfig() async {
    try {
      final res = await http
          .get(
            Uri.parse(_configUrl),
            headers: {'Cache-Control': 'no-cache', 'Pragma': 'no-cache'},
          )
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (_) {}
    return {};
  }

  static Future<bool> isVodafoneNetwork() async {
    try {
      final res = await http.get(
        Uri.parse(
            'http://mobile.vodafone.com.eg/checkSeamless/realms/vf-realm/protocol/openid-connect/auth?client_id=ana-vodafone-app-seamless'),
        headers: {
          'User-Agent': 'okhttp/4.12.0',
          'clientId': 'AnaVodafoneAndroid',
          'x-agent-version': '2026.4.1',
          'x-agent-build': '1139',
          'digitalId': '24S0M31T0I9RK',
          'x-agent-device': 'Xiaomi M2101K9AG',
          'x-agent-operatingsystem': '13',
          'Accept-Language': 'ar',
          'Accept-Encoding': 'gzip',
        },
      ).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['msisdn'] != null;
      }
    } catch (_) {}
    return false;
  }

  static Future<Map<String, dynamic>> getSeamlessData() async {
    final res = await http.get(
      Uri.parse(
          'http://mobile.vodafone.com.eg/checkSeamless/realms/vf-realm/protocol/openid-connect/auth?client_id=ana-vodafone-app-seamless'),
      headers: {
        'User-Agent': 'okhttp/4.12.0',
        'Connection': 'Keep-Alive',
        'Accept-Encoding': 'gzip',
        'x-agent-operatingsystem': '13',
        'clientId': 'AnaVodafoneAndroid',
        'Accept-Language': 'ar',
        'x-agent-device': 'Xiaomi M2101K9AG',
        'x-agent-version': '2026.4.1',
        'x-agent-build': '1139',
        'digitalId': '24S0M31T0I9RK',
      },
    );
    return jsonDecode(res.body);
  }

  static Future<String?> getAccessToken(String seamlessToken) async {
    final res = await http.post(
      Uri.parse(
          'https://mobile.vodafone.com.eg/auth/realms/vf-realm/protocol/openid-connect/token'),
      headers: {
        'User-Agent': 'okhttp/4.12.0',
        'Accept': 'application/json, text/plain, */*',
        'Accept-Encoding': 'gzip',
        'seamlessToken': seamlessToken,
        'x-agent-operatingsystem': '13',
        'clientId': 'AnaVodafoneAndroid',
        'Accept-Language': 'ar',
        'x-agent-device': 'Xiaomi M2101K9AG',
        'x-agent-version': '2026.4.1',
        'x-agent-build': '1139',
        'digitalId': '24S0M31T0I9RK',
      },
      body: {
        'grant_type': 'password',
        'client_secret': 'b86e30a8-ae29-467a-a71f-65c73f2ff5e3',
        'client_id': 'cash-app',
      },
    );
    return jsonDecode(res.body)['access_token'];
  }

  static Future<Map<String, dynamic>> chargeCard({
    required String productId,
    required String receiver,
    required String pin,
    required String senderMsisdn,
    required String accessToken,
  }) async {
    final payload = {
      "channel": {"name": "MobileApp"},
      "orderItem": [
        {
          "action": "insert",
          "id": productId,
          "product": {
            "characteristic": [
              {"name": "PaymentMethod", "value": "VFCash"},
              {"name": "USE_EMONEY", "value": "False"},
              {"name": "MerchantCode", "value": ""}
            ],
            "id": productId,
            "relatedParty": [
              {"id": senderMsisdn, "name": "MSISDN", "role": "Subscriber"},
              {"id": receiver, "name": "Receiver", "role": "Receiver"}
            ]
          },
          "@type": productId,
          "eCode": 0
        }
      ],
      "relatedParty": [
        {"id": pin, "name": "pin", "role": "Requestor"}
      ],
      "@type": "CashFakkaAndMared"
    };

    final msisdn =
        senderMsisdn.startsWith('0') ? senderMsisdn : '0$senderMsisdn';

    final res = await http.post(
      Uri.parse('https://mobile.vodafone.com.eg/services/dxl/pom/productOrder'),
      headers: {
        'User-Agent': 'okhttp/4.12.0',
        'Connection': 'Keep-Alive',
        'Accept': 'application/json',
        'Accept-Encoding': 'gzip',
        'Content-Type': 'application/json',
        'api-host': 'ProductOrderingManagement',
        'useCase': 'CashFakkaAndMared',
        'api-version': 'v2',
        'msisdn': msisdn,
        'Authorization': 'Bearer $accessToken',
        'Accept-Language': 'ar',
        'x-agent-operatingsystem': '13',
        'clientId': 'AnaVodafoneAndroid',
        'x-agent-device': 'Xiaomi M2101K9AG',
        'x-agent-version': '2026.4.1',
        'x-agent-build': '1139',
        'digitalId': '24S0M31T0I9RK',
      },
      body: jsonEncode(payload),
    );
    return jsonDecode(res.body);
  }
}
