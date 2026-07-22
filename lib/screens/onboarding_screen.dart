import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {

  static const _bg1      = Color(0xFFF6F3EE);
  static const _bg2      = Color(0xFFEDE6DE);
  static const _cardBg   = Color(0xFFFDF9F4);
  static const _accent   = Color(0xFFE89A3E);
  static const _textDark = Color(0xFF2F3242);
  static const _textMuted= Color(0xFF70778A);

  final PageController _pageController = PageController();
  int _currentIndex = 0;

  late final AnimationController _animController;
  late final Animation<double>   _fadeAnimation;
  late final Animation<Offset>   _slideAnimation;

  final List<_PageData> _pages = [
    _PageData(
      title: 'أهلًا بك في عالم الإبداع! 👋',
      body: 'جاهزة لدرس اليوم؟ لنصنع شيئًا مميزًا معًا.',
      icon: Icons.auto_fix_high_rounded,
      isIntroPage: false,
    ),
    _PageData(
      title: '',
      body: 'انطلاقًا من أهمية تعزيز الشمولية وإتاحة المعرفة لجميع فئات المجتمع، جاءت هذه الدراسة بعنوان:\n\n'
          '"فعالية تطبيق ذكي للتدريب على إعداد النماذج وتنفيذ ملابس الأطفال لتنمية مهارات الفتيات الصم"\n\n'
          'يهدف هذا التطبيق إلى تقديم محتوى تعليمي متخصص يدمج بين مجال تصميم الأزياء وتقنيات التعليم الرقمي، من خلال توفير بيئة تعلم ذاتي تتيح للمستخدم التعلم دون الحاجة إلى مدرب، وذلك عبر عرض نماذج ملابس الأطفال وشرح خطوات تنفيذها بطريقة مبسطة وتفاعلية.\n\n'
          'ويحتوي التطبيق على جلسات تعليمية نظرية وعملية تسهم في تنمية المهارات المعرفية والتطبيقية لدى الفئة المستهدفة، حيث يتم تقديم المحتوى التطبيقي من خلال مقاطع فيديو مترجمة إلى لغة الإشارة، بما يدعم فئة الصم ويسهم في تمكينهن من التعرف على أنواع ملابس الأطفال وفهم آلية تصميمها وتنفيذها.',
      icon: Icons.school_rounded,
      isIntroPage: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
        parent: _animController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (mounted) Navigator.pushReplacementNamed(context, '/home');
  }

  void _nextPage() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size         = MediaQuery.of(context).size;
    final isSmall      = size.height < 650 || size.width < 360;
    final isTablet     = size.width >= 600;
    final hPad         = size.width  * (isTablet ? 0.12 : 0.07);
    final topSpacing   = size.height * (isSmall  ? 0.05 : 0.08);
    final cardVPad     = size.height * (isSmall  ? 0.035 : 0.05);
    final cardRadius   = size.width  * (isTablet ? 0.055 : 0.075);
    final titleFs      = isTablet ? 27.0 : isSmall ? 19.5 : 22.5;
    final bodyFs       = isTablet ? 16.5 : isSmall ? 13.8 : 15.0;
    final iconSize     = (size.width * (isTablet ? 0.17 : 0.21)).clamp(70.0, 105.0);
    final btnHeight    = (size.height * 0.072).clamp(56.0, 70.0);
    final isLastPage   = _currentIndex == _pages.length - 1;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bg1, _bg2],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  SizedBox(height: topSpacing),

                  // ── PageView ────────────────────────────────
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pages.length,
                      onPageChanged: (i) =>
                          setState(() => _currentIndex = i),
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (_, i) => _OnboardCard(
                        data: _pages[i],
                        cardRadius: cardRadius,
                        titleFontSize: titleFs,
                        bodyFontSize: bodyFs,
                        iconSize: iconSize,
                        verticalPadding: cardVPad,
                      ),
                    ),
                  ),

                  // ── نقاط + سياسة الخصوصية + زر ────────────
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        hPad, 18, hPad, topSpacing * 0.7),
                    child: Column(
                      children: [
                        _Dots(
                            count: _pages.length,
                            currentIndex: _currentIndex),
                        const SizedBox(height: 16),

                        // ✅ سياسة الخصوصية — تظهر فقط في الصفحة الأخيرة
                        if (isLastPage)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: RichText(
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: bodyFs - 1.5,
                                  color: _textMuted,
                                  height: 1.5,
                                ),
                                children: [
                                  const TextSpan(
                                      text: 'بالمتابعة فإنك توافقين على '),
                                  TextSpan(
                                    text: 'سياسة الخصوصية',
                                    style: const TextStyle(
                                      color: _accent,
                                      decoration: TextDecoration.underline,
                                      decorationColor: _accent,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        final url = Uri.parse(
                                            'https://clothesa.site/privacy-policy/');
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url,
                                              mode: LaunchMode
                                                  .externalApplication);
                                        }
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // ── زر التالي / ابدئي ──────────────────
                        SizedBox(
                          width: double.infinity,
                          height: btnHeight,
                          child: ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accent,
                              foregroundColor: Colors.white,
                              elevation: 6,
                              shadowColor: _accent.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isLastPage ? 'ابدئي الآن' : 'التالي',
                                  style: TextStyle(
                                    fontSize: bodyFs + 1,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                                const SizedBox(width: 14),
                                Icon(
                                  isLastPage
                                      ? Icons.check_rounded
                                      : Icons.arrow_forward_ios_rounded,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

// ── بطاقة كل صفحة ───────────────────────────────────────────
class _OnboardCard extends StatelessWidget {
  final _PageData data;
  final double cardRadius, titleFontSize, bodyFontSize,
      iconSize, verticalPadding;

  const _OnboardCard({
    required this.data,
    required this.cardRadius,
    required this.titleFontSize,
    required this.bodyFontSize,
    required this.iconSize,
    required this.verticalPadding,
  });

  @override
  Widget build(BuildContext context) {
    final hPad = MediaQuery.of(context).size.width * 0.06;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: 26, vertical: verticalPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(cardRadius),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFDF9F4), Color(0xFFF2E7DB)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            if (!data.isIntroPage) ...[
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [
                    const Color(0xFFE89A3E).withOpacity(0.96),
                    const Color(0xFFE89A3E).withOpacity(0.78),
                  ]),
                ),
                child: Icon(data.icon,
                    size: iconSize * 0.46, color: Colors.white),
              ),
              SizedBox(height: iconSize * 0.25),
            ],
            if (data.title.isNotEmpty)
              Text(
                data.title,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2F3242),
                  height: 1.25,
                ),
              ),
            if (data.title.isNotEmpty) const SizedBox(height: 18),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  data.body,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: bodyFontSize,
                    color: const Color(0xFF70778A),
                    height: data.isIntroPage ? 1.9 : 1.75,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── نقاط التنقل ─────────────────────────────────────────────
class _Dots extends StatelessWidget {
  final int count, currentIndex;
  const _Dots({required this.count, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: active ? 30 : 9.5,
          height: 9.5,
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFFE89A3E)
                : const Color(0xFFE89A3E).withOpacity(0.35),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }
}

// ── بيانات الصفحة ────────────────────────────────────────────
class _PageData {
  final String title, body;
  final IconData icon;
  final bool isIntroPage;
  const _PageData({
    required this.title,
    required this.body,
    required this.icon,
    this.isIntroPage = false,
  });
}