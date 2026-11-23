import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/strings.dart';
import '../store/masrofy_store.dart';
import '../theme/app_theme.dart';
import '../widgets/pin_pad.dart';

/// شاشة قفل محلية تُعرض قبل أي واجهة أخرى عند تفعيل PIN.
class PinScreen extends StatefulWidget {
  final MasrofyStore store;
  final VoidCallback onSuccess;

  const PinScreen({
    super.key,
    required this.store,
    required this.onSuccess,
  });

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _pin = '';
  String? _error;

  void _onDigit(String digit) {
    if (_pin.length >= 4) return;
    setState(() {
      _pin += digit;
      _error = null;
    });
    if (_pin.length == 4) _verify();
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _error = null;
    });
  }

  Future<void> _verify() async {
    final ok = widget.store.verifyPin(_pin);
    if (!mounted) return;
    if (ok) {
      HapticFeedback.mediumImpact();
      widget.onSuccess();
      return;
    }
    HapticFeedback.heavyImpact();
    setState(() {
      _error = Strings(widget.store.language).pinWrong;
      _pin = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = Strings(widget.store.language);

    return Scaffold(
      backgroundColor: p.bg,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              p.bg.computeLuminance() > 0.5 ? Brightness.dark : Brightness.light,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: p.accent.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lock_outline, size: 32, color: p.accent),
                  ),
                  const SizedBox(height: 18),
                  Text(s.pinEntryTitle,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: p.textPrimary)),
                  const SizedBox(height: 6),
                  Text(s.pinEntrySubtitle,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 12.5, color: p.textSecondary)),
                  const SizedBox(height: 28),
                  PinPad(
                    length: 4,
                    value: _pin,
                    palette: p,
                    onDigit: _onDigit,
                    onBackspace: _onBackspace,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 20,
                    child: Text(
                      _error ?? '',
                      style: TextStyle(fontSize: 12, color: p.expense),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    s.pinPrivacyNote,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10.5, color: p.textMuted),
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
