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

  String get appSubtitle =>
      isAr ? 'إدارة أموالك.. لحياة أفضل' : 'Manage your money for a better life';

  String get navHome => isAr ? 'الرئيسية' : 'Home';

  String get navTransactions => isAr ? 'المعاملات' : 'Transactions';

  String get navReports => isAr ? 'الإحصائيات' : 'Statistics';

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

  String get themeGreen => isAr ? 'أخضر' : 'Green';

  String get themeGreenHint => isAr ? 'الواجهة الفاتحة الافتراضية' : 'Default light UI';

  String get themeCream => isAr ? 'كريمي' : 'Cream';

  String get themeCreamHint =>
      isAr ? 'واجهة كريمية دافئة' : 'Warm cream UI';

  String get themeDark => isAr ? 'داكن' : 'Dark';

  String get themeDarkHint => isAr ? 'وضع ليلي أخضر داكن' : 'Dark green night mode';

  String get yes => isAr ? 'نعم' : 'Yes';

  String get no => isAr ? 'لا' : 'No';

  String get noData => isAr ? 'لا توجد بيانات بعد' : 'No data yet';

  String get totalLabel => isAr ? 'الإجمالي' : 'Total';

  String get donutCenterLabel => isAr ? 'المصاريف' : 'Expenses';

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

  String get catIncome => isAr ? 'الدخل' : 'Income';

  String get catFood => isAr ? 'الطعام' : 'Food';

  String get catFun => isAr ? 'الترفيه' : 'Entertainment';

  String get catBills => isAr ? 'الفواتير' : 'Bills';

  String get catInstall => isAr ? 'الأقساط' : 'Installments';

  String get headerTagline => isAr ? 'تحكم في أموالك' : 'Control your money';

  String get homeGreet => isAr ? 'مرحباً بك' : 'Welcome back';

  String get homeGreetSub =>
      isAr ? 'خلي كل مصروف تحت السيطرة' : 'Keep every expense under control';

  String get expensesThisMonth =>
      isAr ? 'إجمالي المصروفات هذا الشهر' : 'Total expenses this month';

  String get expensesByCategory =>
      isAr ? 'المصروفات حسب الفئات' : 'Expenses by category';

  String get recentTransactionsTitle =>
      isAr ? 'أحدث المعاملات' : 'Recent transactions';

  String get noNotifications => isAr ? 'لا توجد إشعارات حالياً' : 'No notifications yet';

  // ----- إدارة العمليات -----
  String get edit => isAr ? 'تعديل' : 'Edit';

  String get editTransaction => isAr ? 'تعديل العملية' : 'Edit transaction';

  String get deleteTransactionTitle =>
      isAr ? 'حذف العملية' : 'Delete transaction';

  String get deleteTransactionMessage =>
      isAr ? 'هل تريد حذف هذه العملية نهائياً؟' : 'Delete this transaction permanently?';

  String get deleted => isAr ? 'تم الحذف' : 'Deleted';

  String get restored => isAr ? 'تمت الاستعادة' : 'Restored';

  String get undo => isAr ? 'تراجع' : 'Undo';

  String get search => isAr ? 'ابحث في العمليات...' : 'Search transactions...';

  String get filterAll => isAr ? 'الكل' : 'All';

  String get filterIncome => isAr ? 'الدخل' : 'Income';

  String get filterExpense => isAr ? 'المصروفات' : 'Expenses';

  String get allCategories => isAr ? 'كل التصنيفات' : 'All categories';

  String get sortBy => isAr ? 'ترتيب حسب' : 'Sort by';

  String get sortDate => isAr ? 'التاريخ' : 'Date';

  String get sortAmount => isAr ? 'المبلغ' : 'Amount';

  String get newestFirst => isAr ? 'الأحدث أولاً' : 'Newest first';

  String get oldestFirst => isAr ? 'الأقدم أولاً' : 'Oldest first';

  String get highestFirst => isAr ? 'الأكبر أولاً' : 'Highest first';

  String get lowestFirst => isAr ? 'الأصغر أولاً' : 'Lowest first';

  String get noFilterResults =>
      isAr ? 'لا توجد نتائج مطابقة' : 'No matching results';

  String get amountTooLarge =>
      isAr ? 'المبلغ كبير جداً' : 'Amount is too large';

  // ----- التصنيفات والميزانية -----
  String get deleteCategoryTitle =>
      isAr ? 'حذف التصنيف' : 'Delete category';

  String get deleteCategoryMessage => isAr
      ? 'سيتم نقل عمليات هذا التصنيف إلى "أخرى" مع الحفاظ على المبالغ والتواريخ.'
      : 'Transactions in this category will move to "Other" with amounts and dates preserved.';

  String get budgetExceeded =>
      isAr ? 'تجاوزت حدود بعض التصنيفات هذا الشهر' : 'Some categories exceeded their monthly limit';

  // ----- الرصيد الافتتاحي -----
  String get openingBalance => isAr ? 'الرصيد الافتتاحي' : 'Opening balance';

  String get openingBalanceHint =>
      isAr ? 'المبلغ الموجود قبل بدء التسجيل في التطبيق' : 'Amount you had before tracking started';

  // ----- قفل التطبيق -----
  String get appLock => isAr ? 'قفل التطبيق (PIN)' : 'App Lock (PIN)';

  String get appLockHint =>
      isAr ? 'رقم سري مكوّن من 4 أرقام لحماية بياناتك محلياً' : 'A 4-digit local privacy code';

  String get pinPrivacyNote => isAr
      ? 'هذا قفل خصوصية محلي وليس بديلاً عن قفل الجهاز. يُحفظ الرقم كتجزئة مشوّشة فقط.'
      : 'A local privacy lock, not a replacement for device security. Only a salted hash is stored.';

  String get pinEntryTitle => isAr ? 'أدخل رمز القفل' : 'Enter PIN';

  String get pinEntrySubtitle =>
      isAr ? 'أدخل الأرقام الأربعة لفتح مصروفي' : 'Enter the 4-digit code to open Masrofy';

  String get pinCreateTitle => isAr ? 'أنشئ رمز القفل' : 'Create PIN';

  String get pinConfirmTitle => isAr ? 'أكد رمز القفل' : 'Confirm PIN';

  String get pinChangeTitle => isAr ? 'تغيير رمز القفل' : 'Change PIN';

  String get pinCurrentTitle => isAr ? 'أدخل الرمز الحالي' : 'Enter current PIN';

  String get pinNewTitle => isAr ? 'الرمز الجديد' : 'New PIN';

  String get pinDisableTitle => isAr ? 'إلغاء قفل التطبيق' : 'Disable app lock';

  String get pinInvalid => isAr ? 'أدخل 4 أرقام صحيحة' : 'Enter exactly 4 digits';

  String get pinMismatch => isAr ? 'الرمزان غير متطابقين' : 'PINs do not match';

  String get pinWrong => isAr ? 'الرمز غير صحيح' : 'Incorrect PIN';

  String get pinSetSuccess =>
      isAr ? 'تم تفعيل قفل التطبيق' : 'App lock enabled';

  String get pinChanged => isAr ? 'تم تغيير الرمز' : 'PIN changed';

  String get pinDisabled => isAr ? 'تم إلغاء قفل التطبيق' : 'App lock disabled';

  String get pinEnable => isAr ? 'تفعيل القفل' : 'Enable lock';

  String get pinChange => isAr ? 'تغيير الرمز' : 'Change PIN';

  String get pinDisable => isAr ? 'إلغاء القفل' : 'Disable lock';

  // ----- النسخ الاحتياطي -----
  String get backupRestore => isAr ? 'النسخ الاحتياطي والاستعادة' : 'Backup & restore';

  String get backupHint => isAr
      ? 'ملف JSON محلي لا يغني عن نسخة الجهاز، لكنه يحفظ بياناتك عند تغيير الهاتف.'
      : 'A local JSON file helps move your data between devices.';

  String get exportBackup => isAr ? 'تصدير نسخة احتياطية' : 'Export backup';

  String get importBackup => isAr ? 'استيراد نسخة احتياطية' : 'Import backup';

  String get importConfirmTitle =>
      isAr ? 'استيراد النسخة الاحتياطية' : 'Import backup';

  String get importConfirmMessage => isAr
      ? 'سيتم استبدال جميع البيانات الحالية بالنسخة المستوردة. هل تريد المتابعة؟'
      : 'This will replace all current data. Continue?';

  String get backupExported =>
      isAr ? 'تم حفظ النسخة الاحتياطية' : 'Backup exported';

  String get backupCancelled =>
      isAr ? 'تم إلغاء الاستيراد' : 'Import cancelled';

  String get backupImported =>
      isAr ? 'تم استيراد البيانات بنجاح' : 'Backup imported successfully';

  String get backupInvalid =>
      isAr ? 'ملف النسخة الاحتياطية غير صالح أو غير متوافق' : 'Invalid or incompatible backup file';

  String get backupExportFailed =>
      isAr ? 'تعذر حفظ النسخة الاحتياطية' : 'Could not export backup';

  String get backupImportFailed =>
      isAr ? 'تعذر قراءة النسخة الاحتياطية' : 'Could not read backup';

  // ----- أخطاء الحفظ -----
  String get saveFailed =>
      isAr ? 'تعذر حفظ البيانات على الجهاز' : 'Could not save data on this device';

  String get loadFailed =>
      isAr ? 'تعذر تحميل البيانات المحلية' : 'Could not load local data';
}