# مصروفي (Masrofy)

تطبيق إدارة المصاريف الشخصية — تجميع Flutter مع واجهة داكنة متميزة، دعم عربي/إنجليزي، تسجيل دخول برقم الموبايل، ورف اهتمام ثيم فاتح/داكن.

## المميزات

- **لوحة رئيسية**: الرصيد الحالي، الدخل، والمصروفات بكارت متدرج.
- **تسجيل الدخول برقم الموبايل + OTP**: كود SMS عبر Firebase Auth (أو وضع تجريبي بكود `1234` عند غياب إعدادات Firebase).
- **جلسة دائمة**: البقاء مسجّلاً للدخول بين فترات فتح التطبيق (SharedPreferences + استماع لحالة Firebase).
- **التحكم في اللغة**: تبديل فوري بين العربية والإنجليزية بدون إعادة تشغيل (RTL/LTR).
- **تبديل الثيم**: اللون الداكن والفاتح بشكل سلس.
- **منتقي الشهور**: عرض سجل أي شهر ماضٍ والتنقل بين السنوات.
- **حذف بالسحب** للعمليات مع حفظ تلقائي محلي (SharedPreferences).

## تفعيل إرسال SMS الحقيقي (Firebase Auth)

التطبيق يعمل فوراً بالوضع التجريبي (`1234`) حتى تتوفر إعدادات Firebase. لتشغيل الرسائل الحقيقية:

1. أنشئ مشروعاً في [Firebase Console](https://console.firebase.google.com) باسم التطبيق.
2. سجّل التطبيق (Android) بأي اسم حزمة `com.masrofy.masrofy`.
3. أضف بصمة SHA-1 لجهاز debug من سطر الأوامر:
   - `keytool -list -v -keystore $HOME/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
   - أضف البصمة (SHA-1) و (SHA-256) في إعدادات التطبيق على Firebase.
4. نزّل ملف `google-services.json` من إعدادات المشروع في Firebase وضعْه في `android/app/`.
5. أضف سطر `id("com.google.gms.google-services")` في `android/settings.gradle.kts`+`android/app/build.gradle.kts` plugins.
   - أو شغّل أداة FlutterFire: `dart pub global activate flutterfire_cli` ثم `flutterfire configure`.
6. فعّل **Phone Authentication** من قسم Authentication → Sign-in method في Firebase.

بعد ذلك سيتحول `AuthService` تلقائياً من الوضع التجريبي إلى إرسال كود حقيقي عبر SMS والتحقق الآمن.

## البنية

```
lib/
  main.dart            # نقطة التشغيل + إعداد locale/اللغة/الجلسة
  l10n/strings.dart    # الترجمات العربية/الإنجليزية
  models/transaction.dart
  services/auth_service.dart  # Firebase Auth مع فولبك تجريبي
  store/masrofy_store.dart    # الحالة + الحفظ المحلي
  theme/app_theme.dart        # الثيمات الديناميكية
  screens/
    login_screen.dart  # تسجيل الدخول برقم الموبايل
    otp_screen.dart    # شاشة التحقق (4/6 خانات)
    welcome_screen.dart# شاشة الترحيب بالرسمة
    home_screen.dart   # الرئيسية
    add_transaction_screen.dart
```

## التشغيل

```bash
flutter pub get
flutter run
```