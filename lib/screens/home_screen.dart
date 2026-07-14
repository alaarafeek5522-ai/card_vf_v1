import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/card_model.dart';
import '../services/vodafone_service.dart';
import '../services/balance_service.dart';
import '../theme/app_theme.dart';
import 'charge_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<CardModel> _cards = CardModel.getAll();
  String _search = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _isLoading = false);
  }

  List<CardModel> get _filtered => _cards
      .where((c) => c.name.contains(_search) || c.netCharge.contains(_search))
      .toList();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppTheme.white,
            surfaceTintColor: Colors.transparent,
            elevation: 1,
            shadowColor: Colors.black.withOpacity(0.08),
            flexibleSpace: FlexibleSpaceBar(
              background: _AppBarBg(),
              title: const _ShimmerTitle(),
              centerTitle: false,
              titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 14),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.history_rounded, color: AppTheme.black),
                onPressed: () => Navigator.push(context, _SlideRoute(page: const HistoryScreen())),
              ),
              IconButton(
                icon: const Icon(Icons.whatsapp_rounded, color: Color(0xFF25D366)),
                onPressed: () => launchUrl(Uri.parse('https://wa.me/+201143172355'), mode: LaunchMode.externalApplication),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style: GoogleFonts.cairo(color: AppTheme.black),
                decoration: InputDecoration(
                  hintText: 'ابحث عن باقة...',
                  hintStyle: GoogleFonts.cairo(color: AppTheme.grey),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.grey),
                  filled: true, fillColor: AppTheme.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppTheme.redVF, width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppTheme.lightGrey)),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(children: [
                Container(width: 4, height: 18, decoration: BoxDecoration(
                  color: AppTheme.redVF, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 8),
                Text('الباقات المتاحة',
                  style: GoogleFonts.cairo(color: AppTheme.black, fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${_filtered.length} باقة',
                  style: GoogleFonts.cairo(color: AppTheme.grey, fontSize: 13)),
              ]),
            ),
          ),

          if (_isLoading)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.95),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _SkeletonCard(), childCount: 6),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.95),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _CardTile(card: _filtered[i], stars: _stars)
                      .animate()
                      .fadeIn(delay: (i * 30).ms, duration: 300.ms)
                      .scale(begin: const Offset(0.9, 0.9)),
                  childCount: _filtered.length),
              ),
            ),
        ],
      ),
    );
  }
}

class _ShimmerTitle extends StatefulWidget {
  const _ShimmerTitle();
  @override
  State<_ShimmerTitle> createState() => _ShimmerTitleState();
}

class _ShimmerTitleState extends State<_ShimmerTitle>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: const [AppTheme.redVF, Color(0xFFFF4444), AppTheme.darkRed, Color(0xFFFF4444), AppTheme.redVF],
          stops: [0.0, (_ctrl.value - 0.1).clamp(0.0, 1.0), _ctrl.value.clamp(0.0, 1.0),
            (_ctrl.value + 0.1).clamp(0.0, 1.0), 1.0],
          begin: Alignment.centerLeft, end: Alignment.centerRight,
        ).createShader(bounds),
        child: Text('𝘾𝙖𝙧𝙙 𝙑𝙤𝙙𝙖𝙛𝙤𝙣𝙚',
          style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.redVF)),
      ),
    );
  }
}

class _AppBarBg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.white,
      child: Stack(children: [
        Positioned(top: -40, right: -40,
          child: Container(width: 180, height: 180,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: AppTheme.redVF.withOpacity(0.05)))),
        Positioned(bottom: -20, left: 20,
          child: Container(width: 100, height: 100,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: AppTheme.starColor.withOpacity(0.06)))),
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Image.asset('assets/images/app_icon.png', height: 50,
              errorBuilder: (_, __, ___) => const SizedBox()),
          ),
        ),
      ]),
    );
  }
}

class _CardTile extends StatelessWidget {
  final CardModel card;
  const _CardTile({required this.card});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, _SlideRoute(page: ChargeScreen(card: card))),
      child: Container(
        decoration: AppTheme.whiteCard(),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppTheme.redVF.withOpacity(0.08),
                    border: Border.all(color: AppTheme.redVF.withOpacity(0.2), width: 1.5)),
                  padding: const EdgeInsets.all(6),
                  child: Image.asset('assets/images/app_icon.png', fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.credit_card, color: AppTheme.redVF, size: 22))),
                // نجمة واحدة في اليمين
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasStars ? AppTheme.starColor.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: hasStars ? AppTheme.starColor.withOpacity(0.3) : Colors.grey.withOpacity(0.2)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.star_rounded, color: AppTheme.starColor, size: 14),
                    const SizedBox(width: 2),
                    Text('1', style: GoogleFonts.cairo(
                      color: AppTheme.starColor,
                      fontSize: 11, fontWeight: FontWeight.bold)),
                  ]),
                ),
              ]),

              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(card.name,
                  style: GoogleFonts.cairo(color: AppTheme.black, fontSize: 14, fontWeight: FontWeight.bold),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(children: [
                  Icon(Icons.bolt, color: AppTheme.starColor, size: 12),
                  const SizedBox(width: 2),
                  Expanded(child: Text(card.units,
                    style: GoogleFonts.cairo(color: AppTheme.grey, fontSize: 10),
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
              ]),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: AppTheme.redVF,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: AppTheme.redVF.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: Text('\${card.netCharge} ج',
                  style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  textAlign: TextAlign.center)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatefulWidget {
  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    _anim = Tween(begin: 0.5, end: 1.0).animate(_ctrl);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightGrey.withOpacity(_anim.value),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(width: 44, height: 44,
                  decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(12))),
                Container(width: 36, height: 22,
                  decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(10))),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 80, height: 12,
                  decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(6))),
                const SizedBox(height: 6),
                Container(width: 50, height: 10,
                  decoration: BoxDecoration(color: Colors.grey.withOpacity(0.15), borderRadius: BorderRadius.circular(6))),
              ]),
              Container(width: double.infinity, height: 34,
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(10))),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideRoute extends PageRouteBuilder {
  final Widget page;
  _SlideRoute({required this.page}) : super(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      final slide = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
          .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      final fade = Tween(begin: 0.0, end: 1.0)
          .animate(CurvedAnimation(parent: animation, curve: Curves.easeIn));
      return SlideTransition(position: slide, child: FadeTransition(opacity: fade, child: child));
    },
    transitionDuration: const Duration(milliseconds: 350),
  );
}
