class Strings {
  final String language;

  const Strings(this.language);

  bool get isAr => language == 'ar';

  String get appName => isAr ? 'مصروفي' : 'Masrofy';

  String get appTagline => isAr ? 'لحظاتك المالية ببساطة' : 'Your money made simple';

  String get currentBalance => isAr ? 'رصيدك الحالي' : 'Current Balance';

  String get income => isAr ? 'الدخل' : 'Income';

  String get expenses => isAr ? 'المصروفات' : 'Expenses';

  String get addIncome => isAr ? 'اضافة دخل' : 'Add Income';

  String get addExpense => isAr ? 'اضافة مصروف' : 'Add Expense';

  String get category => isAr ? 'الفئة' : 'Category';

  String get date => isAr ? 'التاريخ' : 'Date';

  String get note => isAr ? 'ملاحظة (اختياري)' : 'Note (optional)';

  String get noteHint => isAr ? 'مثال: فاتورة الكهرباء' : 'e.g. Electricity bill';

  String get saveTransaction => isAr ? 'حفظ العملية' : 'Save Transaction';

  String get amount => isAr ? 'المبلغ' : 'Amount';

  String get enterValidAmount => isAr ? 'أدخل مبلغاً صحيحاً' : 'Enter a valid amount';

  String get noTransactions => isAr ? 'لا توجد عمليات بعد' : 'No transactions yet';

  String get noTransactionsThisMonth =>
      isAr ? 'لا توجد عمليات في هذا الشهر' : 'No transactions this month';

  String transactionsCount(int count) =>
      isAr ? '$count عملية' : '$count transactions';

  String get pickMonthTitle => isAr ? 'اختر الشهر' : 'Pick a Month';

  String get thisMonth => isAr ? 'هذا الشهر' : 'This Month';

  String get chooseDate => isAr ? 'اختر التاريخ' : 'Select date';

  String get cancel => isAr ? 'إلغاء' : 'Cancel';

  String get ok => isAr ? 'موافق' : 'OK';

  String get darkMode => isAr ? 'الوضع الداكن' : 'Dark mode';

  String get lightMode => isAr ? 'الوضع الفاتح' : 'Light mode';

  String get arabic => isAr ? 'العربية' : 'Arabic';

  String get english => isAr ? 'الإنجليزية' : 'English';

  String get languageLabel => isAr ? 'اللغة' : 'Language';

  String currencySymbol() => isAr ? 'ج.م' : 'EGP';

  String currencyLocale() => isAr ? 'ar' : 'en_US';

  String dateLocale() => isAr ? 'ar' : 'en';

  String get welcomeTitle => isAr ? 'أهلاً بيك في مصروفي' : 'Welcome to Masrofy';

  String get welcomeSubtitle =>
      isAr ? 'اقفل التطبيق وابدأ تتحكم في فلوسك خطوة بخطوة' : 'Open the app and start taking control of your money';

  String get loginTitle => isAr ? 'تسجيل الدخول' : 'Sign in';

  String get phoneHint => isAr ? 'أدخل رقم الموبايل' : 'Enter your phone number';

  String get continueLabel => isAr ? 'متابعة' : 'Continue';

  String get phoneInvalid =>
      isAr ? 'رقم الموبايل غير صحيح' : 'Invalid phone number';

  String get otpTitle => isAr ? 'كود التفعيل' : 'Verification code';

  String get otpSubtitle =>
      isAr ? 'أدخل الكود اللي اتجرسل ليك' : 'Enter the code sent to you';

  String get otpHint => isAr ? 'الكود التجريبي: 1234' : 'Demo code: 1234';

  String get otpRealHint =>
      isAr ? 'أدخل الكود اللي وصل في رسالة SMS' : 'Enter the code from the SMS';

  String get otpWrong => isAr ? 'الكود غير صحيح' : 'Wrong code';

  String get otpIncomplete => isAr
      ? 'أدخل كل أرقام الكود'
      : 'Enter all the digits of the code';

  String get otpSendFailed =>
      isAr ? 'تعذر إرسال الكود. حاول مرة أخرى' : 'Failed to send code. Try again';

  String get demoModeNotice =>
      isAr ? 'الوضع التجريبي (بدون Firebase): استخدم الكود 1234' : 'Demo mode (no Firebase): use code 1234';

  String get startApp => isAr ? 'ابدأ' : 'Get started';

  String get welcomeStory =>
      isAr ? 'تتبع كل جنيه فين راح وجاء' : 'Track every pound in and out';
}