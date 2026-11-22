import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../formatters/digit_formatter.dart';

/// بيانات المستخدم المسجّل (بغض النظر عن طريقة الدخول: هاتف أو Google).
class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? phoneNumber;
  final String? photoUrl;
  final String providerId;

  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.phoneNumber,
    this.photoUrl,
    required this.providerId,
  });

  String get displayLabel {
    final value = displayName?.trim().isNotEmpty == true
        ? displayName!.trim()
        : (email?.trim().isNotEmpty == true
            ? email!.trim()
            : (phoneNumber ?? uid));
    return value;
  }

  bool get isGoogle => providerId == 'google.com';
  bool get isPhone => providerId == 'phone';
}

/// خدمة المصادقة السحابية:
/// - رقم الهاتف عبر Firebase Auth (OTP حقيقي).
/// - حساب Google/Gmail عبر google_sign_in + Firebase Auth.
/// - وضع تجريبي (كود 1234) فقط إذا لم يتم تهيئة Firebase.
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  /// الكود التجريبي المستخدم عندما لا يكون Firebase مكوّناً.
  static const String demoCode = '1234';

  /// معرّف عميل الويب في مشروع Firebase (مطلوب لربط Google بـ Firebase Auth).
  static const String googleWebClientId =
      '632333523298-n6esnpt2vqruar8j5mk611asibuhfao9.apps.googleusercontent.com';

  bool _firebaseReady = false;
  bool _sendFailed = false;

  /// يشير إلى أن Firebase متاح فعلاً (مشروع حقيقي مكوّن).
  bool get firebaseReady => _firebaseReady;

  /// هل فشل إرسال SMS الحقيقي؟
  bool get sendFailed => _sendFailed;

  /// المستخدم الحالي في Firebase (إن وُجد).
  AppUser? get currentUser =>
      _firebaseReady ? _toAppUser(FirebaseAuth.instance.currentUser) : null;

  /// معرّف المستخدم الحالي، ويستخدمه المتجر لجلب بياناته من Firestore.
  String? get currentUid => currentUser?.uid;

  Future<void> init() async {
    try {
      await Firebase.initializeApp();
      _firebaseReady = true;
    } catch (_) {
      _firebaseReady = false;
      return;
    }
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: googleWebClientId,
      );
    } catch (_) {
      // فشل Google لا يمنع الدخول برقم الهاتف.
    }
  }

  Future<AuthResult> sendCode(String phone) async {
    // نضّر كل محاولة سابقة حتى لا تسرّب حالة قديمة إلى التحقق الحالي.
    _sendFailed = false;
    if (!_firebaseReady) {
      return const AuthResult.demo();
    }

    final completer = Completer<AuthResult>();
    void done(AuthResult result) {
      if (!completer.isCompleted) completer.complete(result);
    }

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (credential) async {
          // بعض أجهزة Android تتحقق تلقائياً من SMS بدون إدخال الكود.
          try {
            final userCredential =
                await FirebaseAuth.instance.signInWithCredential(credential);
            done(AuthResult.auto(_toAppUser(userCredential.user)));
          } catch (_) {
            done(const AuthResult.failed());
          }
        },
        verificationFailed: (e) {
          _sendFailed = true;
          done(const AuthResult.failed());
        },
        codeSent: (verificationId, forceResendingToken) {
          done(AuthResult.real(verificationId));
        },
        codeAutoRetrievalTimeout: (verificationId) {
          // ننتظر إدخال المستخدم للكود يدوياً.
        },
      );
      return await completer.future.timeout(
        const Duration(seconds: 70),
        onTimeout: () => const AuthResult.failed(),
      );
    } catch (_) {
      return const AuthResult.failed();
    }
  }

  Future<bool> verifyCode(String verificationId, String code) async {
    // نطبّع الأرقام دائماً (يدعم الإدخال العربي ١٢٣٤ أيضاً).
    final normalized = normalizeDigits(code.trim());
    // الوضع التجريبي يُحدَّد من الـverificationId الممرَّر فقط.
    if (verificationId.isEmpty) {
      return normalized == demoCode;
    }
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: normalized,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// تسجيل الدخول بحساب Google (Gmail) وربطه بحساب Firebase.
  Future<AppUser?> signInWithGoogle() async {
    if (!_firebaseReady) return null;
    try {
      final googleAccount = await GoogleSignIn.instance.authenticate();
      final idToken = googleAccount.authentication.idToken;
      if (idToken == null || idToken.isEmpty) return null;
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      return _toAppUser(userCredential.user);
    } catch (_) {
      return null;
    }
  }

  /// توقّع جلسة Firebase حالية (عند العودة للتطبيق).
  Future<bool> hasActiveSession() async {
    if (!_firebaseReady) return false;
    return FirebaseAuth.instance.currentUser != null;
  }

  /// إنهاء جلسة Firebase وGoogle (عند تسجيل الخروج).
  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    if (!_firebaseReady) return;
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
  }

  AppUser? _toAppUser(User? user) {
    if (user == null) return null;
    final provider = user.providerData.isNotEmpty
        ? user.providerData.first.providerId
        : (user.phoneNumber != null ? 'phone' : 'firebase');
    return AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      phoneNumber: user.phoneNumber,
      photoUrl: user.photoURL,
      providerId: provider,
    );
  }
}

enum AuthResultKind { real, demo, failed, auto }

class AuthResult {
  final AuthResultKind kind;
  final String verificationId;
  final AppUser? user;

  const AuthResult.real(this.verificationId, [this.user])
      : kind = AuthResultKind.real;

  const AuthResult.demo()
      : kind = AuthResultKind.demo,
        verificationId = '',
        user = null;

  const AuthResult.failed()
      : kind = AuthResultKind.failed,
        verificationId = '',
        user = null;

  const AuthResult.auto(this.user)
      : kind = AuthResultKind.auto,
        verificationId = '';

  bool get isReal => kind == AuthResultKind.real;
  bool get isDemo => kind == AuthResultKind.demo;
  bool get isFailed => kind == AuthResultKind.failed;
  bool get isAuto => kind == AuthResultKind.auto;
}
