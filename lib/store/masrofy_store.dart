import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart'
    show FirebaseFirestore, FieldValue, SetOptions;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction.dart';

class MasrofyStore extends ChangeNotifier {
  static const _key = 'masrofy.transactions.v1';
  static const _themeKey = 'masrofy.darkMode.v1';
  static const _themeNewKey = 'masrofy.theme.v1';
  static const _langKey = 'masrofy.language.v1';
  static const _authKey = 'masrofy.loggedIn.v1';
  static const _customCatsKey = 'masrofy.customCategories.v1';
  static const _budgetKey = 'masrofy.budgets.v1';

  static const List<Color> _customColors = [
    Color(0xFFEC6B5E),
    Color(0xFF6FA8DC),
    Color(0xFFE0A458),
    Color(0xFF3FA9A0),
    Color(0xFFB78B4B),
    Color(0xFF9B8AFB),
    Color(0xFF4CAF7D),
    Color(0xFFD98BB0),
  ];

  List<Transaction> _transactions = [];
  List<TxCategory> _customCategories = [];
  final Map<String, Map<String, double>> _budgets = {};
  bool _loaded = false;
  bool _loggedIn = false;
  String? _cloudUid;
  bool _summaryAllTime = false;
  String _language = 'ar';
  String _theme = 'green';
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  List<Transaction> get transactions => List.unmodifiable(_transactions);

  /// كل تصنيفات المصروفات المتاحة (الأساسية + المخصّصة).
  List<TxCategory> get expenseCategories => AppCategory.allExpense;

  List<TxCategory> get customCategories => List.unmodifiable(_customCategories);

  bool get loaded => _loaded;

  bool get darkMode => _theme == 'dark';

  /// الثيم النشط: 'green' | 'cream' | 'dark'.
  String get themeName => _theme;

  bool get loggedIn => _loggedIn;

  /// هل البيانات مرتبطة بحساب سحابي حالياً؟
  bool get cloudSynced => _cloudUid != null;

  String get language => _language;

  DateTime get selectedMonth => _selectedMonth;

  /// وضع الكروت: false = الشهر المحدد فقط، true = كل الفترات.
  bool get summaryAllTime => _summaryAllTime;

  double get totalIncome =>
      _transactions.where((t) => t.type == TxType.income).fold(0, (s, t) => s + t.amount);

  double get totalExpense =>
      _transactions.where((t) => t.type == TxType.expense).fold(0, (s, t) => s + t.amount);

  double get balance => totalIncome - totalExpense;

  double get monthlyIncome {
    final month = _selectedMonth;
    return _transactions
        .where((t) =>
            t.type == TxType.income &&
            t.date.year == month.year &&
            t.date.month == month.month)
        .fold(0, (s, t) => s + t.amount);
  }

  double get monthlyExpense {
    final month = _selectedMonth;
    return _transactions
        .where((t) =>
            t.type == TxType.expense &&
            t.date.year == month.year &&
            t.date.month == month.month)
        .fold(0, (s, t) => s + t.amount);
  }

  double get monthlyBalance => monthlyIncome - monthlyExpense;

  /// قيمة الدخل المعروضة بحسب نطاق الكروت الحالي.
  double get shownIncome => _summaryAllTime ? totalIncome : monthlyIncome;

  /// قيمة المصروفات المعروضة بحسب نطاق الكروت الحالي.
  double get shownExpense => _summaryAllTime ? totalExpense : monthlyExpense;

  /// الرصيد المعروض بحسب نطاق الكروت الحالي.
  double get shownBalance => _summaryAllTime ? balance : monthlyBalance;

  /// تبديل نطاق الحساب (الشهر المحدد / كل الفترات).
  Future<void> toggleSummaryScope() async {
    _summaryAllTime = !_summaryAllTime;
    notifyListeners();
  }

