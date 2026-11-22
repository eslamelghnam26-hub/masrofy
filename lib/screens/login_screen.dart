import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../formatters/digit_formatter.dart';
import '../l10n/strings.dart';
import '../services/auth_service.dart';
import '../store/masrofy_store.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_background.dart';
import 'otp_screen.dart';
import 'welcome_screen.dart';

class _Country {
  final String flag;
  final String nameAr;
  final String nameEn;
  final String dialCode;

  const _Country(this.flag, this.nameAr, this.nameEn, this.dialCode);

  String name(bool isAr) => isAr ? nameAr : nameEn;
}

const List<_Country> _countries = [
  _Country('🇪🇬', 'مصر', 'Egypt', '+20'),
  _Country('🇸🇦', 'السعودية', 'Saudi Arabia', '+966'),
  _Country('🇦🇪', 'الإمارات', 'United Arab Emirates', '+971'),
  _Country('🇰🇼', 'الكويت', 'Kuwait', '+965'),
  _Country('🇶🇦', 'قطر', 'Qatar', '+974'),
  _Country('🇧🇭', 'البحرين', 'Bahrain', '+973'),
  _Country('🇴🇲', 'عُمان', 'Oman', '+968'),
  _Country('🇯🇴', 'الأردن', 'Jordan', '+962'),
  _Country('🇱🇧', 'لبنان', 'Lebanon', '+961'),
  _Country('🇮🇶', 'العراق', 'Iraq', '+964'),
  _Country('🇸🇾', 'سوريا', 'Syria', '+963'),
  _Country('🇵🇸', 'فلسطين', 'Palestine', '+970'),
  _Country('🇾🇪', 'اليمن', 'Yemen', '+967'),
  _Country('🇸🇩', 'السودان', 'Sudan', '+249'),
  _Country('🇱🇾', 'ليبيا', 'Libya', '+218'),
  _Country('🇹🇳', 'تونس', 'Tunisia', '+216'),
  _Country('🇩🇿', 'الجزائر', 'Algeria', '+213'),
  _Country('🇲🇦', 'المغرب', 'Morocco', '+212'),
  _Country('🇲🇷', 'موريتانيا', 'Mauritania', '+222'),
  _Country('🇸🇴', 'الصومال', 'Somalia', '+252'),
  _Country('🇩🇯', 'جيبوتي', 'Djibouti', '+253'),
  _Country('🇰🇲', 'جزر القمر', 'Comoros', '+269'),
  _Country('🇹🇷', 'تركيا', 'Turkey', '+90'),
  _Country('🇺🇸', 'الولايات المتحدة', 'United States', '+1'),
  _Country('🇬🇧', 'المملكة المتحدة', 'United Kingdom', '+44'),
  _Country('🇨🇦', 'كندا', 'Canada', '+1'),
  _Country('🇫🇷', 'فرنسا', 'France', '+33'),
  _Country('🇩🇪', 'ألمانيا', 'Germany', '+49'),
  _Country('🇮🇹', 'إيطاليا', 'Italy', '+39'),
  _Country('🇪🇸', 'إسبانيا', 'Spain', '+34'),
  _Country('🇳🇱', 'هولندا', 'Netherlands', '+31'),
  _Country('🇷🇺', 'روسيا', 'Russia', '+7'),
  _Country('🇮🇳', 'الهند', 'India', '+91'),
  _Country('🇵🇰', 'باكستان', 'Pakistan', '+92'),
  _Country('🇮🇩', 'إندونيسيا', 'Indonesia', '+62'),
  _Country('🇲🇾', 'ماليزيا', 'Malaysia', '+60'),
  _Country('🇳🇬', 'نيجيريا', 'Nigeria', '+234'),
  _Country('🇿🇦', 'جنوب أفريقيا', 'South Africa', '+27'),
  _Country('🇨🇳', 'الصين', 'China', '+86'),
  _Country('🇯🇵', 'اليابان', 'Japan', '+81'),
];

class LoginScreen extends StatefulWidget {
  final MasrofyStore store;

  const LoginScreen({super.key, required this.store});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _accent = LightColors.accent;
  static const _textPrimary = LightColors.textPrimary;
  static const _hint = LightColors.textMuted;

