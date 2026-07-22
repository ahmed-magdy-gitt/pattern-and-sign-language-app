import 'package:flutter/material.dart';

class NoInternetScreen extends StatelessWidget {
  final VoidCallback onRetry;
  const NoInternetScreen({super.key, required this.onRetry});

  // ── ألوان Clothesa ──────────────────────────────────────────
  static const _bgDark = Color(0xFFF6F3EE);
  static const _bgMid = Color(0xFFEDE6DE);
  static const _bgLight = Color(0xFFFDF9F4);

  static const _primary = Color(0xFFE89A3E);
  static const _accent = Color(0xFF2F3242);
  static const _accentSoft = Color(0xFF70778A);


  @override
  Widget build(BuildContext context) {
    final mq       = MediaQuery.of(context);
    final sw       = mq.size.width;
    final sh       = mq.size.height;
    final isSmall  = sh < 600;
    final isTablet = sw >= 600;

    final iconContainerSize = (sw * 0.35).clamp(110.0, 170.0);
    final iconSize          = iconContainerSize * 0.52;
    final titleFont         = isTablet ? 26.0 : (isSmall ? 18.0 : 22.0);
    final bodyFont          = isTablet ? 18.0 : (isSmall ? 13.0 : 15.0);
    final btnHeight         = (sh * 0.07).clamp(48.0, 64.0);
    final hPad              = sw * 0.08;
    final gapLg             = sh * 0.04;
    final gapSm             = sh * 0.02;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_bgDark, _bgMid, _bgLight],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── أيقونة wifi مع نبضة ─────────────────────
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.85, end: 1.0),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeInOut,
                    builder: (ctx, v, _) => Transform.scale(
                      scale: v,
                      child: Container(
                        width: iconContainerSize,
                        height: iconContainerSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _primary.withOpacity(0.15),
                          border: Border.all(
                            color: _primary.withOpacity(0.35),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.wifi_off_rounded,
                          size: iconSize,
                          color: _primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: gapLg),

                  // ── العنوان ──────────────────────────────────
                  Text(
                    'لا يوجد اتصال بالإنترنت',
                    style: TextStyle(
                      fontSize: titleFont,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: gapSm),

                  // ── الوصف ────────────────────────────────────
                  Text(
                    'يبدو أنكِ غير متصلة بالإنترنت.\nتحققي من إعدادات الشبكة وحاولي مرة أخرى.',
                    style: TextStyle(
                      fontSize: bodyFont,
                      color: _accent.withOpacity(0.8),
                      height: 1.65,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: gapLg * 1.4),

                  // ── زر إعادة المحاولة ─────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: btnHeight,
                    child: ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: Icon(Icons.refresh_rounded,
                          size: isSmall ? 20 : 24),
                      label: Text(
                        'إعادة المحاولة',
                        style: TextStyle(
                          fontSize: isTablet ? 18.0 : (isSmall ? 14.0 : 16.0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 6,
                        shadowColor: _primary.withOpacity(0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
