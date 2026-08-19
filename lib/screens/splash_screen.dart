import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/vodafone_service.dart';
import '../services/license_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'license_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerCtrl;
  String _status = '';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    Future.delayed(const Duration(milliseconds: 1200), _startChecks);
  }

  bool _isVersionLower(String current, String minimum) {
    final c = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final m = minimum.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    for (int i = 0; i < m.length; i++) {
      final cv = i < c.length ? c[i] : 0;
      if (cv < m[i]) return true;
      if (cv > m[i]) return false;
    }
    return false;
  }

  Future<void> _startChecks() async {
    setState(() => _status = 'جاري التحقق...');
    final config = await VodafoneService.fetchRemoteConfig();

    if (config['stopped'] == true) {
      _showDialog(
        icon: Icons.block_rounded,
        iconColor: AppTheme.redVF,
        title: 'التطبيق متوقف',
        message: config['stopped_message'] ?? 'التطبيق متوقف مؤقتاً',
        actions: [_DialogBtn(label: 'خروج', color: AppTheme.redVF, onTap: () => SystemNavigator.pop())],
      );
      return;
    }

    final minVersion = config['min_version']?.toString() ?? '1.0';
    final info = await PackageInfo.fromPlatform();
    if (_isVersionLower(info.version, minVersion)) {
      _showDialog(
        icon: Icons.system_update_rounded,
        iconColor: AppTheme.gold,
        title: 'تحديث جديد',
        message: config['update_message'] ?? 'يوجد تحديث جديد',
        actions: [
          _DialogBtn(
            label: '⬇️ تحديث الآن',
            color: AppTheme.gold,
            onTap: () async {
              final url = config['update_url'] ?? '';
              if (url.isNotEmpty) await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            },
          ),
        ],
      );
      return;
    }

    setState(() => _status = 'جاري التحقق من الترخيص...');
    final licenseResult = await LicenseService.validateSavedKey();
    if (!mounted) return;

    if (licenseResult.success) {
      setState(() => _status = 'جاهز ✓');
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (_, a, __) => const HomeScreen(),
          transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ));
      }
    } else if (licenseResult.isConnectionError) {
      _showDialog(
        icon: Icons.wifi_off_rounded,
        iconColor: AppTheme.gold,
        title: 'خطأ في الاتصال',
        message: 'تعذر الاتصال بالسيرفر\nتأكد من اتصالك بالإنترنت',
        actions: [
          _DialogBtn(label: 'إعادة المحاولة', color: AppTheme.gold, onTap: () { Navigator.pop(context); _startChecks(); }),
          _DialogBtn(label: 'خروج', color: AppTheme.darkGrey, onTap: () => SystemNavigator.pop()),
        ],
      );
    } else {
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (_, a, __) => const LicenseScreen(),
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ));
    }
  }

  void _showDialog({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required List<Widget> actions,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: AppTheme.goldGlowCard(radius: 26),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconColor.withOpacity(0.12),
                    border: Border.all(color: iconColor.withOpacity(0.4), width: 2),
                  ),
                  child: Icon(icon, color: iconColor, size: 44),
                ),
                const SizedBox(height: 20),
                Text(title, style: GoogleFonts.cairo(color: AppTheme.offWhite, fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text(message, style: GoogleFonts.cairo(color: AppTheme.grey, fontSize: 14), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ...actions,
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() { _shimmerCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Stack(
          children: [
            // توهجات خلفية فخمة
            Positioned(top: -120, right: -100,
              child: Container(width: 380, height: 380,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [AppTheme.redVF.withOpacity(0.20), Colors.transparent])))),
            Positioned(bottom: -100, left: -100,
              child: Container(width: 320, height: 320,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [AppTheme.gold.withOpacity(0.12), Colors.transparent])))),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // لوجو فخم بإطار ذهبي متوهج
                  Container(
                    width: 168, height: 168,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.surface,
                      boxShadow: [
                        BoxShadow(color: AppTheme.gold.withOpacity(0.35), blurRadius: 46, spreadRadius: 4),
                        BoxShadow(color: AppTheme.redVF.withOpacity(0.18), blurRadius: 90, spreadRadius: 18),
                        BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 24, offset: const Offset(0, 12)),
                      ],
                      border: const GradientBoxBorder(gradient: AppTheme.goldGradient, width: 2.2),
                    ),
                    padding: const EdgeInsets.all(28),
                    child: Image.asset('assets/images/app_icon.png',
                      errorBuilder: (_, __, ___) => const Icon(Icons.signal_cellular_alt, color: AppTheme.gold, size: 70)),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.04, 1.04), duration: 1500.ms),

                  const SizedBox(height: 48),

                  // شيمر ذهبي على الاسم
                  AnimatedBuilder(
                    animation: _shimmerCtrl,
                    builder: (_, __) => ShaderMask(
                      shaderCallback: (bounds) => AppTheme.shimmerGold(t: _shimmerCtrl.value).createShader(bounds),
                      child: Text('𝘾𝙖𝙧𝙙 𝙑𝙤𝙙𝙖𝙛𝙤𝙣𝙚',
                        style: GoogleFonts.cairo(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.gold,
                          letterSpacing: 1)),
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),

                  const SizedBox(height: 10),

                  ShaderMask(
                    shaderCallback: (bounds) => AppTheme.goldGradient.createShader(bounds),
                    child: Text('Team Ahmed',
                      style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700,
                        color: Colors.white, letterSpacing: 4),
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 80),

                  if (_status.isNotEmpty) ...[
                    Text(_status,
                      style: GoogleFonts.cairo(color: AppTheme.grey, fontSize: 13),
                    ).animate().fadeIn(),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 180,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          backgroundColor: AppTheme.lightGrey,
                          valueColor: const AlwaysStoppedAnimation(AppTheme.gold),
                          minHeight: 3,
                        ),
                      ),
                    ).animate().fadeIn(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _DialogBtn({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        width: double.infinity, height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: AppTheme.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          onPressed: onTap,
          child: Text(label, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }
}
