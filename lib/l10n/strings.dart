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

  String get periodThisMonth => isAr ? 'هذا الشهر' : 'This Month';

  String get periodAllTime => isAr ? 'كل الفترات' : 'All Time';

  String get periodHint =>
      isAr ? 'اضغط على الكروت للتبديل' : 'Tap the cards to switch';

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

  String get selectCountry => isAr ? 'اختر الدولة' : 'Select country';

  String get searchCountry => isAr ? 'ابحث عن دولة' : 'Search country';

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

  String get appSubtitle =>
      isAr ? 'إدارة أموالك.. لحياة أفضل' : 'Manage your money for a better life';

  String get navHome => isAr ? 'الرئيسية' : 'Home';

  String get navTransactions => isAr ? 'المعاملات' : 'Transactions';

  String get navReports => isAr ? 'التقارير' : 'Reports';

  String get navSettings => isAr ? 'الإعدادات' : 'Settings';

  String get remainingBalance => isAr ? 'الرصيد المتبقي' : 'Remaining balance';

  String get remainingThisMonth =>
      isAr ? 'المتبقي من هذا الشهر' : 'Remaining this month';

  String get expenseBreakdown =>
      isAr ? 'تصنيفات المصروفات' : 'Expense breakdown';

  String get expenseDistribution =>
      isAr ? 'توزيع المصروفات' : 'Expense distribution';

  String get recentTransactions =>
      isAr ? 'أحدث العمليات' : 'Recent transactions';

  String get reportsTitle => isAr ? 'التقارير' : 'Reports';

  String get settingsTitle => isAr ? 'الإعدادات' : 'Settings';

  String get themeLabel => isAr ? 'المظهر' : 'Theme';

  String get themeGreen => isAr ? 'أخضر داكن' : 'Dark green';

  String get themeCream => isAr ? 'كريمي فاتح' : 'Light cream';

  String get logout => isAr ? 'تسجيل الخروج' : 'Log out';

  String get noData => isAr ? 'لا توجد بيانات بعد' : 'No data yet';

  String get totalLabel => isAr ? 'الإجمالي' : 'Total';

  String get viewAll => isAr ? 'عرض الكل' : 'View all';

  String get monthTransactionsTitle =>
      isAr ? 'معاملات الشهر' : 'Transactions this month';

  String get budgetTitle => isAr ? 'الميزانية' : 'Budget';

  String get monthlyBudget => isAr ? 'الميزانية الشهرية' : 'Monthly budget';

  String get manageBudget => isAr ? 'إدارة الميزانية' : 'Manage budget';

  String get budgetInfo => isAr
      ? 'حدّد حد شهري لكل تصنيف بحرية كاملة — بدون أي قيود مفروضة'
      : 'Set a monthly limit for each category with full freedom — no fixed values';

  String get addCategory => isAr ? 'إضافة تصنيف' : 'Add category';

  String get newCategory => isAr ? 'تصنيف جديد' : 'New category';

  String get categoryName => isAr ? 'اسم التصنيف' : 'Category name';

  String get categoryNameHint => isAr ? 'مثال: قهوة' : 'e.g. Coffee';

  String get monthlyLimit => isAr ? 'الحد الشهري' : 'Monthly limit';

  String get limitEmptyHint =>
      isAr ? 'اتركه فاضياً لإزالة الحد' : 'Leave empty to remove the limit';

  String get noLimit => isAr ? 'بدون حد' : 'No limit';

  String get spent => isAr ? 'المنصرف' : 'Spent';

  String get remaining => isAr ? 'المتبقي' : 'Remaining';

  String get totalBudget => isAr ? 'إجمالي الميزانية' : 'Total budget';

  String get budgetEmpty =>
      isAr ? 'لسه محدّدتش ميزانية' : 'No budget set yet';

  String get budgetEmptyHint => isAr
      ? 'اضغط إدارة الميزانية وحدّد حد شهري للتصنيفات اللي تحبها'
      : 'Tap Manage budget and set a monthly limit for the categories you want';

  String get overLimit => isAr ? 'تجاوزت الحد' : 'Over limit';

  String get save => isAr ? 'حفظ' : 'Save';

  String get delete => isAr ? 'حذف' : 'Delete';

  String get editLimit => isAr ? 'تعديل الحد' : 'Edit limit';

  String get amountMustBeNumber =>
      isAr ? 'ادخل رقماً صحيحاً' : 'Enter a valid number';

  String get customCategoriesLabel => isAr ? 'تصنيفاتك' : 'Your categories';

  String get builtInCategoriesLabel =>
      isAr ? 'التصنيفات الأساسية' : 'Default categories';

  String get incomeUsed =>
      isAr ? 'من الدخل المستخدم' : 'of income used';
}