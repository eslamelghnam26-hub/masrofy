# مصروفي — Masrofy

تطبيق إدارة مصاريف شخصية **Offline-first** وجاهز كقالب مصدر كود تجاري.  
لا يحتوي على Firebase، ولا تسجيل دخول، ولا خوادم، ولا أي اتصال بالإنترنت أثناء الاستخدام. كل البيانات تُحفظ على جهاز المستخدم.

---

## المميزات

- واجهة عربية/إنجليزية مع RTL/LTR، وثلاث ثيمات: أخضر، كريمي، داكن.
- شاشة رئيسية مباشرة عند الفتح (لا تسجيل دخول، ولا OTP، ولا شاشة ترحيب).
- إضافة وتعديل وحذف الدخل والمصروفات.
- زر حذف أحمر واضح مع تأكيد + **تراجع Undo** فوري، مع الحفاظ على السحب للحذف.
- تعديل كل حقول العملية: المبلغ، النوع، التصنيف، التاريخ، والملاحظة.
- بحث وتصفية (الكل / دخل / مصروفات / تصنيف) وترتيب (التاريخ / المبلغ).
- تصنيفات أساسية + تصنيفات مخصّصة؛ حذف التصنيف ينقل عملياته إلى «أخرى» دون فقدانها.
- ميزانيات شهرية لكل تصنيف مع شريط تقدّم وتنبيه عند التجاوز.
- رصيد افتتاحي اختياري؛ الرصيد = الرصيد الافتتاحي + الدخل − المصروفات.
- كل الحسابات تتم بالـ cents لتقليل أخطاء الفاصلة العائمة.
- يقبل الأرقام العربية والفارسية في حقول المبالغ والميزانية.
- **App Lock (PIN)** اختياري: رقم من 4 خانات، يُحفظ كـ salted hash، مع إنشاء/تغيير/إلغاء.
- نسخ احتياطي واستعادة بصيغة JSON عبر ملف محلي، مع تأكيد قبل الاستبدال وتحقق من الملف.
- تخزين JSON بإصدار `schema: 2` مع ترحيل تلقائي من بيانات الإصدار القديمv1.
- معالجة آمنة للملفات التالفة، وإشعار للمستخدم عند فشل الحفظ.

> قفل PIN هو قفل خصوصية محلي فقط، وليس بديلاً عن قفل الجهاز أو التشفير القوي.

---

## المتطلبات

- Flutter **3.44.0** أو أحدث (تم البناء عليه).
- Dart **3.12.0** (من `environment.sdk: ^3.12.0` في `pubspec.yaml`).
- Android Studio / Xcode لإعدادات المنصات عند الحاجة.
- لا يحتاج أي Firebase project أو Google Services file أو مفتاح API.

---

## التشغيل

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

### بناء APK

```bash
flutter build apk --release
```

المسار: `build/app/outputs/flutter-apk/app-release.apk`

### بناء AAB (Google Play)

```bash
flutter build appbundle --release
```

المسار: `build/app/outputs/bundle/release/app-release.aab`

> التوقيع الحالي في `android/app/build.gradle.kts` يستخدم توقيع debug لتسهيل التجربة.  
> قبل النشر الرسمي في المتاجر، استبدله بـ upload keystore خاص بك ولا ترفع الملف `.jks/.keystore` داخل القالب.

---

## التخزين المحلي

الملف الأساسي: `masrofy.data.v2` في `SharedPreferences`.

```json
{
  "schema": 2,
  "transactions": [],
  "customCategories": [],
  "defaultCategories": [],
  "budgets": {},
  "openingBalance": 0,
  "preferences": {
    "theme": "green",
    "language": "ar",
    "appLockEnabled": false,
    "pinSalt": null,
    "pinHash": null
  }
}
```

تُكتب أيضاً مفاتيح v1 القديمة للتوافق مع الإصدارات السابقة.  
النسخة الاحتياطية القابلة للتصدير تحتوي على نفس البنية مع `exportedAt`.

> SharedPreferences لا تحمي البيانات من إلغاء تثبيت التطبيق أو مسح بياناته. لهذا يوجد تصدير/استيراد JSON يدوي.

---

## هيكل الكود

```
lib/
├── main.dart                     # بدء التطبيق + بوابة PIN + إشعارات الأخطاء
├── models/transaction.dart       # النماذج + Money (حسابات بالـ cents)
├── store/masrofy_store.dart      # التخزين، الحسابات، PIN، النسخ الاحتياطي
├── services/pin_service.dart     # salted hash محلي للـ PIN
├── l10n/strings.dart             # العربية/الإنجليزية
├── screens/
│   ├── home_screen.dart
│   ├── transactions_screen.dart
│   ├── add_transaction_screen.dart
│   ├── budget_screen.dart
│   ├── reports_screen.dart
│   ├── settings_screen.dart
│   ├── pin_screen.dart
│   └── pin_setup_sheet.dart
└── widgets/                      # TxTile, PinPad, pickers, pie chart...
```

---

## التخصيص للبيع كقالب

1. غيّر الاسم/الوصف والأيقونة من `pubspec.yaml` و`android/app/src/main/res/` و`assets/icon/`.
2. غيّر `applicationId` من `android/app/build.gradle.kts` و`namespace` إن لزم.
3. عدّل الألوان من `lib/theme/app_theme.dart` والألوان الثابتة في `home_screen.dart`.
4. أضف لغة جديدة بإضافة getters في `lib/l10n/strings.dart` وتحديث `supportedLocales`.
5. استبدل توقيع debug بتوقيع الإصدار الخاص بك قبل النشر.
6. احذف أي ملفات development/local مثل `local.properties` أو `.iml` قبل رفع القالب.
7. لا تضع كلمات مرور أو مفاتيح خاصة داخل المشروع.

---

## الاختبارات

```bash
flutter test
```

تشمل الاختبارات الآلية:
- الحفظ وإعادة التحميل بعد إعادة تشغيل المتجر.
- التعديل مع الحفاظ على المعرّف.
- الحذف والتراجع.
- تلف JSON والترحيل من v1.
- إنشاء/تحقق/تغيير/إلغاء PIN وعدم تخزين الرقم صريحاً.
- تصدير/استيراد JSON ورفض الملفات التالفة.
- حسابات الميزانية الشهرية.
- ظهور شاشة PIN قبل الرئيسية والدخول بعد الرقم الصحيح.

يُنصح أيضاً باختبار يدوي على جهاز حقيقي ل: إضافة/تعديل/حذف، إعادة تشغيل التطبيق، تبديل اللغة والثيم، تفعيل/إلغاء PIN، التصدير/الاستيراد، والتشغيل بدون إنترنت.

---

## ملاحظات

- المشروع لا يطلب أي صلاحية إنترنت في AndroidManifest.
- خط Cairo مضمّن في `google_fonts/` مع تعطيل الجلب وقت التشغيل؛ لا يوجد أي طلب شبكة لعرض الواجهة.
- خط Cairo مرخّص بموجب SIL Open Font License 1.1 (`google_fonts/OFL.txt`).
- إصدار القالب: `1.0.0+1`.
