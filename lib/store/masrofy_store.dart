import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/strings.dart';
import '../models/transaction.dart';
import '../services/pin_service.dart';

/// المتجر المحلي الوحيد للتطبيق.
///
/// كل البيانات تُحفظ في ملف JSON واحد بإصدار `masrofy.data.v2`، مع نسخ
/// توافقية على مفاتيح v1 القديمة حتى لا تُفقد بيانات المستخدم عند التحديث.
class MasrofyStore extends ChangeNotifier {
  static const int schemaVersion = 2;
  static const String dataKey = 'masrofy.data.v2';

  // مفاتيح الإصدارات السابقة (تُقرأ عند الترحيل وتُكتب أيضاً للتوافق).
  static const String _key = 'masrofy.transactions.v1';
  static const String _themeKey = 'masrofy.darkMode.v1';
  static const String _themeNewKey = 'masrofy.theme.v1';
  static const String _langKey = 'masrofy.language.v1';
  static const String _summaryKey = 'masrofy.summaryAllTime.v1';
  static const String _customCatsKey = 'masrofy.customCategories.v1';
  static const String _budgetKey = 'masrofy.budgets.v1';
  static const String _openingKey = 'masrofy.openingBalance.v1';

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
  Map<String, dynamic> _extraData = {};
  Map<String, dynamic> _extraPreferences = {};

  double _openingBalance = 0;
  String _theme = 'green';
  String _language = 'ar';
  bool _summaryAllTime = false;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  bool _appLockEnabled = false;
  String? _pinSalt;
  String? _pinHash;

  bool _loaded = false;
  String? _lastError;
  Future<void> _writeChain = Future.value();

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  bool get loaded => _loaded;
  String? get lastError => _lastError;

  List<Transaction> get transactions => List.unmodifiable(_transactions);
  List<TxCategory> get customCategories => List.unmodifiable(_customCategories);

  String get language => _language;
  String get themeName => _theme;
  bool get darkMode => _theme == 'dark';
  bool get summaryAllTime => _summaryAllTime;
  DateTime get selectedMonth => _selectedMonth;

  bool get appLockEnabled => _appLockEnabled;
  bool get pinConfigured => _pinSalt != null && _pinHash != null;
  double get openingBalance => _openingBalance;

  double get totalIncome => _sumCents(_transactions
      .where((t) => t.type == TxType.income)
      .map((t) => t.amountCents));

  double get totalExpense => _sumCents(_transactions
      .where((t) => t.type == TxType.expense)
      .map((t) => t.amountCents));

  /// الرصيد الحقيقي = الرصيد الافتتاحي + الدخل - المصروف.
  double get balance =>
      Money.round(_openingBalance + totalIncome - totalExpense);

  List<Transaction> monthTransactions() => _transactions
      .where((t) =>
          t.date.year == _selectedMonth.year &&
          t.date.month == _selectedMonth.month)
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  double get monthlyIncome => _sumCents(monthTransactions()
      .where((t) => t.type == TxType.income)
      .map((t) => t.amountCents));

  double get monthlyExpense => _sumCents(monthTransactions()
      .where((t) => t.type == TxType.expense)
      .map((t) => t.amountCents));

  double get monthlyBalance => Money.round(monthlyIncome - monthlyExpense);

  double get shownIncome => _summaryAllTime ? totalIncome : monthlyIncome;
  double get shownExpense => _summaryAllTime ? totalExpense : monthlyExpense;
  double get shownBalance => _summaryAllTime ? balance : monthlyBalance;

  double get monthlyBudgetTotal => _sumCents(_budgets.values
      .expand((months) => months.values)
      .map(Money.toCents));

  double get remainingBudget => Money.round(monthlyBudgetTotal - monthlyExpense);

  double budgetFor(String categoryId) =>
      _budgets[_monthKey]?[categoryId] ?? 0;

  double spentFor(String categoryId) => _sumCents(monthTransactions()
      .where((t) => t.type == TxType.expense && t.categoryId == categoryId)
      .map((t) => t.amountCents));

