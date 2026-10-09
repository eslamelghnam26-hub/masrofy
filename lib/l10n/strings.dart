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
}