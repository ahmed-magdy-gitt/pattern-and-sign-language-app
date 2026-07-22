import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final bool seenOnboarding;
  const SplashScreen({super.key, required this.seenOnboarding});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  static const _bgDark = Color(0xFFF6F3EE);
  static const _bgMid = Color(0xFFEDE6DE);
  static const _bgLight = Color(0xFFFDF9F4);

  static const _primary = Color(0xFFE89A3E);
  static const _accent = Color(0xFF2F3242);
  static const _accentSoft = Color(0xFF70778A);

  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1600));

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller,
            curve: const Interval(0.0, 0.65, curve: Curves.easeOut)));

    _scaleAnim = Tween<double>(begin: 0.72, end: 1.0).animate(
        CurvedAnimation(parent: _controller,
            curve: const Interval(0.0, 0.65, curve: Curves.elasticOut)));

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.pushReplacementNamed(
            context, widget.seenOnboarding ? '/home' : '/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq       = MediaQuery.of(context);
    final sw       = mq.size.width;
    final sh       = mq.size.height;
    final isSmall  = sh < 600;
    final isTablet = sw >= 600;

    final logoSize   = (sw * 0.30).clamp(100.0, 170.0);
    final logoRadius = logoSize * 0.22;
    final titleFont  = isTablet ? 30.0 : (isSmall ? 22.0 : 26.0);
    final subFont    = isTablet ? 16.0 : (isSmall ? 12.0 : 14.0);
    final gapLg      = sh * 0.04;
    final gapSm      = sh * 0.015;
    final spinnerSz  = (sw * 0.08).clamp(28.0, 44.0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_bgDark, _bgMid, _bgLight],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── شعار التطبيق ──────────────────────────
                    Container(
                      width: logoSize,
                      height: logoSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(logoRadius),
                        color: const Color(0xFFFFF8F0),
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withOpacity(0.45),
                            blurRadius: 28,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(logoRadius),
                        child: Image.asset(
                          'assets/images/logo_app.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.content_cut_rounded,
                            size: logoSize * 0.5,
                            color: _primary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: gapLg),

                    // ── اسم التطبيق ──────────────────────────
                    Text(
                      'باترون وإشارة',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: titleFont,
                        fontWeight: FontWeight.bold,
                        color: Colors.orangeAccent,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: gapSm),

                    // ── الوصف المختصر ─────────────────────────
                    Text(
                      'تعلّمي الخياطة بلغة الإشارة',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: subFont,
                        color: _accent.withOpacity(0.85),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
