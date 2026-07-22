// أضيفي هذا Widget في أسفل onboarding_screen.dart
// قبل زر "ابدئي التعلم الآن" مباشرة

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyText extends StatelessWidget {
  const PrivacyPolicyText({super.key});

  @override
  Widget build(BuildContext context) {
    final fontSize = MediaQuery.of(context).size.width >= 600 ? 13.0 : 11.5;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        text: TextSpan(
          style: TextStyle(
            fontSize: fontSize,
            color: const Color(0xFF70778A),
            height: 1.6,
          ),
          children: [
            const TextSpan(text: 'بالمتابعة فإنك توافقين على '),
            TextSpan(
              text: 'سياسة الخصوصية',
              style: const TextStyle(
                color: Color(0xFFE89A3E),
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFFE89A3E),
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  final url = Uri.parse(
                      'https://clothesa.site/privacy-policy/');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url,
                        mode: LaunchMode.externalApplication);
                  }
                },
            ),
            const TextSpan(text: ' الخاصة بالتطبيق'),
          ],
        ),
      ),
    );
  }
}
