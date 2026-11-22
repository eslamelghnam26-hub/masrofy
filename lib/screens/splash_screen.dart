import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// شاشة البداية (Splash): شعار التطبيق واسمه في منتصف خلفية فاتحة ناعمة،
/// ثم تنتقل تلقائياً إلى الشاشة التالية (تسجيل الدخول أو الشاشة الرئيسية).
class SplashScreen extends StatefulWidget {
  final Widget next;

  const SplashScreen({super.key, required this.next});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _delay = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    Future.delayed(_delay, _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => widget.next),
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    final iconSize = (h * 0.079).clamp(112.0, 126.0);
    final nameSize = (h * 0.026).clamp(34.0, 44.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            const _SplashBackground(),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/icon/app_icon_splash.png',
                    width: iconSize,
                    height: iconSize,
                    filterQuality: FilterQuality.high,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'مصروفي',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: nameSize,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF24232A),
                      height: 1.05,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// خلفية شاشة البداية: تدرج فاتح من الأبيض الدافئ إلى الرمادي الباهت،
/// مع حلقات دائرية خفيفة في الأركان.
class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8F7F3), Color(0xFFEFEEF2), Color(0xFFE3E2E9)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // حلقة رمادية-خضراء كبيرة تخرج خلف الركن الأعلى الأيمن.
          Positioned(
            top: -h * 0.12,
            right: -h * 0.16,
            child: _Ring(
              size: h * 0.46,
              color: const Color(0xFFA8B6A4),
              opacity: 0.28,
            ),
          ),
          // دائرة جزئية خفيفة على الحافة اليسرى.
          Positioned(
            top: h * 0.24,
            left: -h * 0.20,
            child: _Ring(
              size: h * 0.30,
              color: const Color(0xFFB9C2B4),
              opacity: 0.16,
            ),
          ),
          // حلقة رمادية-بنفسجية كبيرة تخرج خلف الركن الأسفل الأيسر.
          Positioned(
            bottom: -h * 0.14,
            left: -h * 0.18,
            child: _Ring(
              size: h * 0.52,
              color: const Color(0xFFB4B1C6),
              opacity: 0.26,
            ),
          ),
        ],
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _Ring({
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: opacity),
          width: size * 0.11,
        ),
      ),
    );
  }
}
