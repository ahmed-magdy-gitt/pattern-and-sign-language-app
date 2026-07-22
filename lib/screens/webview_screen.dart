import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'no_internet_screen.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  bool _hasError = false;
  bool _hasInternet = true;
  double _loadingProgress = 0;
  StreamSubscription? _connectivitySubscription;

  final String _homeUrl = 'https://clothesa.site';
  final CookieManager _cookieManager = CookieManager.instance();

  // ── ألوان التطبيق ────────────────────────────────────────────
  static const _primary   = Color(0xFFE89A3E);
  static const _bgDark    = Color(0xFF3D2B1F);
  static const _textLight = Color(0xFFE8C9B0);

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final hasConnection = results.isNotEmpty &&
          !results.contains(ConnectivityResult.none);
      setState(() => _hasInternet = hasConnection);
      if (hasConnection && _hasError) _webViewController?.reload();
    });
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      _hasInternet = result != ConnectivityResult.none;
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_webViewController != null) {
      final canGoBack = await _webViewController!.canGoBack();
      if (canGoBack) {
        await _webViewController!.goBack();
        return false;
      }
    }
    return _showExitDialog();
  }

  Future<bool> _showExitDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF3D2B1F),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: const Text(
              'الخروج من التطبيق',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
              textDirection: TextDirection.rtl,
            ),
            content: const Text(
              'هل أنت متأكدة أنك تريدين الخروج؟',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFE8C9B0)),
              textDirection: TextDirection.rtl,
            ),
            actions: [
              Row(children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('إلغاء',
                        style: TextStyle(color: Color(0xFFE89A3E))),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      SystemNavigator.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE89A3E),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('خروج',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ]),
            ],
          ),
        ) ??
        false;
  }

  // ── حوار حذف الحساب ──────────────────────────────────────────
  Future<void> _showDeleteAccountDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF3D2B1F),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'حذف الحساب',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'سيتم حذف حسابك وجميع بياناتك بشكل نهائي.\n\nهل أنتِ متأكدة؟',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: TextStyle(color: Color(0xFFE8C9B0), height: 1.6),
        ),
        actions: [
          Row(children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('إلغاء',
                    style: TextStyle(color: Color(0xFFE89A3E))),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('حذف الحساب',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ]),
        ],
      ),
    );

    if (confirmed == true) {
      // يفتح صفحة حذف الحساب على الموقع
      final url = Uri.parse('https://clothesa.site/حذف-الحساب/');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // أو يفتحها داخل WebView
        _webViewController?.loadUrl(
          urlRequest: URLRequest(
              url: WebUri('https://clothesa.site/حذف-الحساب/')),
        );
      }
    }
  }

  Future<void> _persistLoginCookies() async {
    try {
      final cookies =
          await _cookieManager.getCookies(url: WebUri(_homeUrl));
      for (final cookie in cookies) {
        final name = cookie.name.toLowerCase();
        final isLogin = name.startsWith('wordpress') ||
            name.startsWith('wp-') ||
            name.contains('logged') ||
            name == 'phpsessid';
        if (isLogin) {
          await _cookieManager.setCookie(
            url: WebUri(_homeUrl),
            name: cookie.name,
            value: cookie.value,
            domain: cookie.domain ?? 'clothesa.site',
            path: cookie.path ?? '/',
            expiresDate: DateTime.now()
                .add(const Duration(days: 365))
                .millisecondsSinceEpoch,
            isSecure: true,
            isHttpOnly: true,
          );
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasInternet) {
      return NoInternetScreen(onRetry: () {
        _checkConnectivity();
        _webViewController?.reload();
      });
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) await _onWillPop();
      },
      child: Scaffold(
        backgroundColor: _bgDark,
        // ── AppBar مع زر القائمة ───────────────────────────
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: AppBar(backgroundColor: Colors.transparent),
        ),
        // ── زر القائمة العائم (⋮) ─────────────────────────

        body: Stack(children: [
          // ══ WebView ════════════════════════════════════════
          SafeArea(
            top: false,
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(_homeUrl)),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                domStorageEnabled: true,
                databaseEnabled: true,
                cacheEnabled: true,
                cacheMode: CacheMode.LOAD_DEFAULT,
                thirdPartyCookiesEnabled: true,
                saveFormData: true,
                useWideViewPort: true,
                loadWithOverviewMode: true,
                supportZoom: true,
                builtInZoomControls: false,
                displayZoomControls: false,
                allowsInlineMediaPlayback: true,
                mediaPlaybackRequiresUserGesture: false,
                allowFileAccessFromFileURLs: true,
                allowUniversalAccessFromFileURLs: true,
                transparentBackground: false,
                verticalScrollBarEnabled: false,
                horizontalScrollBarEnabled: false,
                userAgent:
                    'Mozilla/5.0 (Linux; Android 13; Pixel 7) '
                    'AppleWebKit/537.36 (KHTML, like Gecko) '
                    'Chrome/120.0.6099.210 Mobile Safari/537.36',
              ),
              onWebViewCreated: (c) => _webViewController = c,
              onLoadStart: (c, url) => setState(() {
                _isLoading = true;
                _hasError = false;
              }),
              onProgressChanged: (c, progress) => setState(() {
                _loadingProgress = progress / 100.0;
                if (progress == 100) _isLoading = false;
              }),
              onLoadStop: (c, url) async {
                setState(() => _isLoading = false);
                await _persistLoginCookies();
              },
              onReceivedError: (c, request, error) => setState(() {
                _isLoading = false;
                _hasError = true;
              }),
              shouldOverrideUrlLoading: (c, action) async =>
                  NavigationActionPolicy.ALLOW,
            ),
          ),

          // ══ شريط التحميل ══════════════════════════════════
          if (_isLoading)
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: _loadingProgress > 0 ? _loadingProgress : null,
                backgroundColor: Colors.transparent,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(_primary),
                minHeight: 3,
              ),
            ),

          // ══ شاشة التحميل الأولية ══════════════════════════
          if (_isLoading && _loadingProgress < 0.1)
            Container(
              color: _bgDark,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                        color: _primary, strokeWidth: 3),
                    const SizedBox(height: 20),
                    Text('جارٍ التحميل...',
                        style: TextStyle(
                            color: _textLight, fontSize: 16),
                        textDirection: TextDirection.rtl),
                  ],
                ),
              ),
            ),

          // ══ شاشة الخطأ ════════════════════════════════════
          if (_hasError)
            Container(
              color: _bgDark,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 80, color: _primary),
                      const SizedBox(height: 20),
                      const Text('حدث خطأ في التحميل',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                          textDirection: TextDirection.rtl),
                      const SizedBox(height: 10),
                      Text('تحقق من اتصالك بالإنترنت وحاول مرة أخرى',
                          style: TextStyle(color: _textLight),
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() => _hasError = false);
                          _webViewController?.reload();
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('إعادة المحاولة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }

  // ── القائمة العائمة (⋮) ───────────────────────────────────────
  void _showAppMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF3D2B1F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // مقبض
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2)),
              ),

              // الصفحة الرئيسية
              _MenuItem(
                icon: Icons.home_rounded,
                label: 'الصفحة الرئيسية',
                color: _primary,
                onTap: () {
                  Navigator.pop(context);
                  _webViewController?.loadUrl(
                    urlRequest:
                        URLRequest(url: WebUri(_homeUrl)),
                  );
                },
              ),

              // إعادة تحميل
              _MenuItem(
                icon: Icons.refresh_rounded,
                label: 'إعادة التحميل',
                color: _primary,
                onTap: () {
                  Navigator.pop(context);
                  _webViewController?.reload();
                },
              ),

              // سياسة الخصوصية
              _MenuItem(
                icon: Icons.privacy_tip_rounded,
                label: 'سياسة الخصوصية',
                color: _primary,
                onTap: () async {
                  Navigator.pop(context);
                  final url = Uri.parse(
                      'https://clothesa.site/privacy-policy/');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url,
                        mode: LaunchMode.externalApplication);
                  }
                },
              ),

              const Divider(color: Colors.white12, height: 1),

              // ✅ حذف الحساب — مطلوب من Apple
              _MenuItem(
                icon: Icons.delete_forever_rounded,
                label: 'حذف الحساب',
                color: Colors.red.shade400,
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteAccountDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── عنصر القائمة ─────────────────────────────────────────────
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        textDirection: TextDirection.rtl,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