  final _phoneController = TextEditingController();
  final _phoneFocus = FocusNode();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;
  bool _submitting = false;
  bool _showDemoNotice = false;
  _Country _country = _countries.first;

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _pickCountry() async {
    final s = Strings(widget.store.language);
    FocusScope.of(context).unfocus();
    final selected = await showModalBottomSheet<_Country>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) => _CountryPickerSheet(
        countries: _countries,
        isAr: s.isAr,
        title: s.selectCountry,
        searchHint: s.searchCountry,
        selected: _country,
      ),
    );
    if (selected != null && mounted) {
      setState(() => _country = selected);
      _phoneFocus.requestFocus();
    }
  }

  void _forgotPassword() {
    final s = Strings(widget.store.language);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(s.forgotPasswordHint)));
  }

  Future<void> _continue() async {
    final s = Strings(widget.store.language);
    final digits =
        normalizeDigits(_phoneController.text).replaceAll(RegExp(r'[^0-9]'), '');
    final isEgypt = _country.dialCode == '+20';
    final valid = isEgypt
        ? (digits.length == 11 && digits.startsWith('01'))
        : (digits.length >= 6 && digits.length <= 15);
    if (!valid) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(s.phoneInvalid)));
      }
      return;
    }
    final password = _passwordController.text.trim();
    if (password.isNotEmpty && password.length < 4) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(s.passwordInvalid)));
      }
      return;
    }
    setState(() => _submitting = true);
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 400));

    final auth = AuthService.instance;
    final result = await auth.sendCode('${_country.dialCode}$digits');
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

    if (result.isAuto && result.user != null) {
      await widget.store.attachUser(result.user!.uid);
      await widget.store.setLoggedIn(true);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => WelcomeScreen(store: widget.store),
          transitionsBuilder: (_, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpScreen(
          store: widget.store,
          phone: '${_country.dialCode} $digits',
          phoneNumber: '${_country.dialCode}$digits',
          verificationId: result.verificationId,
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    final s = Strings(widget.store.language);
    setState(() => _submitting = true);
    FocusScope.of(context).unfocus();

    final user = await AuthService.instance.signInWithGoogle();
    if (!mounted) return;
    setState(() => _submitting = false);

    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.googleSignInFailed)));
      return;
    }

    await widget.store.attachUser(user.uid);
    await widget.store.setLoggedIn(true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => WelcomeScreen(store: widget.store),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = Strings(widget.store.language);
    // شاشة الدخول بخلفية رصاصي فاتح دائماً مهما كان الثيم الحالي.
    return Scaffold(
      backgroundColor: const Color(0xFFEAEAEA),
      body: PremiumBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: 'app_logo',
                  child: Image.asset(
                    'assets/icon/app_icon_clear.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  s.appName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: _submitting ? null : _pickCountry,
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 15),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_country.flag,
                                  style: const TextStyle(fontSize: 17)),
                              const SizedBox(width: 6),
                              Text(
                                _country.dialCode,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: _textPrimary,
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down,
                                  size: 18, color: _hint),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 2, vertical: 12),
                        width: 1,
                        height: 24,
                        color: const Color(0xFFE2E2E2),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          focusNode: _phoneFocus,
                          keyboardType: TextInputType.phone,
                          maxLength: 15,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _continue(),
                          inputFormatters: [
                            DigitInputFormatter(),
                            LengthLimitingTextInputFormatter(15),
                          ],
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _textPrimary),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: false,
                            hintText: s.phoneHint,
                            hintStyle: TextStyle(
                                fontSize: 14, color: _hint),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isCollapsed: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _continue(),
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: s.passwordHint,
                    hintStyle: TextStyle(fontSize: 14, color: _hint),
                    suffixIcon: IconButton(
                      onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: _hint,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _accent, width: 1.4),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    isCollapsed: true,
                  ),
                ),
                if (_showDemoNotice) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: LightColors.accentSoft,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _accent.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: _accent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            s.demoModeNotice,
                            style:
                                const TextStyle(fontSize: 12, color: _accent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _submitting ? null : _continue,
                    child: _submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white),
                          )
                        : Text(
                            s.loginTitle,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                        child: Divider(color: Colors.grey.shade300, height: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(s.orLabel,
                          style:
                              const TextStyle(fontSize: 12, color: _hint)),
                    ),
                    Expanded(
                        child: Divider(color: Colors.grey.shade300, height: 1)),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _submitting ? null : _signInWithGoogle,
                    icon: const Icon(Icons.g_mobiledata,
                        size: 28, color: Color(0xFF4285F4)),
                    label: Text(
                      s.signInWithGoogle,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _forgotPassword,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: Text(
                      s.forgotPassword,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                  ),
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

class _CountryPickerSheet extends StatefulWidget {
  final List<_Country> countries;
  final bool isAr;
  final String title;
  final String searchHint;
  final _Country selected;

  const _CountryPickerSheet({
    required this.countries,
    required this.isAr,
    required this.title,
    required this.searchHint,
    required this.selected,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  static const _accent = Color(0xFF3B5A4F);
  static const _border = Color(0xFFE3E3EC);
  static const _textPrimary = Color(0xFF17171C);

  final _searchController = TextEditingController();
  late List<_Country> _filtered = widget.countries;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    final query = q.trim().toLowerCase();
    setState(() {
      _filtered = widget.countries
          .where((c) =>
              query.isEmpty ||
              c.nameAr.contains(query) ||
              c.nameEn.toLowerCase().contains(query) ||
              c.dialCode.contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.75;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: _border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: _textPrimary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearch,
                style: const TextStyle(color: _textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF5F5F8),
                  hintText: widget.searchHint,
                  hintStyle: const TextStyle(color: Color(0xFF8A8A94)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF8A8A94)),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _accent, width: 1.4),
                  ),
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: _filtered.length,
                itemBuilder: (_, i) {
                  final c = _filtered[i];
                  final isSelected = c == widget.selected;
                  return ListTile(
                    onTap: () => Navigator.of(context).pop(c),
                    leading: Text(c.flag, style: const TextStyle(fontSize: 22)),
                    title: Text(
                      c.name(widget.isAr),
                      style: const TextStyle(
                        color: _textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          c.dialCode,
                          style: const TextStyle(
                            color: Color(0xFF55555E),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isSelected)
                          const Icon(Icons.check, color: _accent, size: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}