  List<Transaction> sorted() {
    final list = List<Transaction>.from(_transactions);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<Transaction> monthTransactions() {    final list = _transactions
        .where((t) =>
            t.date.year == _selectedMonth.year && t.date.month == _selectedMonth.month)
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  /// مصروفات الشهر المحدد موزّعة حسب الفئة (تنازلياً حسب المبلغ).
  List<MapEntry<String, double>> monthExpenseBreakdown() {
    final map = <String, double>{};
    for (final t in _transactions) {
      if (t.type != TxType.expense) continue;
      if (t.date.year != _selectedMonth.year ||
          t.date.month != _selectedMonth.month) {
        continue;
      }
      map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
    }
    final list = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return list;
  }

  /// آخر [count] عملية (الأحدث أولاً).
  List<Transaction> recent(int count) => sorted().take(count).toList();

  String _monthKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  /// حدود الميزانية للشهر المحدد: معرّف الفئة → الحد الشهري.
  Map<String, double> get monthBudgets =>
      Map<String, double>.from(_budgets[_monthKey(_selectedMonth)] ?? const {});

  double budgetFor(String categoryId) =>
      _budgets[_monthKey(_selectedMonth)]?[categoryId] ?? 0;

  double get monthlyBudgetTotal =>
      monthBudgets.values.fold<double>(0, (a, b) => a + b);

  /// مجموع مصروفات الشهر المحدد لفئة معيّنة.
  double spentFor(String categoryId) {
    var sum = 0.0;
    for (final t in _transactions) {
      if (t.type != TxType.expense) continue;
      if (t.date.year != _selectedMonth.year ||
          t.date.month != _selectedMonth.month) {
        continue;
      }
      if (t.categoryId == categoryId) sum += t.amount;
    }
    return sum;
  }

  /// ضبط/تعديل الحد الشهري لفئة (0 أو أقل = إزالة الحد).
  Future<void> setBudget(String categoryId, double amount) async {
    final key = _monthKey(_selectedMonth);
    final map = _budgets.putIfAbsent(key, () => {});
    if (amount <= 0) {
      map.remove(categoryId);
      if (map.isEmpty) _budgets.remove(key);
    } else {
      map[categoryId] = amount;
    }
    await _persistBudgets();
  }

  /// إضافة تصنيف مصروفات مخصّص جديد.
  Future<TxCategory> addCustomCategory(String name) async {
    final clean = name.trim();
    final id = 'custom_${DateTime.now().microsecondsSinceEpoch}';
    final color =
        _customColors[_customCategories.length % _customColors.length];
    final icon = AppCategory
        .paletteIcons[_customCategories.length % AppCategory.paletteIcons.length];
    final cat = TxCategory(
      id: id,
      name: clean.isEmpty ? 'تصنيف' : clean,
      nameEn: clean.isEmpty ? 'Category' : clean,
      icon: icon,
      color: color,
    );
    _customCategories.add(cat);
    AppCategory.customExpense = List.from(_customCategories);
    await _persistCategories();
    return cat;
  }

  /// حذف تصنيف مخصّص (مع حدوده).
  Future<void> removeCustomCategory(String id) async {
    _customCategories.removeWhere((c) => c.id == id);
    AppCategory.customExpense = List.from(_customCategories);
    for (final m in _budgets.values) {
      m.remove(id);
    }
    await _persistCategories();
    await _persistBudgets();
  }

  Future<void> setMonth(DateTime month) async {
    _selectedMonth = DateTime(month.year, month.month, 1);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    const order = ['green', 'cream', 'dark'];
    final i = order.indexOf(_theme);
    _theme = order[(i + 1) % order.length];
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeNewKey, _theme);
    await _writeCloud();
  }

  Future<void> setTheme(String theme) async {
    if (_theme == theme) return;
    _theme = theme;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeNewKey, _theme);
    await _writeCloud();
  }

