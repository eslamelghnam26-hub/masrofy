import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/strings.dart';
import '../store/masrofy_store.dart';
import '../theme/app_theme.dart';
import 'welcome_screen.dart';

class OtpScreen extends StatefulWidget {
  final MasrofyStore store;
  final String phone;

  const OtpScreen({super.key, required this.store, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focuses = List.generate(4, (_) => FocusNode());
  bool _verifying = false;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focuses) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isEmpty) return;
    if (index < 3) {
      _focuses[index + 1].requestFocus();
    } else {
      _focuses[index].unfocus();
    }
  }

  String get _entered =>
      _controllers.map((c) => c.text.trim()).join();

  Future<void> _verify() async {
    final s = Strings(widget.store.language);
    if (_entered.length != 4) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.otpWrong)));
      return;
    }
    setState(() => _verifying = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    if (_entered == '1234') {
      await widget.store.setLoggedIn(true);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => WelcomeScreen(store: widget.store),
          transitionsBuilder: (_, animation, _, child) => FadeTransition(
              opacity: animation, child: child),
        ),
      );
    } else {
      setState(() => _verifying = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.otpWrong)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = Strings(widget.store.language);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: p.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Icon(Icons.sms_outlined,
                  size: 56, color: p.accent.withValues(alpha: 0.9)),
              const SizedBox(height: 18),
              Text(
                s.otpTitle,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: p.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                s.otpSubtitle,
                style: TextStyle(fontSize: 14, color: p.textSecondary),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: p.accentSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+20 ${widget.phone}',
                  style: TextStyle(fontSize: 13, color: p.accent),
                ),
              ),
              const SizedBox(height: 34),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (i) {
                  return SizedBox(
                    width: 68,
                    height: 76,
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focuses[i],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      onChanged: (v) {
                        _onChanged(i, v);
                        if (v.isNotEmpty && i == 3) _verify();
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: p.textPrimary),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: p.bgElevated,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: p.cardBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                              color: p.accent, width: 1.6),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  s.otpHint,
                  style: TextStyle(fontSize: 12, color: p.textMuted),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _verifying ? null : _verify,
                  child: _verifying
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(s.continueLabel,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}