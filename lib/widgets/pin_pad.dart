import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// شريط أرقام مشترك بين شاشة القفل وإعدادات الرقم السري.
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

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(length, (i) {
            final filled = i < value.length;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 7),
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
        const SizedBox(height: 18),
        for (var row = 0; row < 3; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var col = 0; col < 3; col++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    child: _KeyButton(
                      label: keys[row * 3 + col],
                      palette: p,
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
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: _KeyButton(
                label: '',
                icon: Icons.backspace_outlined,
                palette: p,
                onTap: onBackspace,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: _KeyButton(
                label: '0',
                palette: p,
                onTap: () => onDigit('0'),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 7),
              child: SizedBox(width: 62, height: 62),
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
  final VoidCallback onTap;

  const _KeyButton({
    required this.label,
    this.icon,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return SizedBox(
      width: 62,
      height: 62,
      child: Material(
        color: p.card,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: icon != null
                ? Icon(icon, size: 21, color: p.textSecondary)
                : Text(label,
                    style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: p.textPrimary)),
          ),
        ),
      ),
    );
  }
}
