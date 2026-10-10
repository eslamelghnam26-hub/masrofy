import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../formatters/digit_formatter.dart';
import '../l10n/strings.dart';
import '../services/auth_service.dart';
import '../store/masrofy_store.dart';
import '../theme/app_theme.dart';
import 'otp_screen.dart';

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
  static const _accent = Color(0xFF7C5CFC);
  static const _border = Color(0xFFE3E3EC);
  static const _textPrimary = Color(0xFF17171C);

  final _phoneController = TextEditingController();
  final _phoneFocus = FocusNode();
  bool _submitting = false;
  bool _showDemoNotice = false;
  _Country _country = _countries.first;

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
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

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpScreen(
          store: widget.store,
          phone: '${_country.dialCode} $digits',
          verificationId: result.verificationId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = Strings(widget.store.language);
    // شاشة الدخول دائماً بخلفية بيضاء صلبة مهما كان الثيم الحالي.
    return Scaffold(
      backgroundColor: Colors.white,
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
                      boxShadow: [
                        BoxShadow(
                          color: _accent.withValues(alpha: 0.35),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  s.appName,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  s.loginTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF55555E)),
                ),
                const SizedBox(height: 36),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _border),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: _submitting ? null : _pickCountry,
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(18),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 18),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_country.flag,
                                  style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 6),
                              Text(
                                _country.dialCode,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: _textPrimary,
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down,
                                  size: 20, color: Color(0xFF8A8A94)),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 2, vertical: 14),
                        width: 1,
                        height: 26,
                        color: _border,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          focusNode: _phoneFocus,
                          keyboardType: TextInputType.phone,
                          maxLength: 15,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _continue(),
                          inputFormatters: [
                            DigitInputFormatter(),
                            LengthLimitingTextInputFormatter(15),
                          ],
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary),
                          decoration: const InputDecoration(
                            counterText: '',
                            filled: false,
                            hintText: '010 0000 0000',
                            hintStyle: TextStyle(
                                fontSize: 15, color: Color(0xFF8A8A94)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isCollapsed: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                    ],
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
                            style: const TextStyle(fontSize: 12, color: _accent),
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
  static const _accent = Color(0xFF7C5CFC);
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
