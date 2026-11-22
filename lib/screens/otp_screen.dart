import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../formatters/digit_formatter.dart';
import '../l10n/strings.dart';
import '../services/auth_service.dart';
import '../store/masrofy_store.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_background.dart';
import 'welcome_screen.dart';

class OtpScreen extends StatefulWidget {
  final MasrofyStore store;
  final String phone;
  final String phoneNumber;
  final String verificationId;

  const OtpScreen({
    super.key,
    required this.store,
    required this.phone,
    this.phoneNumber = '',
    this.verificationId = '',
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const _accent = LightColors.accent;
  static const _textPrimary = LightColors.textPrimary;

  late final int _digitCount;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focuses;
  bool _verifying = false;

  bool get _isReal => widget.verificationId.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _digitCount = _isReal ? 6 : 4;
    _controllers = List.generate(_digitCount, (_) => TextEditingController());
    _focuses = List.generate(_digitCount, (_) => FocusNode());
    // تركيز تلقائي على أول خانة لبدء الإدخال فوراً.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _focuses.isNotEmpty) {
        _focuses.first.requestFocus();
      }
    });
  }

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
    if (index < _digitCount - 1) {
      _focuses[index + 1].requestFocus();
    } else {
      _focuses[index].unfocus();
      _verify();
    }
  }

  /// يجمع الأرقام كما تظهر بصرياً (يسار -> يمين) بغض النظر عن اتجاه الواجهة،
  /// ويحوّل الأرقام العربية إلى ASCII قبل المقارنة.
  String get _entered =>
      normalizeDigits(_controllers.map((c) => c.text).join());

  Future<void> _resend() async {
    final s = Strings(widget.store.language);
    if (!_isReal) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.otpHint)));
      return;
    }
    if (widget.phoneNumber.isEmpty) return;
    final result = await AuthService.instance.sendCode(widget.phoneNumber);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.isFailed ? s.otpSendFailed : s.otpResent)));
  }

  Future<void> _verify() async {
    final s = Strings(widget.store.language);
    final code = _entered;
    if (code.length != _digitCount) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(s.otpIncomplete)));
      }
      return;
    }
    setState(() => _verifying = true);
    final delayed = Future.delayed(const Duration(milliseconds: 700));
    final ok = await AuthService.instance.verifyCode(widget.verificationId, code);
    await delayed;
    if (!mounted) return;
    if (ok) {
      final uid = AuthService.instance.currentUid;
      if (uid != null) {
        await widget.store.attachUser(uid);
      }
      await widget.store.setLoggedIn(true);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => WelcomeScreen(store: widget.store),
          transitionsBuilder: (_, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
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
    final s = Strings(widget.store.language);
    final subtitle = _isReal ? s.otpSubtitle6 : s.otpSubtitle4;
    final boxSize = 52.0;
    final gap = 14.0;
    // شاشة كود التفعيل بخلفية رصاصي فاتح دائماً مهما كان الثيم الحالي.
    return Scaffold(
      backgroundColor: LightColors.bg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PremiumBackground(
        child: SafeArea(
          child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Text(
                s.otpTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
              ),
              const SizedBox(height: 40),
              // صناديق الكود ثابتة الاتجاه (يسار -> يمين) مهما كان لغة الواجهة،
              // حتى يتطابق ترتيب الإدخال مع ترتيب join() وترتيب كود SMS.
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_digitCount, (i) {
                    return Padding(
                      padding: EdgeInsets.only(
                          left: i == 0 ? 0 : gap),
                      child: SizedBox(
                        width: boxSize,
                        height: 56,
                        child: TextField(
                          controller: _controllers[i],
                          focusNode: _focuses[i],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          onChanged: (v) => _onChanged(i, v),
                          inputFormatters: [
                            DigitInputFormatter(),
                            LengthLimitingTextInputFormatter(1),
                          ],
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: _accent, width: 1.4),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _isReal ? s.otpRealHint : s.otpHint,
                style:
                    const TextStyle(fontSize: 12, color: Color(0xFF8A8A94)),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: 320,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _verifying ? null : _verify,
                  child: _verifying
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(
                          s.continueLabel,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: _verifying ? null : _resend,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    s.resendCode,
                    style: const TextStyle(
                        fontSize: 16, color: Color(0xFF666666)),
                  ),
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