import 'dart:convert';
import 'package:http/http.dart' as http;

class BalanceResult {
  final bool success;
  final String? balance;
  final String? message;
  const BalanceResult({required this.success, this.balance, this.message});
}

class BalanceService {
  static Future<BalanceResult> getBalance({required String pin}) async {
    try {
      // Seamless
      final seamlessRes = await http.get(
        Uri.parse('http://mobile.vodafone.com.eg/checkSeamless/realms/vf-realm/protocol/openid-connect/auth?client_id=ana-vodafone-app-seamless'),
        headers: {
          'User-Agent': 'okhttp/4.11.0',
          'Connection': 'Keep-Alive',
          'Accept-Encoding': 'gzip',
          'x-agent-operatingsystem': '13',
          'clientId': 'AnaVodafoneAndroid',
          'Accept-Language': 'ar',
          'x-agent-device': 'OPPO CPH2235',
          'x-agent-version': '2024.7.2.1',
          'x-agent-build': '1050',
          'digitalId': '24S0M31T0I9RK',
        },
      ).timeout(const Duration(seconds: 10));

      final seamlessData = jsonDecode(seamlessRes.body);
      final seamlessToken = seamlessData['seamlessToken'];
      if (seamlessToken == null) {
        return const BalanceResult(success: false, message: 'فشل تسجيل الدخول - تأكد من داتا فودافون');
      }

      // Access Token
      final tokenRes = await http.post(
        Uri.parse('https://mobile.vodafone.com.eg/auth/realms/vf-realm/protocol/openid-connect/token'),
        headers: {
          'User-Agent': 'okhttp/4.11.0',
          'Accept': 'application/json, text/plain, */*',
          'Accept-Encoding': 'gzip',
          'silentLogin': 'true',
          'seamlessToken': seamlessToken,
          'firstTimeLogin': 'true',
          'x-agent-operatingsystem': '13',
          'clientId': 'AnaVodafoneAndroid',
          'Accept-Language': 'ar',
          'x-agent-device': 'OPPO CPH2235',
          'x-agent-version': '2024.7.2.1',
          'x-agent-build': '1050',
          'digitalId': '24S0M31T0I9RK',
        },
        body: {
          'grant_type': 'password',
          'client_secret': 'b86e30a8-ae29-467a-a71f-65c73f2ff5e3',
          'client_id': 'cash-app',
        },
      ).timeout(const Duration(seconds: 10));

      final tokenData = jsonDecode(tokenRes.body);
      final accessToken = tokenData['access_token'];
      if (accessToken == null) {
        return const BalanceResult(success: false, message: 'فشل الحصول على token');
      }

      // Decode JWT للرقم
      final parts = accessToken.split('.');
      final padding = (4 - (parts[1].length % 4)) as int;
      final padded = parts[1] + (padding != 4 ? '=' * padding : '');
      final decoded = jsonDecode(utf8.decode(base64Decode(padded)));
      final number = decoded['userInfo']?['msisdn'] ?? decoded['preferred_username'];

      if (number == null) {
        return const BalanceResult(success: false, message: 'تعذر الحصول على رقم المحفظة');
      }

      // رصيد الكاش
      final balanceRes = await http.get(
        Uri.parse('https://mobile.vodafone.com.eg/services/dxl/pm/paymentMethod/$number?%40type=DigitalWallet&%40referredType=CashBalance'),
        headers: {
          'User-Agent': 'okhttp/4.12.0',
          'Connection': 'close',
          'Accept': 'application/json',
          'Accept-Encoding': 'gzip',
          'pinCode': pin,
          'X-Request-ID': '2e3a365d-b3f3-4494-bb86-9318096d30fc',
          'X-App-StackTrace': '',
          'device-id': '48ad4d6d0e273340',
          'Content-Type': 'application/json',
          'api-version': 'v2',
          'msisdn': number,
          'Authorization': 'Bearer $accessToken',
          'Accept-Language': 'ar',
          'x-agent-operatingsystem': '12',
          'x-agent-device': 'OPPO CPH2471',
          'x-agent-version': '2026.4.1',
          'x-agent-build': '1139',
          'digitalId': '25N8E4AMYUNL6',
          'clientId': 'AnaVodafoneAndroid',
        },
      ).timeout(const Duration(seconds: 10));

      final balanceData = jsonDecode(balanceRes.body);
      final balance = balanceData['characteristics']?[0]?['value']?.toString();

      if (balance == null) {
        return const BalanceResult(success: false, message: 'تعذر الحصول على الرصيد');
      }

      return BalanceResult(success: true, balance: balance.toString());
    } catch (e) {
      return BalanceResult(success: false, message: 'خطأ في الاتصال: ${e.toString()}');
    }
  }
}
