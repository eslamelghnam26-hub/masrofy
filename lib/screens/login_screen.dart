import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/strings.dart';
import '../services/auth_service.dart';
import '../store/masrofy_store.dart';
import '../theme/app_theme.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  final MasrofyStore store;

  const LoginScreen({super.key, required this.store});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _phoneFocus = FocusNode();
  bool _submitting = false;
  bool _showDemoNotice = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final s = Strings(widget.store.language);
    final digits = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 11 || !digits.startsWith('01')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(s.phoneInvalid)));
      }
      return;
    }
    setState(() => _submitting = true);
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 400));

    final auth = AuthService.instance;
    final result = await auth.sendCode('+20$digits');
    if (!mounted) return;

    setState(() => _submitting = false);

    if (result.isFailed) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.otpSendFailed)));
      return;
    }
    if (result.isDemo) {
      setState(() => _showDemoNotice = true);
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpScreen(
          store: widget.store,
          phone: digits,
          verificationId: result.verificationId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = Strings(widget.store.language);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: 'app_logo',
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        colors: [p.accent, const Color(0xFF4C67F5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: p.accent.withValues(alpha: 0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Icon(Icons.account_balance_wallet_outlined,
                        color: Colors.white, size: 46),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  s.appName,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: p.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  s.loginTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: p.textSecondary),
                ),
                const SizedBox(height: 36),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: p.bgElevated,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: p.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Text('+20',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: p.textPrimary)),
                      Container(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        width: 1,
                        height: 24,
                        color: p.cardBorder,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          focusNode: _phoneFocus,
                          keyboardType: TextInputType.phone,
                          maxLength: 11,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _continue(),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                          ],
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: p.textPrimary),
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: s.phoneHint,
                            hintStyle:
                                TextStyle(fontSize: 15, color: p.textMuted),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_showDemoNotice) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: p.accentSoft,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: p.accent.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: p.accent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            s.demoModeNotice,
                            style: TextStyle(fontSize: 12, color: p.accent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _continue,
                    child: _submitting
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
      ),
    );
  }
}