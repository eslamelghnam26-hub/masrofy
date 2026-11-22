import 'package:flutter/material.dart';

/// خلفية بريميوم فاتحة للشاشات الرئيسية: تدرج رمادي/أبيض دافئ،
/// إضاءة زمردية خافتة، وأشكال عضوية شفافة في الزوايا مع عمق ناعم.
/// تُرسم الخلفية الفاتحة فقط؛ في الوضع الداكن تبقى الخلفية عادية.
class PremiumBackground extends StatelessWidget {
  final Widget child;

  const PremiumBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) return child;

    const forest = Color(0xFF39594F);
    const sage = Color(0xFFA4B69D);
    const warmOffWhite = Color(0xFFF8F6F1);
    const lightGray = Color(0xFFE8E8EC);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [warmOffWhite, lightGray, const Color(0xFFE3E3E8)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // إضاءة زمردية خافتة أعلى اليسار.
          Positioned(
            top: -140,
            left: -120,
            child: _SoftGlow(color: sage.withValues(alpha: 0.30), size: 320),
          ),
          // إضاءة زمردية خافتة أسفل اليمين.
          Positioned(
            bottom: -160,
            right: -110,
            child:
                _SoftGlow(color: forest.withValues(alpha: 0.16), size: 360),
          ),
          // أشكال عضوية مفرّغة (حلقات) في الزوايا بكتمة عالية.
          Positioned(
            top: -70,
            right: -50,
            child: _OrganicRing(color: sage.withValues(alpha: 0.22), size: 190),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child:
                _OrganicRing(color: forest.withValues(alpha: 0.10), size: 230),
          ),
          // نقطة ناعمة خفيفة على الجانب الأيسر.
          Positioned(
            top: 90,
            left: -90,
            child: _OrganicDot(color: sage.withValues(alpha: 0.14), size: 120),
          ),
          child,
        ],
      ),
    );
  }
}

/// هالة متدرجة ناعمة (إضاءة محيطية).
class _SoftGlow extends StatelessWidget {
  final Color color;
  final double size;

  const _SoftGlow({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

/// حلقة عضوية مفرّغة تعطي عمقاً ناعماً دون تشويش.
class _OrganicRing extends StatelessWidget {
  final Color color;
  final double size;

  const _OrganicRing({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: size * 0.10),
      ),
    );
  }
}

class _OrganicDot extends StatelessWidget {
  final Color color;
  final double size;

  const _OrganicDot({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}