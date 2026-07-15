import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/license_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class LicenseScreen extends StatefulWidget {
  const LicenseScreen({super.key});
  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen> {
  final _keyCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _keyVisible = true;

  Future<void> _activate() async {
    final key = _keyCtrl.text.trim().toUpperCase();
    if (key.isEmpty) {
      setState(() => _error = 'ادخل مفتاح التفعيل');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final result = await LicenseService.activateKey(key);
      if (!mounted) return;
      if (result.success) {
        Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (_, a, __) => const HomeScreen(),
          transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ));
      } else {
        setState(() => _error = result.message ?? 'المفتاح غير صحيح');
      }
    } catch (e) {
      setState(() => _error = 'خطأ في الاتصال، حاول مرة أخرى');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: Stack(
        children: [
          // خلفية
          Positioned(top: -120, right: -80,
            child: Container(width: 320, height: 320,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: AppTheme.redVF.withOpacity(0.06)))),
          Positioned(bottom: -100, left: -60,
            child: Container(width: 280, height: 280,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: AppTheme.redVF.withOpacity(0.04)))),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // لوجو
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.white,
                      boxShadow: [
                        BoxShadow(color: AppTheme.redVF.withOpacity(0.2), blurRadius: 30, spreadRadius: 4),
                        BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 6)),
                      ],
                      border: Border.all(color: AppTheme.redVF.withOpacity(0.15), width: 2),
                    ),
                    padding: const EdgeInsets.all(22),
                    child: Image.asset('assets/images/app_icon.png',
                      errorBuilder: (_, __, ___) => const Icon(Icons.vpn_key_rounded, color: AppTheme.redVF, size: 50)),
                  ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),

                  const SizedBox(height: 32),

                  Text('𝘾𝙖𝙧𝙙 𝙑𝙤𝙙𝙖𝙛𝙤𝙣𝙚',
                    style: GoogleFonts.cairo(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.redVF),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),

                  const SizedBox(height: 6),

                  Text('Team Ahmed',
                    style: GoogleFonts.cairo(fontSize: 13, color: AppTheme.grey, letterSpacing: 2),
                  ).animate().fadeIn(delay: 150.ms),

                  const SizedBox(height: 48),

                  // كارت التفعيل
                  Container(
                    decoration: AppTheme.whiteCard(),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.redVF.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.vpn_key_rounded, color: AppTheme.redVF, size: 22)),
                            const SizedBox(width: 12),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('تفعيل التطبيق',
                                style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.black)),
                              Text('أدخل مفتاح التفعيل الخاص بك',
                                style: GoogleFonts.cairo(fontSize: 12, color: AppTheme.grey)),
                            ]),
                          ]),

                          const SizedBox(height: 24),

                          // حقل المفتاح
                          TextField(
                            controller: _keyCtrl,
                            textAlign: TextAlign.center,
                            textCapitalization: TextCapitalization.characters,
                            obscureText: !_keyVisible,
                            style: GoogleFonts.cairo(
                              fontSize: 18, fontWeight: FontWeight.bold,
                              color: AppTheme.black, letterSpacing: 3),
                            decoration: InputDecoration(
                              hintText: 'XXXX-XXXX-XXXX',
                              hintStyle: GoogleFonts.cairo(color: AppTheme.grey, letterSpacing: 3),
                              filled: true,
                              fillColor: AppTheme.offWhite,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppTheme.redVF, width: 2)),
                              prefixIcon: const Icon(Icons.key_rounded, color: AppTheme.redVF),
                              suffixIcon: IconButton(
                                icon: Icon(_keyVisible ? Icons.visibility_off : Icons.visibility, color: AppTheme.grey),
                                onPressed: () => setState(() => _keyVisible = !_keyVisible),
                              ),
                            ),
                          ),

                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.withOpacity(0.3)),
                              ),
                              child: Row(children: [
                                const Icon(Icons.error_outline_rounded, color: Colors.red, size: 18),
                                const SizedBox(width: 8),
                                Expanded(child: Text(_error!,
                                  style: GoogleFonts.cairo(color: Colors.red, fontSize: 13))),
                              ]),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // زرار التفعيل
                          SizedBox(
                            width: double.infinity, height: 54,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: EdgeInsets.zero),
                              onPressed: _loading ? null : _activate,
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: _loading
                                      ? const LinearGradient(colors: [Colors.grey, Colors.grey])
                                      : const LinearGradient(
                                          colors: [AppTheme.redVF, AppTheme.darkRed],
                                          begin: Alignment.topLeft, end: Alignment.bottomRight),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [BoxShadow(color: AppTheme.redVF.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                                ),
                                child: Center(
                                  child: _loading
                                      ? const SizedBox(width: 24, height: 24,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                      : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                          const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 20),
                                          const SizedBox(width: 10),
                                          Text('تفعيل', style: GoogleFonts.cairo(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                                        ]),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                  const SizedBox(height: 24),

                  // التواصل مع المطور عبر واتساب
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => launchUrl(
                      Uri.parse('https://wa.me/201143172355'),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.offWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.lightGrey),
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.chat_rounded, color: Color(0xFF25D366), size: 20),
                        const SizedBox(width: 8),
                        Text('التواصل مع المطور',
                          style: GoogleFonts.cairo(color: AppTheme.darkGrey, fontSize: 13, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
