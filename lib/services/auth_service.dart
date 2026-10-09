import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// خدمة المصادقة: تحاول استخدام Firebase Auth الحقيقي (SMS) أولاً،
/// وإذا لم يكن المشروع مكوّناً (بدون google-services.json)
/// تتحوّل تلقائياً للوضع التجريبي بكود ثابت 1234.
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  bool _firebaseReady = false;
  bool _sendFailed = false;

  /// يشير إلى أن Firebase متاح فعلاً (مشروع حقيقي مكوّن).
  bool get firebaseReady => _firebaseReady;

  /// هل فشل إرسال SMS الحقيقي (يحتاج المشروع لتكوين Firebase أولاً)؟
  bool get sendFailed => _sendFailed;

  Future<void> init() async {
    try {
      await Firebase.initializeApp();
      _firebaseReady = true;
    } catch (e) {
      _firebaseReady = false;
    }
  }

  Future<AuthResult> sendCode(String phone) async {
    if (!_firebaseReady) {
      return const AuthResult.demo();
    }
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        verificationFailed: (e) {
          _sendFailed = true;
        },
        codeSent: (verificationId, forceResendingToken) {
          _verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
      await Future.delayed(const Duration(milliseconds: 250));
      if (_sendFailed || _verificationId == null) {
        _verificationId = null;
        return const AuthResult.failed();
      }
      return AuthResult.real(_verificationId!);
    } catch (_) {
      return const AuthResult.failed();
    }
  }

  String? _verificationId;

  Future<bool> verifyCode(String verificationId, String code) async {
    if (_verificationId == null && verificationId.isEmpty) {
      // الوضع التجريبي: الكود الثابت 1234
      return code == '1234';
    }
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId.isNotEmpty
            ? verificationId
            : _verificationId!,
        smsCode: code,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// توقّع جلسة Firebase حالية (عند العودة للتطبيق).
  Future<bool> hasActiveSession() async {
    if (!_firebaseReady) return false;
    final user = FirebaseAuth.instance.currentUser;
    return user != null;
  }
}

enum AuthResultKind { real, demo, failed }

class AuthResult {
  final AuthResultKind kind;
  final String verificationId;

  const AuthResult.real(this.verificationId) : kind = AuthResultKind.real;

  const AuthResult.demo()
      : kind = AuthResultKind.demo,
        verificationId = '';

  const AuthResult.failed()
      : kind = AuthResultKind.failed,
        verificationId = '';

  bool get isReal => kind == AuthResultKind.real;
  bool get isDemo => kind == AuthResultKind.demo;
  bool get isFailed => kind == AuthResultKind.failed;
}