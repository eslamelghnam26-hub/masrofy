import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction.dart';

class MasrofyStore extends ChangeNotifier {
  static const _key = 'masrofy.transactions.v1';
  static const _themeKey = 'masrofy.darkMode.v1';
  static const _langKey = 'masrofy.language.v1';

  List<Transaction> _transactions = [];
  bool _loaded = false;
  bool _darkMode = true;
  String _language = 'ar';
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  List<Transaction> get transactions => List.unmodifiable(_transactions);

  bool get loaded => _loaded;

  bool get darkMode => _darkMode;

  String get language => _language;

  DateTime get selectedMonth => _selectedMonth;

  double get totalIncome =>
      _transactions.where((t) => t.type == TxType.income).fold(0, (s, t) => s + t.amount);

  double get totalExpense =>
      _transactions.where((t) => t.type == TxType.expense).fold(0, (s, t) => s + t.amount);

  double get balance => totalIncome - totalExpense;

  List<Transaction> sorted() {
    final list = List<Transaction>.from(_transactions);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<Transaction> monthTransactions() {
    final list = _transactions
        .where((t) =>
            t.date.year == _selectedMonth.year && t.date.month == _selectedMonth.month)
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> setMonth(DateTime month) async {
    _selectedMonth = DateTime(month.year, month.month, 1);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _darkMode = !_darkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _darkMode);
  }

  Future<void> setLanguage(String lang) async {
    if (_language == lang) return;
    _language = lang;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, lang);
  }

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool(_themeKey) ?? true;
    _language = prefs.getString(_langKey) ?? 'ar';
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        _transactions = list
            .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
            .toList();
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_transactions.map((t) => t.toJson()).toList()),
    );
  }

  /// بيانات تجريبية تُحمّل أول مرة حتى لا تفتح شاشة فارغة.
  Future<void> seedIfEmpty() async {
    if (_transactions.isNotEmpty) return;
    final now = DateTime.now();
    final fallback = [
      Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: TxType.income,
        categoryId: 'salary',
        amount: 12000,
        date: DateTime(now.year, now.month, 1),
        note: 'الراتب الشهري',
      ),
      Transaction(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        type: TxType.expense,
        categoryId: 'bills',
        amount: 1500,
        date: DateTime(now.year, now.month, 3),
        note: 'الكهرباء والإنترنت',
      ),
      Transaction(
        id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
        type: TxType.expense,
        categoryId: 'food',
        amount: 850,
        date: DateTime(now.year, now.month, 5),
        note: 'تسوق الأسبوعي',
      ),
      Transaction(
        id: (DateTime.now().millisecondsSinceEpoch + 3).toString(),
        type: TxType.expense,
        categoryId: 'transport',
        amount: 400,
        date: DateTime(now.year, now.month, 7),
        note: 'بنزين',
      ),
      Transaction(
        id: (DateTime.now().millisecondsSinceEpoch + 4).toString(),
        type: TxType.income,
        categoryId: 'freelance',
        amount: 3200,
        date: DateTime(now.year, now.month, 9),
        note: 'مشروع جانبي',
      ),
    ];
    _transactions = fallback;
    await _persist();
  }
}