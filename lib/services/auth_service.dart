import '../formatters/digit_formatter.dart';

/// مصادقة محلية بسيطة للتطبيق المستقل: لا شبكة ولا خدمات خارجية.
/// رمز الدخول التجريبي الثابت هو 1234 ويُقبل بعد تحويل الأرقام العربية.
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const String demoCode = '1234';

  Future<void> init() async {
    // لا شيء لتهيئته في الوضع المحلي.
  }

  /// "إرسال" الكود محلياً: لا SMS، نعود مباشرة لشاشة التحقق.
  Future<AuthResult> sendCode(String phone) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return const AuthResult.demo();
  }

  Future<bool> verifyCode(String verificationId, String code) async {
    return normalizeDigits(code.trim()) == demoCode;
  }

  /// الجلسة تُحفظ محلياً عبر MasrofyStore، لا عبر حساب خارجي.
  Future<bool> hasActiveSession() async => false;

  Future<void> signOut() async {
    // لا يوجد حساب خارجي لتسجيل الخروج منه.
  }
}

enum AuthResultKind { demo }

class AuthResult {
  final AuthResultKind kind;
  final String verificationId;

  const AuthResult.demo()
      : kind = AuthResultKind.demo,
        verificationId = '';

  bool get isDemo => kind == AuthResultKind.demo;
}