  Future<void> setLanguage(String lang) async {
    if (_language == lang) return;
    _language = lang;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, lang);
    await _writeCloud();
  }

  /// يربط المتجر بحساب المستخدم ويحمّل بياناته من Firestore.
  /// أول دخول للمستخدم يرفع بياناته المحلية إلى السحابة.
  Future<void> attachUser(String uid) async {
    if (!_loaded) await load();
    _cloudUid = uid;

    // لقطة محلية قبل قراءة السحابة، تُستخدم كترحيل أول مرة.
    final localTransactions = List<Transaction>.from(_transactions);
    final localCategories = List<TxCategory>.from(_customCategories);
    final localBudgets = _budgets.map(
      (key, value) => MapEntry(key, Map<String, double>.from(value)),
    );

    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null && data.isNotEmpty) {
        _applyCloudData(data);
        await _persistLocalAll();
      } else {
        // لا توجد بيانات سحابية بعد: ارفع ما عند المستخدم كبداية.
        _transactions = localTransactions;
        _customCategories = localCategories;
        _budgets
          ..clear()
          ..addAll(localBudgets);
        AppCategory.customExpense = List.from(_customCategories);
        await _persistLocalAll();
        await _writeCloud();
      }
    } catch (_) {
      // عند انقطاع الشبكة نحتفظ بالبيانات المحلية حتى عودة الاتصال.
      _transactions = localTransactions;
      _customCategories = localCategories;
      _budgets
        ..clear()
        ..addAll(localBudgets);
      AppCategory.customExpense = List.from(_customCategories);
    }
    notifyListeners();
  }

  /// يفصل المتجر عن الحساب الحالي ويفرغ البيانات المعروضة.
  void detachUser() {
    _cloudUid = null;
    _transactions = [];
    _customCategories = [];
    _budgets.clear();
    AppCategory.customExpense = [];
    notifyListeners();
  }

  void _applyCloudData(Map<String, dynamic> data) {
    final txRaw = data['transactions'] as List<dynamic>? ?? const [];
    _transactions = txRaw
        .whereType<Map>()
        .map((e) => Transaction.fromJson(_stringMap(e)))
        .toList();

    final catsRaw = data['customCategories'] as List<dynamic>? ?? const [];
    _customCategories = catsRaw
        .whereType<Map>()
        .map((e) => TxCategory.fromJson(_stringMap(e)))
        .toList();
    AppCategory.customExpense = List.from(_customCategories);

    _budgets.clear();
    final budgetsRaw = (data['budgets'] as Map?) ?? const {};
    budgetsRaw.forEach((key, value) {
      if (value is Map) {
        _budgets[key.toString()] = value.map(
          (cid, limit) => MapEntry(cid.toString(), (limit as num).toDouble()),
        );
      }
    });

    final lang = data['language'] as String?;
    if (lang == 'ar' || lang == 'en') _language = lang!;
    final theme = data['theme'] as String?;
    if (theme == 'green' || theme == 'cream' || theme == 'dark') {
      _theme = theme!;
    }
  }

  Future<void> setLoggedIn(bool value) async {
    _loggedIn = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_authKey, value);
  }

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeNewKey);
    final oldDark = prefs.getBool(_themeKey);
    _theme = savedTheme ??
        (oldDark == true ? 'dark' : 'green');
    _language = prefs.getString(_langKey) ?? 'ar';
    _loggedIn = prefs.getBool(_authKey) ?? false;
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        _transactions = list
            .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    final catsRaw = prefs.getString(_customCatsKey);
    if (catsRaw != null) {
      try {
        final list = jsonDecode(catsRaw) as List;
        _customCategories = list
            .map((e) => TxCategory.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    AppCategory.customExpense = List.from(_customCategories);
    final budgetRaw = prefs.getString(_budgetKey);
    if (budgetRaw != null) {
      try {
        final map = jsonDecode(budgetRaw) as Map<String, dynamic>;
        _budgets.clear();
        map.forEach((key, value) {
          final inner = <String, double>{};
          (value as Map<String, dynamic>).forEach((cid, limit) {
            inner[cid] = (limit as num).toDouble();
          });
          _budgets[key] = inner;
        });
      } catch (_) {}
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> add(Transaction t) async {
    _transactions.add(t);
    await _persist();
  }

  Future<void> remove(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _persist();
  }

  Future<void> _persist() async {
    notifyListeners();
    await _persistLocalAll();
    await _writeCloud();
  }

  Future<void> _persistCategories() async {
    notifyListeners();
    await _persistLocalAll();
    await _writeCloud();
  }

  Future<void> _persistBudgets() async {
    notifyListeners();
    await _persistLocalAll();
    await _writeCloud();
  }

  Future<void> _persistLocalAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_transactions.map((t) => t.toJson()).toList()),
    );
    await prefs.setString(
      _customCatsKey,
      jsonEncode(_customCategories.map((c) => c.toJson()).toList()),
    );
    await prefs.setString(_budgetKey, jsonEncode(_budgets));
    await prefs.setString(_themeNewKey, _theme);
    await prefs.setString(_langKey, _language);
  }

  Map<String, dynamic> _stringMap(Map<dynamic, dynamic> map) =>
      map.map((key, value) => MapEntry(key.toString(), value));

  /// يكتب نسخة المستخدم في مستند واحد تحت /users/{uid}.
  Future<void> _writeCloud() async {
    final uid = _cloudUid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {
          'transactions': _transactions.map((t) => t.toJson()).toList(),
          'customCategories': _customCategories.map((c) => c.toJson()).toList(),
          'budgets': _budgets,
          'theme': _theme,
          'language': _language,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {
      // الفشل هنا لا يوقف الاستخدام المحلي؛ سيُعاد المحاولة عند التعديل التالي.
    }
  }
}