# مصروفي (Masrofy)

تطبيق إدارة المصاريف الشخصية — Flutter، عربي/إنجليزي، تسجيل دخول سحابي برقم الهاتف أو بحساب Google، ونسخة احتياطية لكل مستخدم في Firestore.

## المميزات

- **تسجيل دخول برقم الموبايل + OTP حقيقي** عبر Firebase Auth.
- **تسجيل دخول بحساب Google/Gmail** عبر `google_sign_in` وربطه بـ Firebase Auth.
- **بيانات سحابية لكل مستخدم**: مستند واحد تحت `users/{uid}` في Cloud Firestore.
- **ترحيل أول دخول**: بيانات المستخدم المحلية ترفع تلقائياً إلى السحابة أول مرة يسجّل فيها.
- **جلسة دائمة**: البقاء مسجّلاً بين فتحات التطبيق مع استرجاع بياناته السحابية.
- **حفظ محلي احتياطي** عبر SharedPreferences عند انقطاع الشبكة.
- **لوحة رئيسية** للرصيد والدخل والمصروفات، مع منتقي شهور وحذف بالسحب.
- **تبديل فوري** بين العربية والإنجليزية والثيمات.

## إعداد Firebase (جاهز في هذا المستودع)

المشروع المستخدم: `masrofy-d5b1c` — الحزمة `com.masrofy.masrofy`.

الملفات المكوّنة موجودة بالفعل:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- إضافات Gradle في `android/settings.gradle.kts` و `android/app/build.gradle.kts`

في Firebase Console يجب أن تكون مُفعّلة:

1. **Authentication → Sign-in method**: Phone و Google (بريد الدعم `eslamelghnam26@gmail.com`).
2. **Firestore Database**: قاعدة بيانات `(default)`، وتم نشر القواعد الموجودة في `firestore.rules`:
   ```text
   match /users/{userId} {
     allow read, write: if request.auth != null && request.auth.uid == userId;
   }
   ```
3. بصمة SHA-1 لجهاز التطوير مضافة في إعدادات تطبيق Android (لأن Google Sign-In يحتاجها).

إذا أردت مشروعك الخاص: غيّر الحزمة، نزّل ملفي الإعداد من Firebase، وحدّث `AuthService.googleWebClientId` بمعرّف عميل الويب (type 3) الخاص بمشروعك.

> ملاحظة: خطة Spark تسمح بـ 10 رسائل SMS يومياً تقريباً. لزيادة الحد يحتاج المشروع إلى خطة Blaze.

## البنية

```
lib/
  main.dart                  # التشغيل + الجلسة + ربط المستخدم بالسحابة
  l10n/strings.dart          # الترجمات
  models/transaction.dart    # النموذج + toJson/fromJson
  services/auth_service.dart # Firebase Auth: هاتف/Google + فولبك تجريبي
  store/masrofy_store.dart   # الحالة + الحفظ المحلي + مزامنة Firestore
  screens/                   # login/otp/welcome/home/settings/...
firestore.rules              # قواعد حماية كل مستخدم
```

## التشغيل والبناء

```bash
flutter pub get
flutter analyze
flutter test
flutter run
flutter build apk --release
```

APK الناتج: `build/app/outputs/flutter-apk/app-release.apk`.

## وضع تجريبي

إذا لم يتوفر إعداد Firebase (مثلاً عند استخدام الكود كم قالب فقط)، يعمل التطبيق محلياً بكود ثابت `1234`. مع الملفات الموجودة أعلاه سيكون الدخول حقيقياً.