  /// هل أي تصنيف تجاوز حدّه في الشهر الحالي؟
  bool get hasOverBudgetCategory => _budgets[_monthKey]?.entries.any((entry) {
        final spent = _sumCents(monthTransactions()
            .where((t) => t.type == TxType.expense && t.categoryId == entry.key)
            .map((t) => t.amountCents));
        return entry.value > 0 && spent > entry.value;
      }) ?? false;

  List<MapEntry<String, double>> monthExpenseBreakdown() {
    final totals = <String, int>{};
    for (final tx in monthTransactions()) {
      if (tx.type != TxType.expense) continue;
      totals[tx.categoryId] = (totals[tx.categoryId] ?? 0) + tx.amountCents;
    }
    final entries = totals.entries
        .map((e) => MapEntry(e.key, Money.fromCents(e.value)))
        .toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  List<Transaction> recent(int limit) {
    final items = List<Transaction>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return items.take(limit).toList();
  }

  String get _monthKey =>
      '${_selectedMonth.year.toString().padLeft(4, '0')}-${_selectedMonth.month.toString().padLeft(2, '0')}';

  static double _sumCents(Iterable<int> cents) =>
      Money.fromCents(cents.fold<int>(0, (a, b) => a + b));

  // ---------------------------------------------------------------------------
  // تحميل وحفظ
  // ---------------------------------------------------------------------------

  Future<void> load() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(dataKey);
      if (raw != null && raw.trim().isNotEmpty) {
        try {
          _applyEnvelope(jsonDecode(raw) as Map<String, dynamic>);
        } catch (_) {
          // ملف تالف: نستعيد من المفاتيح القديمة ثم نعيد كتابة النسخة الجديدة.
          _loadLegacy(prefs);
          await _persist();
        }
      } else {
        _loadLegacy(prefs);
        await _persist();
      }
      _lastError = null;
    } catch (_) {
      _lastError = Strings(_language).loadFailed;
    }
    _loaded = true;
    notifyListeners();
  }

  void _loadLegacy(SharedPreferences prefs) {
    _transactions = _decodeList(prefs.getString(_key));
    _customCategories = _decodeCategories(prefs.getString(_customCatsKey));
    AppCategory.customExpense = List.from(_customCategories);
    _budgets
      ..clear()
      ..addAll(_decodeBudgets(prefs.getString(_budgetKey)));
    _theme = prefs.getString(_themeNewKey) ??
        (prefs.getBool(_themeKey) == true ? 'dark' : 'green');
    if (!const ['green', 'cream', 'dark'].contains(_theme)) _theme = 'green';
    final lang = prefs.getString(_langKey);
    _language = (lang == 'ar' || lang == 'en') ? lang! : 'ar';
    _summaryAllTime = prefs.getBool(_summaryKey) ?? false;
    _openingBalance = prefs.getDouble(_openingKey) ?? 0;
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _appLockEnabled = false;
    _pinSalt = null;
    _pinHash = null;
    _extraData = {};
    _extraPreferences = {};
  }

  void _applyEnvelope(Map<String, dynamic> data) {
    final envelope = Map<String, dynamic>.from(data);
    _extraData = Map<String, dynamic>.from(envelope)
      ..removeWhere((key, _) => const [
            'schema', 'transactions', 'customCategories', 'defaultCategories',
            'budgets', 'openingBalance', 'preferences',
          ].contains(key));

    _transactions = _decodeList(jsonEncode(envelope['transactions'] ?? []));
    _customCategories =
        _decodeCategories(jsonEncode(envelope['customCategories'] ?? []));
    AppCategory.customExpense = List.from(_customCategories);
    _budgets
      ..clear()
      ..addAll(_decodeBudgets(jsonEncode(envelope['budgets'] ?? {})));

    final prefs = envelope['preferences'];
    final prefMap = prefs is Map<String, dynamic>
        ? Map<String, dynamic>.from(prefs)
        : <String, dynamic>{};
    _extraPreferences = Map<String, dynamic>.from(prefMap)
      ..removeWhere((key, _) => const [
            'theme', 'language', 'summaryAllTime', 'selectedMonth',
            'appLockEnabled', 'pinSalt', 'pinHash', 'openingBalance',
          ].contains(key));

    _openingBalance = _asDouble(
        prefMap['openingBalance'] ?? envelope['openingBalance'],
        fallback: 0);
    final theme = prefMap['theme'] ?? envelope['theme'];
    _theme = (theme == 'green' || theme == 'cream' || theme == 'dark')
        ? theme as String
        : 'green';
    final lang = prefMap['language'] ?? envelope['language'];
    _language = (lang == 'ar' || lang == 'en') ? lang as String : 'ar';
    _summaryAllTime =
        (prefMap['summaryAllTime'] ?? envelope['summaryAllTime']) == true;
    _appLockEnabled = prefMap['appLockEnabled'] == true;
    _pinSalt = prefMap['pinSalt'] is String ? prefMap['pinSalt'] as String : null;
    _pinHash = prefMap['pinHash'] is String ? prefMap['pinHash'] as String : null;
    if (_appLockEnabled && !pinConfigured) _appLockEnabled = false;
    _selectedMonth = _parseMonth(prefMap['selectedMonth']);
  }

  static DateTime _parseMonth(dynamic value) {
    if (value is String) {
      final parts = value.split('-');
      if (parts.length == 2) {
        final y = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        if (y != null && m != null && m >= 1 && m <= 12) {
          return DateTime(y, m);
        }
      }
    }
    return DateTime(DateTime.now().year, DateTime.now().month);
  }

  static List<Transaction> _decodeList(String? raw) {
    if (raw == null || raw.trim().isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((e) => Transaction.tryFromJson(Map<String, dynamic>.from(e)))
          .whereType<Transaction>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  static List<TxCategory> _decodeCategories(String? raw) {
    if (raw == null || raw.trim().isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((e) => TxCategory.tryFromJson(Map<String, dynamic>.from(e)))
          .whereType<TxCategory>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Map<String, Map<String, double>> _decodeBudgets(String? raw) {
    if (raw == null || raw.trim().isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      final result = <String, Map<String, double>>{};
      decoded.forEach((month, categories) {
        if (categories is! Map) return;
        final inner = <String, double>{};
        categories.forEach((id, limit) {
          final value = _asDouble(limit);
          if (value > 0) inner[id.toString()] = value;
        });
        if (inner.isNotEmpty) result[month.toString()] = inner;
      });
      return result;
    } catch (_) {
      return {};
    }
  }

  static double _asDouble(dynamic value, {double fallback = 0}) {
    if (value is num) {
      final d = value.toDouble();
      return d.isFinite ? Money.round(d.abs()) : fallback;
    }
    return fallback;
  }

  /// نسخة JSON كاملة؛ تُستخدم داخلياً للحفظ وخارجياً للتصدير.
  Map<String, dynamic> buildBackup({bool includeMeta = true}) {
    final preferences = <String, dynamic>{
      ..._extraPreferences,
      'theme': _theme,
      'language': _language,
      'summaryAllTime': _summaryAllTime,
      'selectedMonth': _monthKey,
      'appLockEnabled': _appLockEnabled,
      'pinSalt': _pinSalt,
      'pinHash': _pinHash,
      'openingBalance': _openingBalance,
    };
    final envelope = <String, dynamic>{
      ..._extraData,
      'schema': schemaVersion,
      'transactions': _transactions.map((t) => t.toJson()).toList(),
      'customCategories': _customCategories.map((c) => c.toJson()).toList(),
      'defaultCategories': AppCategory.defaultIds,
      'budgets': _budgets,
      'openingBalance': _openingBalance,
      'preferences': preferences,
    };
    if (includeMeta) {
      envelope['exportedAt'] = DateTime.now().toIso8601String();
      envelope['app'] = 'Masrofy';
    }
    return envelope;
  }

  String exportBackup() => const JsonEncoder.withIndent('  ').convert(buildBackup());

  /// استيراد نسخة احتياطية بعد تحقق صارم. لا يلمس البيانات الحالية عند الفشل.
  Future<bool> importBackup(String text) async {
    final s = Strings(_language);
    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        _setError(s.backupInvalid);
        return false;
      }
      final schema = decoded['schema'];
      if (schema is int && schema > schemaVersion) {
        _setError(s.backupInvalid);
        return false;
      }
      final txsRaw = decoded['transactions'];
      final catsRaw = decoded['customCategories'];
      if (txsRaw is! List || catsRaw is! List) {
        _setError(s.backupInvalid);
        return false;
      }
      final txs = <Transaction>[];
      for (final item in txsRaw) {
        if (item is! Map) throw const FormatException('bad transaction');
        final tx = Transaction.tryFromJson(Map<String, dynamic>.from(item));
        if (tx == null) throw const FormatException('bad transaction');
        txs.add(tx);
      }
      final cats = <TxCategory>[];
      for (final item in catsRaw) {
        if (item is! Map) throw const FormatException('bad category');
        final cat = TxCategory.tryFromJson(Map<String, dynamic>.from(item));
        if (cat == null) throw const FormatException('bad category');
        cats.add(cat);
      }

      _applyEnvelope(decoded);
      _transactions = txs;
      _customCategories = cats;
      AppCategory.customExpense = List.from(cats);
      _lastError = null;
      await _persist();
      notifyListeners();
      return true;
    } on FormatException catch (_) {
      _setError(s.backupInvalid);
      return false;
    } catch (_) {
      _setError(s.backupInvalid);
      return false;
    }
  }

  /// سلسلة كتابة متسلسلة: أي تغييرات سريعة تُكتب بالترتيب دون تداخل.
  Future<void> _persist() {
    _writeChain = _writeChain.then((_) => _writeSnapshot());
    return _writeChain;
  }

  Future<void> _writeSnapshot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final envelope = jsonEncode(buildBackup(includeMeta: false));
      await prefs.setString(dataKey, envelope);

      // نسخ توافقية للإصدارات الأقدم من التطبيق.
      await prefs.setString(
          _key, jsonEncode(_transactions.map((t) => t.toJson()).toList()));
      await prefs.setString(
          _customCatsKey,
          jsonEncode(_customCategories.map((c) => c.toJson()).toList()));
      await prefs.setString(_budgetKey, jsonEncode(_budgets));
      await prefs.setString(_themeNewKey, _theme);
      await prefs.setBool(_themeKey, _theme == 'dark');
      await prefs.setString(_langKey, _language);
      await prefs.setBool(_summaryKey, _summaryAllTime);
      await prefs.setDouble(_openingKey, _openingBalance);
      _lastError = null;
    } catch (_) {
      _setError(Strings(_language).saveFailed);
    }
  }

  void _setError(String message) {
    _lastError = message;
    notifyListeners();
  }

  void clearError() {
    if (_lastError == null) return;
    _lastError = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // العمليات
  // ---------------------------------------------------------------------------

  Future<void> add(Transaction tx) async {
    final clean = tx.copyWith(amount: Money.round(tx.amount));
    if (clean.amount <= 0) return;
    _transactions.add(clean);
    notifyListeners();
    await _persist();
  }

  Future<void> update(Transaction tx) async {
    final index = _transactions.indexWhere((t) => t.id == tx.id);
    if (index < 0) {
      await add(tx);
      return;
    }
    _transactions[index] = tx.copyWith(amount: Money.round(tx.amount));
    notifyListeners();
    await _persist();
  }

  /// تُعيد العملية المحذوفة حتى يمكن التراجع الفوري.
  Future<Transaction?> remove(String id) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index < 0) return null;
    final removed = _transactions.removeAt(index);
    notifyListeners();
    await _persist();
    return removed;
  }

  Future<void> restore(Transaction tx) async {
    if (_transactions.any((t) => t.id == tx.id)) return;
    _transactions.add(tx);
    notifyListeners();
    await _persist();
  }

  // ---------------------------------------------------------------------------
  // التفضيلات
  // ---------------------------------------------------------------------------

  Future<void> setTheme(String value) async {
    if (!const ['green', 'cream', 'dark'].contains(value) || _theme == value) {
      return;
    }
    _theme = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setLanguage(String value) async {
    if ((value != 'ar' && value != 'en') || _language == value) return;
    _language = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setSummaryAllTime(bool value) async {
    if (_summaryAllTime == value) return;
    _summaryAllTime = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setMonth(DateTime month) async {
    final next = DateTime(month.year, month.month);
    if (next == _selectedMonth) return;
    _selectedMonth = next;
    notifyListeners();
    await _persist();
  }

  Future<void> setOpeningBalance(double value) async {
    final clean = _asDouble(value);
    if (clean == _openingBalance) return;
    _openingBalance = clean;
    notifyListeners();
    await _persist();
  }

  // ---------------------------------------------------------------------------
  // التصنيفات والميزانيات
  // ---------------------------------------------------------------------------

  Future<void> addCustomCategory(String rawName) async {
    final name = rawName.trim();
    if (name.isEmpty) return;
    final id = 'custom_${DateTime.now().microsecondsSinceEpoch}';
    final color = _customColors[_customCategories.length % _customColors.length];
    final icon = AppCategory
        .paletteIcons[_customCategories.length % AppCategory.paletteIcons.length];
    _customCategories.add(TxCategory(
      id: id,
      name: name,
      nameEn: name,
      icon: icon,
      color: color,
    ));
    AppCategory.customExpense = List.from(_customCategories);
    notifyListeners();
    await _persist();
  }

  /// حذف تصنيف مخصص مع نقل جميع عملياته إلى "أخرى" بدل فقدانها.
  Future<bool> removeCustomCategory(String id) async {
    final index = _customCategories.indexWhere((c) => c.id == id);
    if (index < 0) return false;
    _customCategories.removeAt(index);
    AppCategory.customExpense = List.from(_customCategories);
    for (final tx in _transactions) {
      if (tx.categoryId == id) {
        _transactions[_transactions.indexOf(tx)] =
            tx.copyWith(categoryId: 'other');
      }
    }
    for (final month in _budgets.values) {
      month.remove(id);
    }
    notifyListeners();
    await _persist();
    return true;
  }

  Future<void> setBudget(String categoryId, double value) async {
    final clean = _asDouble(value);
    final month = _budgets.putIfAbsent(_monthKey, () => {});
    if (clean <= 0) {
      month.remove(categoryId);
      if (month.isEmpty) _budgets.remove(_monthKey);
    } else {
      month[categoryId] = clean;
    }
    notifyListeners();
    await _persist();
  }

  // ---------------------------------------------------------------------------
  // قفل التطبيق (PIN)
  // ---------------------------------------------------------------------------

  Future<bool> setPin(String pin) async {
    if (!PinService.isValidPin(pin)) {
      _setError(Strings(_language).pinInvalid);
      return false;
    }
    final salt = PinService.newSalt();
    _pinSalt = salt;
    _pinHash = PinService.hash(pin, salt);
    _appLockEnabled = true;
    notifyListeners();
    await _persist();
    return true;
  }

  bool verifyPin(String pin) {
    if (!pinConfigured) return false;
    return PinService.verify(pin, _pinSalt!, _pinHash!);
  }

  Future<bool> changePin(String currentPin, String newPin) async {
    if (!verifyPin(currentPin) || !PinService.isValidPin(newPin)) return false;
    return setPin(newPin);
  }

  Future<bool> disablePin(String currentPin) async {
    if (!verifyPin(currentPin)) return false;
    _appLockEnabled = false;
    notifyListeners();
    await _persist();
    return true;
  }
}
