import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// شريط أرقام مشترك بين شاشة القفل وإعدادات الرقم السري.
/// يتكيّف مع عرض الشاشة حتى لا يفيض على الأجهزة الصغيرة.
class PinPad extends StatelessWidget {
  final int length;
  final String value;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final MasrofyPalette palette;

  const PinPad({
    super.key,
    required this.length,
    required this.value,
    required this.onDigit,
    required this.onBackspace,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final keys = <String>['1', '2', '3', '4', '5', '6', '7', '8', '9'];
    final keySize =
        (MediaQuery.sizeOf(context).width / 4.2).clamp(46.0, 62.0).toDouble();
    final gap = keySize >= 58 ? 7.0 : 4.0;
    final dotGap = gap / 2;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(length, (i) {
            final filled = i < value.length;
            return Container(
              margin: EdgeInsets.symmetric(horizontal: dotGap),
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? p.accent : Colors.transparent,
                border: Border.all(
                  color: filled ? p.accent : p.textMuted,
                  width: 1.6,
                ),
              ),
            );
          }),
        ),
        SizedBox(height: keySize >= 58 ? 18 : 12),
        for (var row = 0; row < 3; row++)
          Padding(
            padding: EdgeInsets.only(bottom: gap + 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var col = 0; col < 3; col++)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: gap),
                    child: _KeyButton(
                      label: keys[row * 3 + col],
                      palette: p,
                      size: keySize,
                      onTap: () => onDigit(keys[row * 3 + col]),
                    ),
                  ),
              ],
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: gap),
              child: _KeyButton(
                label: '',
                icon: Icons.backspace_outlined,
                palette: p,
                size: keySize,
                onTap: onBackspace,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: gap),
              child: _KeyButton(
                label: '0',
                palette: p,
                size: keySize,
                onTap: () => onDigit('0'),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: gap),
              child: SizedBox(width: keySize, height: keySize),
            ),
          ],
        ),
      ],
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final MasrofyPalette palette;
  final double size;
  final VoidCallback onTap;

  const _KeyButton({
    required this.label,
    this.icon,
    required this.palette,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: p.card,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: icon != null
                ? Icon(icon, size: size * 0.34, color: p.textSecondary)
                : FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          color: p.textPrimary),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
