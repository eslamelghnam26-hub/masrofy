import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../formatters/digit_formatter.dart';
import '../l10n/strings.dart';
import '../services/auth_service.dart';
import '../store/masrofy_store.dart';
import '../theme/app_theme.dart';
import 'welcome_screen.dart';

class OtpScreen extends StatefulWidget {
  final MasrofyStore store;
  final String phone;
  final String verificationId;

  const OtpScreen({
    super.key,
    required this.store,
    required this.phone,
    this.verificationId = '',
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
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
    // تركيز تلقائي على أول خانة (يسار) لبدء الإدخال فوراً.
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
    // شاشة كود التفعيل بخلفية رصاصي فاتح دائماً مهما كان الثيم الحالي.
    const p = MasrofyPalette.light;
    final s = Strings(widget.store.language);
    final boxWidth = (MediaQuery.of(context).size.width - 52 - 10 * (_digitCount - 1)) / _digitCount;
    return Scaffold(
      backgroundColor: LightColors.bg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: p.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Icon(Icons.sms_outlined, size: 56, color: p.accent.withValues(alpha: 0.9)),
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
                  widget.phone,
                  style: TextStyle(fontSize: 13, color: p.accent),
                ),
              ),
              const SizedBox(height: 34),
              // صناديق الكود ثابتة الاتجاه (يسار -> يمين) مهما كان لغة الواجهة،
              // حتى يتطابق ترتيب الإدخال مع ترتيب join() وترتيب كود SMS.
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_digitCount, (i) {
                    return SizedBox(
                      width: boxWidth,
                      height: 76,
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
                            borderSide:
                                BorderSide(color: p.accent, width: 1.6),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  _isReal ? s.otpRealHint : s.otpHint,
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